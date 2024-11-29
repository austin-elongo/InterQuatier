package com.example.interquatier.util

import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.net.Uri
import com.google.firebase.storage.FirebaseStorage
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.tasks.await
import kotlinx.coroutines.withContext
import java.io.ByteArrayOutputStream
import java.util.UUID
import kotlin.math.roundToInt

object ImageUploader {
    private val storage = FirebaseStorage.getInstance()
    private val eventImagesRef = storage.reference.child("event_images")
    
    private const val MAX_IMAGE_SIZE = 1024 * 1024 // 1MB
    private const val COMPRESSION_QUALITY = 85

    suspend fun uploadEventImage(context: Context, imageUri: Uri): Result<String> {
        return try {
            withContext(Dispatchers.IO) {
                val compressedImage = compressImage(context, imageUri)
                val filename = "${UUID.randomUUID()}.jpg"
                val imageRef = eventImagesRef.child(filename)
                
                imageRef.putBytes(compressedImage).await()
                val downloadUrl = imageRef.downloadUrl.await()
                
                Result.success(downloadUrl.toString())
            }
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    private fun compressImage(context: Context, uri: Uri): ByteArray {
        val inputStream = context.contentResolver.openInputStream(uri)
        val options = BitmapFactory.Options().apply {
            inJustDecodeBounds = true
        }
        BitmapFactory.decodeStream(inputStream, null, options)
        inputStream?.close()

        var sampleSize = 1
        val maxDimension = 1024
        if (options.outHeight > maxDimension || options.outWidth > maxDimension) {
            val heightRatio = (options.outHeight.toFloat() / maxDimension).roundToInt()
            val widthRatio = (options.outWidth.toFloat() / maxDimension).roundToInt()
            sampleSize = kotlin.math.max(heightRatio, widthRatio)
        }

        val newInputStream = context.contentResolver.openInputStream(uri)
        options.apply {
            inJustDecodeBounds = false
            inSampleSize = sampleSize
        }
        
        val bitmap = BitmapFactory.decodeStream(newInputStream, null, options)
        newInputStream?.close()

        val outputStream = ByteArrayOutputStream()
        bitmap?.compress(Bitmap.CompressFormat.JPEG, COMPRESSION_QUALITY, outputStream)
        
        return outputStream.toByteArray()
    }
} 