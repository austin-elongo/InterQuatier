package com.example.interquatier.util

import android.content.Context
import android.content.SharedPreferences
import coil.ImageLoader
import coil.disk.DiskCache
import coil.memory.MemoryCache
import coil.request.CachePolicy
import coil.request.ImageRequest
import kotlinx.coroutines.*
import java.io.File
import java.util.concurrent.TimeUnit

object ImageCache {
    private var imageLoader: ImageLoader? = null
    private const val PREFS_NAME = "image_cache_prefs"
    private const val LAST_CLEANUP_KEY = "last_cleanup_time"
    private val CLEANUP_INTERVAL = TimeUnit.DAYS.toMillis(7)

    fun createImageLoader(context: Context): ImageLoader {
        return imageLoader ?: ImageLoader.Builder(context)
            .memoryCache {
                MemoryCache.Builder(context)
                    .maxSizePercent(0.25)
                    .build()
            }
            .diskCache {
                DiskCache.Builder()
                    .directory(File(context.cacheDir, "image_cache"))
                    .maxSizeBytes(100 * 1024 * 1024)
                    .build()
            }
            .respectCacheHeaders(false)
            .crossfade(true)
            .allowRgb565(true)
            .build()
            .also { imageLoader = it }
    }

    fun preloadImages(context: Context, urls: List<String>) {
        val loader = createImageLoader(context)
        CoroutineScope(Dispatchers.IO).launch {
            urls.forEach { url ->
                val request = ImageRequest.Builder(context)
                    .data(url)
                    .memoryCachePolicy(CachePolicy.ENABLED)
                    .diskCachePolicy(CachePolicy.ENABLED)
                    .listener(
                        onSuccess = { _, _ ->
                            markImageAsCached(context, url)
                        }
                    )
                    .build()
                loader.enqueue(request)
            }
            performCacheCleanupIfNeeded(context)
        }
    }

    private fun getPrefs(context: Context): SharedPreferences {
        return context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
    }

    private fun markImageAsCached(context: Context, url: String) {
        getPrefs(context).edit().putLong(url, System.currentTimeMillis()).apply()
    }

    private fun performCacheCleanupIfNeeded(context: Context) {
        val prefs = getPrefs(context)
        val lastCleanup = prefs.getLong(LAST_CLEANUP_KEY, 0)
        val currentTime = System.currentTimeMillis()

        if (currentTime - lastCleanup > CLEANUP_INTERVAL) {
            cleanupOldCache(context)
            prefs.edit().putLong(LAST_CLEANUP_KEY, currentTime).apply()
        }
    }

    private fun cleanupOldCache(context: Context) {
        val prefs = getPrefs(context)
        val currentTime = System.currentTimeMillis()
        val maxAge = TimeUnit.DAYS.toMillis(30)

        prefs.all.forEach { (url, timestamp) ->
            if (timestamp is Long && currentTime - timestamp > maxAge) {
                imageLoader?.diskCache?.remove(url)
                prefs.edit().remove(url).apply()
            }
        }
    }

    fun clearCache(context: Context) {
        imageLoader?.let { loader ->
            loader.memoryCache?.clear()
            loader.diskCache?.clear()
        }
        getPrefs(context).edit().clear().apply()
    }

    suspend fun ensureImagesCached(context: Context, urls: List<String>): List<String> {
        return withContext(Dispatchers.IO) {
            urls.filter { url ->
                val diskCache = imageLoader?.diskCache
                diskCache?.openSnapshot(url) != null
            }
        }
    }

    fun getCacheSize(context: Context): Long {
        var size = 0L
        val cacheDir = File(context.cacheDir, "image_cache")
        if (cacheDir.exists() && cacheDir.isDirectory) {
            cacheDir.listFiles()?.forEach { file ->
                if (file.isFile) {
                    size += file.length()
                }
            }
        }
        return size
    }

    fun getCachedImageFile(context: Context, url: String): File? {
        val cacheDir = File(context.cacheDir, "image_cache")
        return if (cacheDir.exists()) {
            File(cacheDir, url.hashCode().toString()).takeIf { it.exists() }
        } else {
            null
        }
    }
} 