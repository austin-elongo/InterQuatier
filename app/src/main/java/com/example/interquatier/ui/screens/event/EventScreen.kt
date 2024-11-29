package com.example.interquatier.ui.screens.event

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Add
import androidx.compose.material.icons.filled.Menu
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.unit.dp
import androidx.lifecycle.viewmodel.compose.viewModel
import androidx.navigation.NavController
import com.example.interquatier.model.Event
import com.example.interquatier.navigation.Screen
import com.example.interquatier.viewmodel.EventViewModel
import com.example.interquatier.viewmodel.EventState
import java.text.SimpleDateFormat
import java.util.*
import kotlinx.coroutines.launch
import androidx.compose.runtime.rememberCoroutineScope
import com.example.interquatier.util.ImageCache
import com.example.interquatier.ui.components.EventBanner

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun EventScreen(
    navController: NavController,
    eventViewModel: EventViewModel = viewModel()
) {
    val events by eventViewModel.events.collectAsState()
    val context = LocalContext.current
    
    // Preload all event images
    LaunchedEffect(events) {
        val imageUrls = events.mapNotNull { event -> 
            event.bannerImageUrl.takeIf { it.isNotBlank() }
        }
        ImageCache.preloadImages(context, imageUrls)
    }

    Scaffold(
        // Add the FAB here
        floatingActionButton = {
            FloatingActionButton(
                onClick = { navController.navigate(Screen.CreateEvent.route) }
            ) {
                Icon(Icons.Default.Add, contentDescription = "Create Event")
            }
        },
        floatingActionButtonPosition = FabPosition.End
    ) { padding ->
        val eventsList = events.toList()

        LazyColumn(
            modifier = Modifier
                .fillMaxSize()
                .padding(padding),
            contentPadding = PaddingValues(16.dp),
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            items(
                items = eventsList,
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

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun EventCard(
    event: Event,
    onEventClick: () -> Unit
) {
    Card(
        modifier = Modifier.fillMaxWidth(),
        onClick = onEventClick
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(16.dp)
        ) {
            Text(
                text = event.title,
                style = MaterialTheme.typography.headlineSmall
            )
            Spacer(modifier = Modifier.height(8.dp))
            Text(
                text = event.sport,
                style = MaterialTheme.typography.bodyLarge
            )
            Spacer(modifier = Modifier.height(4.dp))
            Text(
                text = event.location,
                style = MaterialTheme.typography.bodyMedium
            )
            Spacer(modifier = Modifier.height(4.dp))
            Text(
                text = SimpleDateFormat("MMM dd, yyyy HH:mm", Locale.getDefault())
                    .format(event.dateTime.toDate()),
                style = MaterialTheme.typography.bodyMedium
            )
            Spacer(modifier = Modifier.height(8.dp))
            LinearProgressIndicator(
                progress = event.currentParticipants.size.toFloat() / event.participantLimit,
                modifier = Modifier.fillMaxWidth()
            )
            Text(
                text = "${event.currentParticipants.size}/${event.participantLimit} participants",
                style = MaterialTheme.typography.bodySmall
            )
        }
    }
} 