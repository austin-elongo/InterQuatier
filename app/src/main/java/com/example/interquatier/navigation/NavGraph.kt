package com.example.interquatier.navigation

import androidx.compose.runtime.Composable
import androidx.navigation.NavHostController
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import com.example.interquatier.ui.screens.auth.LoginScreen
import com.example.interquatier.ui.screens.auth.RegisterScreen
import com.example.interquatier.ui.screens.home.HomeScreen
import com.example.interquatier.viewmodel.AuthViewModel

@Composable
fun NavGraph(
    navController: NavHostController,
    authViewModel: AuthViewModel
) {
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
            HomeScreen(navController, authViewModel)
        }
    }
} 