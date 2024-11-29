package com.example.interquatier.ui.screens.event

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.unit.dp
import androidx.navigation.NavController
import coil.compose.AsyncImage
import com.example.interquatier.model.Event
import java.text.SimpleDateFormat
import java.util.*

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun EventDetailsScreen(
    navController: NavController,
    event: Event
) {
    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Event Details") },
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
                .verticalScroll(rememberScrollState())
        ) {
            // Banner Image
            AsyncImage(
                model = event.bannerImageUrl,
                contentDescription = "Event banner",
                modifier = Modifier
                    .fillMaxWidth()
                    .height(200.dp),
                contentScale = ContentScale.Crop
            )

            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(16.dp),
                verticalArrangement = Arrangement.spacedBy(16.dp)
            ) {
                // Title and Basic Info
                Text(
                    text = event.title,
                    style = MaterialTheme.typography.headlineMedium
                )

                // Sport and Type
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween
                ) {
                    InfoChip(
                        icon = Icons.Default.SportsBasketball,
                        text = event.sport
                    )
                    InfoChip(
                        icon = Icons.Default.Category,
                        text = event.eventType
                    )
                }

                // Date and Time
                InfoRow(
                    icon = Icons.Default.Schedule,
                    title = "Date & Time",
                    value = SimpleDateFormat("MMM dd, yyyy HH:mm", Locale.getDefault())
                        .format(event.dateTime.toDate())
                )

                // Location
                InfoRow(
                    icon = Icons.Default.Place,
                    title = "Location",
                    value = event.location
                )

                // Participants
                InfoRow(
                    icon = Icons.Default.Group,
                    title = "Participants",
                    value = "${event.currentParticipants.size}/${event.participantLimit}"
                )

                // Entry Fee
                if (event.entryFee > 0) {
                    InfoRow(
                        icon = Icons.Default.AttachMoney,
                        title = "Entry Fee",
                        value = "$${event.entryFee}"
                    )
                }

                // Duration
                InfoRow(
                    icon = Icons.Default.Timer,
                    title = "Duration",
                    value = event.duration
                )

                // Skill Level
                InfoRow(
                    icon = Icons.Default.Star,
                    title = "Skill Level",
                    value = event.skillLevel
                )

                // Age Group
                InfoRow(
                    icon = Icons.Default.Person,
                    title = "Age Group",
                    value = event.ageGroup
                )

                // Gender Restriction
                InfoRow(
                    icon = Icons.Default.People,
                    title = "Gender Restriction",
                    value = event.genderRestriction
                )

                // Equipment
                InfoRow(
                    icon = Icons.Default.SportsTennis,
                    title = "Equipment Provided",
                    value = event.equipmentProvided
                )

                // Weather Backup Plan
                InfoRow(
                    icon = Icons.Default.WbSunny,
                    title = "Weather Backup Plan",
                    value = event.weatherBackupPlan
                )

                // Special Requirements
                if (event.specialRequirements.isNotEmpty()) {
                    Text(
                        text = "Special Requirements",
                        style = MaterialTheme.typography.titleMedium
                    )
                    event.specialRequirements.forEach { requirement ->
                        Text("• $requirement")
                    }
                }

                // Description
                if (event.description.isNotBlank()) {
                    Text(
                        text = "Description",
                        style = MaterialTheme.typography.titleMedium
                    )
                    Text(event.description)
                }

                // Additional Notes
                if (event.additionalNotes.isNotBlank()) {
                    Text(
                        text = "Additional Notes",
                        style = MaterialTheme.typography.titleMedium
                    )
                    Text(event.additionalNotes)
                }

                Spacer(modifier = Modifier.height(16.dp))

                // Join Button
                Button(
                    onClick = { /* TODO: Implement join functionality */ },
                    modifier = Modifier.fillMaxWidth()
                ) {
                    Text("Join Event")
                }
            }
        }
    }
}

@Composable
private fun InfoRow(
    icon: ImageVector,
    title: String,
    value: String,
    modifier: Modifier = Modifier
) {
    Row(
        modifier = modifier.fillMaxWidth(),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Icon(
            imageVector = icon,
            contentDescription = null,
            modifier = Modifier.size(24.dp)
        )
        Spacer(modifier = Modifier.width(8.dp))
        Column {
            Text(
                text = title,
                style = MaterialTheme.typography.labelMedium
            )
            Text(
                text = value,
                style = MaterialTheme.typography.bodyLarge
            )
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun InfoChip(
    icon: ImageVector,
    text: String,
    modifier: Modifier = Modifier
) {
    AssistChip(
        onClick = { },
        label = { Text(text) },
        leadingIcon = { Icon(icon, contentDescription = null) },
        modifier = modifier
    )
} 