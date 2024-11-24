package com.example.interquatier.ui.screens.settings

import androidx.compose.foundation.layout.*
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.foundation.clickable
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.navigation.NavController
import com.example.interquatier.navigation.Screen
import com.example.interquatier.viewmodel.AuthViewModel

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun SettingsScreen(
    navController: NavController,
    authViewModel: AuthViewModel
) {
    var notifications by remember { mutableStateOf(true) }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Settings") }
            )
        }
    ) { padding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(padding)
                .padding(16.dp)
        ) {
            // Account Section
            Text(
                text = "Account",
                style = MaterialTheme.typography.titleMedium,
                modifier = Modifier.padding(vertical = 8.dp)
            )
            
            ListItem(
                headlineContent = { Text("Edit Profile") },
                leadingContent = { Icon(Icons.Default.Person, null) },
                modifier = Modifier.clickable { navController.navigate(Screen.Profile.route) }
            )

            ListItem(
                headlineContent = { Text("Privacy Settings") },
                leadingContent = { Icon(Icons.Default.Lock, null) },
                modifier = Modifier.clickable { /* TODO */ }
            )

            Divider(modifier = Modifier.padding(vertical = 8.dp))

            // App Settings
            Text(
                text = "App Settings",
                style = MaterialTheme.typography.titleMedium,
                modifier = Modifier.padding(vertical = 8.dp)
            )

            ListItem(
                headlineContent = { Text("Notifications") },
                leadingContent = { Icon(Icons.Default.Notifications, null) },
                trailingContent = {
                    Switch(
                        checked = notifications,
                        onCheckedChange = { notifications = it }
                    )
                }
            )

            Divider(modifier = Modifier.padding(vertical = 8.dp))

            // Premium Features
            Text(
                text = "Premium",
                style = MaterialTheme.typography.titleMedium,
                modifier = Modifier.padding(vertical = 8.dp)
            )

            ListItem(
                headlineContent = { Text("Upgrade to Premium") },
                supportingContent = { Text("Get access to exclusive features") },
                leadingContent = { Icon(Icons.Default.Star, null) },
                modifier = Modifier.clickable { /* TODO: Implement premium upgrade */ }
            )

            Spacer(modifier = Modifier.weight(1f))

            // Logout Button
            Button(
                onClick = {
                    authViewModel.logout()
                    navController.navigate(Screen.Login.route) {
                        popUpTo(0) { inclusive = true }
                    }
                },
                modifier = Modifier.fillMaxWidth(),
                colors = ButtonDefaults.buttonColors(
                    containerColor = MaterialTheme.colorScheme.error
                )
            ) {
                Icon(Icons.Default.ExitToApp, null)
                Spacer(modifier = Modifier.width(8.dp))
                Text("Logout")
            }
        }
    }
} 