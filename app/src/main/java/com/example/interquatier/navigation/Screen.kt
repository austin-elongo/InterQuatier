package com.example.interquatier.navigation

sealed class Screen(val route: String) {
    object Login : Screen("login")
    object Register : Screen("register")
    object Home : Screen("home")
    object EventMenu : Screen("event_menu")
    object Chat : Screen("chat")
    object Profile : Screen("profile")
    object Settings : Screen("settings")
    object CreateEvent : Screen("create_event")
    object EventDetails : Screen("event_details/{eventId}") {
        fun createRoute(eventId: String) = "event_details/$eventId"
    }
    object EventsByCategory : Screen("events/{category}") {
        fun createRoute(category: String) = "events/$category"
    }
} 