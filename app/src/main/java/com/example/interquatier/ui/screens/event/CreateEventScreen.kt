package com.example.interquatier.ui.screens.event

import androidx.compose.foundation.layout.*
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowBack
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.lifecycle.viewmodel.compose.viewModel
import androidx.navigation.NavController
import com.example.interquatier.model.Event
import com.example.interquatier.viewmodel.EventViewModel
import com.google.firebase.Timestamp
import java.util.*

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun CreateEventScreen(
    navController: NavController,
    eventViewModel: EventViewModel = viewModel()
) {
    var title by remember { mutableStateOf("") }
    var sport by remember { mutableStateOf("") }
    var location by remember { mutableStateOf("") }
    var skillLevel by remember { mutableStateOf("") }
    var participantLimit by remember { mutableStateOf("") }
    var description by remember { mutableStateOf("") }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Create Event") },
                navigationIcon = {
                    IconButton(onClick = { navController.navigateUp() }) {
                        Icon(Icons.Default.ArrowBack, "Back")
                    }
                }
            )
        }
    ) { padding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(padding)
                .padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            OutlinedTextField(
                value = title,
                onValueChange = { title = it },
                label = { Text("Event Title") },
                modifier = Modifier.fillMaxWidth()
            )

            OutlinedTextField(
                value = sport,
                onValueChange = { sport = it },
                label = { Text("Sport") },
                modifier = Modifier.fillMaxWidth()
            )

            OutlinedTextField(
                value = location,
                onValueChange = { location = it },
                label = { Text("Location") },
                modifier = Modifier.fillMaxWidth()
            )

            OutlinedTextField(
                value = skillLevel,
                onValueChange = { skillLevel = it },
                label = { Text("Skill Level") },
                modifier = Modifier.fillMaxWidth()
            )

            OutlinedTextField(
                value = participantLimit,
                onValueChange = { participantLimit = it },
                label = { Text("Participant Limit") },
                modifier = Modifier.fillMaxWidth()
            )

            OutlinedTextField(
                value = description,
                onValueChange = { description = it },
                label = { Text("Description") },
                modifier = Modifier.fillMaxWidth(),
                minLines = 3
            )

            Button(
                onClick = {
                    val event = Event(
                        title = title,
                        sport = sport,
                        location = location,
                        skillLevel = skillLevel,
                        participantLimit = participantLimit.toIntOrNull() ?: 0,
                        description = description,
                        dateTime = Timestamp.now() // You might want to add a date/time picker
                    )
                    eventViewModel.createEvent(event)
                    navController.navigateUp()
                },
                modifier = Modifier.fillMaxWidth()
            ) {
                Text("Create Event")
            }
        }
    }
} 