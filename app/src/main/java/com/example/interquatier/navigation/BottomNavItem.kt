package com.example.interquatier.navigation

import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Home
import androidx.compose.material.icons.filled.List
import androidx.compose.material.icons.filled.Email
import androidx.compose.material.icons.filled.Person
import androidx.compose.material.icons.filled.Settings
import androidx.compose.ui.graphics.vector.ImageVector

sealed class BottomNavItem(
    val route: String,
    val title: String,
    val icon: ImageVector
) {
    object Home : BottomNavItem(Screen.Home.route, "Home", Icons.Default.Home)
    object Events : BottomNavItem(Screen.Events.route, "Events", Icons.Default.List)
    object Messages : BottomNavItem(Screen.Chat.route, "Messages", Icons.Default.Email)
    object Profile : BottomNavItem(Screen.Profile.route, "Profile", Icons.Default.Person)
    object Settings : BottomNavItem(Screen.Settings.route, "Settings", Icons.Default.Settings)

    companion object {
        val items = listOf(Home, Events, Messages, Profile, Settings)
    }
} 