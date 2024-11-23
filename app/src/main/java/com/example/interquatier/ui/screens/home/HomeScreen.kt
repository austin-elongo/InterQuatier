package com.example.interquatier.ui.screens.home

import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.navigation.NavController

@Composable
fun HomeScreen(navController: NavController) {
    Scaffold(
        topBar = {
            SmallTopAppBar(
                title = { Text("InterQuatier") },
                actions = {
                    // Add logout button
                    IconButton(onClick = {
                        // TODO: Implement logout
                    }) {
                        Text("Logout")
                    }
                }
            )
        }
    ) { paddingValues ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(paddingValues)
        ) {
            Text("Welcome to InterQuatier!")
            // TODO: Add event list and other home screen content
        }
    }
} 