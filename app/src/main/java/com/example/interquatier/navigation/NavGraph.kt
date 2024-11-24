package com.example.interquatier.navigation

import androidx.compose.runtime.Composable
import androidx.navigation.NavHostController
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.NavType
import androidx.navigation.navArgument
import com.example.interquatier.ui.screens.auth.LoginScreen
import com.example.interquatier.ui.screens.auth.RegisterScreen
import com.example.interquatier.ui.screens.home.HomeScreen
import com.example.interquatier.ui.screens.event.CreateEventScreen
import com.example.interquatier.ui.screens.event.EventScreen
import com.example.interquatier.viewmodel.AuthViewModel
import com.example.interquatier.viewmodel.EventViewModel
import androidx.lifecycle.viewmodel.compose.viewModel
import com.example.interquatier.ui.screens.settings.SettingsScreen
import com.example.interquatier.ui.screens.profile.ProfileScreen
import com.example.interquatier.ui.screens.chat.ChatScreen

@Composable
fun NavGraph(
    navController: NavHostController,
    authViewModel: AuthViewModel
) {
    val eventViewModel: EventViewModel = viewModel()
    
    NavHost(
        navController = navController,
        startDestination = if (authViewModel.isLoggedIn()) Screen.Home.route else Screen.Login.route
    ) {
        composable(Screen.Login.route) {
            LoginScreen(navController, authViewModel)
        }
        
        composable(Screen.Register.route) {
            RegisterScreen(navController, authViewModel)
        }
        
        composable(Screen.Home.route) {
            EventScreen(navController, eventViewModel)
        }
        
        composable(Screen.CreateEvent.route) {
            CreateEventScreen(navController, eventViewModel)
        }
        
        composable(
            route = Screen.EventDetails.route,
            arguments = listOf(navArgument("eventId") { type = NavType.StringType })
        ) { backStackEntry ->
            val eventId = backStackEntry.arguments?.getString("eventId") ?: return@composable
            // EventDetailsScreen(navController, eventViewModel, eventId)
        }
        
        composable(Screen.Settings.route) {
            SettingsScreen(navController, authViewModel)
        }
        
        composable(Screen.Profile.route) {
            ProfileScreen(navController, authViewModel)
        }
        
        composable(Screen.Chat.route) {
            ChatScreen(navController)
        }
    }
} 