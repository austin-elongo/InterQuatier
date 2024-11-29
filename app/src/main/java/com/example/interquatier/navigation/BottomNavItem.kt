package com.example.interquatier.navigation

import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Event
import androidx.compose.material.icons.filled.Home
import androidx.compose.material.icons.filled.Person
import androidx.compose.material.icons.automirrored.filled.Chat
import androidx.compose.ui.graphics.vector.ImageVector

sealed class BottomNavItem(
    val route: String,
    val title: String,
    val icon: ImageVector
) {
    object Home : BottomNavItem("home", "Home", Icons.Default.Home)
    object Events : BottomNavItem("event_menu", "Events", Icons.Default.Event)
    object Chat : BottomNavItem("chat", "Chat", Icons.AutoMirrored.Filled.Chat)
    object Profile : BottomNavItem("profile", "Profile", Icons.Default.Person)

    companion object {
        val items = listOf(Home, Events, Chat, Profile)
    }
} 