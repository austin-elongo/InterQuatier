package com.example.interquatier.ui.screens.event

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowBack
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.lifecycle.viewmodel.compose.viewModel
import androidx.navigation.NavController
import com.example.interquatier.navigation.Screen
import com.example.interquatier.ui.components.EventBanner
import com.example.interquatier.viewmodel.EventViewModel

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun EventsByCategoryScreen(
    navController: NavController,
    category: String,
    eventViewModel: EventViewModel = viewModel()
) {
    val events by eventViewModel.events.collectAsState()
    val filteredEvents = events.filter { event ->
        when (category) {
            "sports" -> true  // Show all sports events
            "tournaments" -> event.eventType == "Tournament"
            "training" -> event.eventType == "Training Session"
            "charity" -> event.eventType == "Charity Event"
            "stakes" -> event.entryFee > 0
            "teams" -> event.participantLimit > 1
            else -> false
        }
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { 
                    Text(
                        when (category) {
                            "sports" -> "Sports Events"
                            "tournaments" -> "Tournaments"
                            "training" -> "Training Sessions"
                            "charity" -> "Charity Events"
                            "stakes" -> "Stakes Events"
                            "teams" -> "Team Events"
                            else -> "Events"
                        }
                    )
                },
                navigationIcon = {
                    IconButton(onClick = { navController.navigateUp() }) {
                        Icon(Icons.Default.ArrowBack, "Back")
                    }
                }
            )
        }
    ) { padding ->
        if (filteredEvents.isEmpty()) {
            Box(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(padding)
                    .padding(16.dp)
            ) {
                Text(
                    text = "No events found in this category",
                    style = MaterialTheme.typography.bodyLarge
                )
            }
        } else {
            LazyColumn(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(padding),
                contentPadding = PaddingValues(16.dp),
                verticalArrangement = Arrangement.spacedBy(16.dp)
            ) {
                items(
                    items = filteredEvents,
                    key = { event -> event.id }
                ) { event ->
                    EventBanner(
                        event = event,
                        onClick = {
                            navController.navigate(Screen.EventDetails.createRoute(event.id))
                        }
                    )
                }
            }
        }
    }
} 