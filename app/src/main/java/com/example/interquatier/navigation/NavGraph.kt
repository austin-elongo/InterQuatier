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
import com.example.interquatier.ui.screens.event.EventDetailsScreen
import com.example.interquatier.ui.screens.event.EventMenuScreen
import com.example.interquatier.ui.screens.event.EventsByCategoryScreen
import com.example.interquatier.ui.screens.common.ComingSoonScreen

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
            val event = eventViewModel.getEvent(eventId)
            event?.let {
                EventDetailsScreen(navController = navController, event = it)
            }
        }
        
        composable(Screen.Settings.route) {
            ComingSoonScreen(
                navController = navController,
                title = "Settings",
                message = "Settings feature coming soon!"
            )
        }
        
        composable(Screen.Profile.route) {
            ComingSoonScreen(
                navController = navController,
                title = "Profile",
                message = "Profile feature coming soon!"
            )
        }
        
        composable(Screen.Chat.route) {
            ComingSoonScreen(
                navController = navController,
                title = "Chat",
                message = "Chat feature coming soon!"
            )
        }
        
        composable(Screen.EventMenu.route) {
            EventMenuScreen(navController)
        }
        
        composable(
            route = Screen.EventsByCategory.route,
            arguments = listOf(navArgument("category") { type = NavType.StringType })
        ) { backStackEntry ->
            val category = backStackEntry.arguments?.getString("category") ?: return@composable
            EventsByCategoryScreen(navController, category)
        }
        
        composable("events/sports") {
            ComingSoonScreen(
                navController = navController,
                title = "Sports Events",
                message = "Sports events feature coming soon!"
            )
        }
        
        composable("events/tournaments") {
            ComingSoonScreen(
                navController = navController,
                title = "Tournaments",
                message = "Tournaments feature coming soon!"
            )
        }
        
        composable("events/training") {
            ComingSoonScreen(
                navController = navController,
                title = "Training Sessions",
                message = "Training sessions feature coming soon!"
            )
        }
        
        composable("events/charity") {
            ComingSoonScreen(
                navController = navController,
                title = "Charity Events",
                message = "Charity events feature coming soon!"
            )
        }
        
        composable("events/stakes") {
            ComingSoonScreen(
                navController = navController,
                title = "Stakes Events",
                message = "Stakes events feature coming soon!"
            )
        }
        
        composable("events/teams") {
            ComingSoonScreen(
                navController = navController,
                title = "Team Events",
                message = "Team events feature coming soon!"
            )
        }
    }
} 