package com.example.interquatier.ui.screens.event

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.grid.GridCells
import androidx.compose.foundation.lazy.grid.LazyVerticalGrid
import androidx.compose.foundation.lazy.grid.items
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.navigation.NavController
import com.example.interquatier.navigation.Screen

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun EventMenuScreen(
    navController: NavController
) {
    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Events") }
            )
        },
        floatingActionButton = {
            ExtendedFloatingActionButton(
                onClick = { navController.navigate(Screen.CreateEvent.route) },
                icon = { 
                    Icon(
                        Icons.Default.Add, 
                        "Create Event",
                        tint = MaterialTheme.colorScheme.onPrimary
                    ) 
                },
                text = { 
                    Text(
                        "Create Event",
                        color = MaterialTheme.colorScheme.onPrimary
                    ) 
                },
                containerColor = MaterialTheme.colorScheme.primary
            )
        },
        floatingActionButtonPosition = FabPosition.End
    ) { padding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(padding)
        ) {
            LazyVerticalGrid(
                columns = GridCells.Fixed(2),
                contentPadding = PaddingValues(16.dp),
                horizontalArrangement = Arrangement.spacedBy(16.dp),
                verticalArrangement = Arrangement.spacedBy(16.dp),
                modifier = Modifier.weight(1f)
            ) {
                items(eventCategories) { category ->
                    EventCategoryCard(
                        category = category,
                        onClick = { navController.navigate(category.route) }
                    )
                }
            }

            QuickActions(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(16.dp)
            )
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun EventCategoryCard(
    category: EventCategory,
    onClick: () -> Unit
) {
    Card(
        onClick = onClick,
        modifier = Modifier
            .fillMaxWidth()
            .aspectRatio(1f)
    ) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(16.dp),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.Center
        ) {
            Icon(
                imageVector = category.icon,
                contentDescription = null,
                modifier = Modifier.size(48.dp),
                tint = MaterialTheme.colorScheme.primary  // Using primary color (orange) for icons
            )
            Spacer(modifier = Modifier.height(8.dp))
            Text(
                text = category.title,
                style = MaterialTheme.typography.titleMedium,
                textAlign = TextAlign.Center
            )
        }
    }
}

@Composable
private fun QuickActions(modifier: Modifier = Modifier) {
    Surface(
        modifier = modifier,
        tonalElevation = 2.dp,
        shape = MaterialTheme.shapes.medium
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(8.dp),
            horizontalArrangement = Arrangement.SpaceEvenly
        ) {
            QuickActionButton(
                icon = Icons.Default.Star,
                label = "Featured",
                onClick = { /* TODO */ }
            )
            QuickActionButton(
                icon = Icons.Default.TrendingUp,
                label = "Popular",
                onClick = { /* TODO */ }
            )
            QuickActionButton(
                icon = Icons.Default.Notifications,
                label = "Upcoming",
                onClick = { /* TODO */ }
            )
            QuickActionButton(
                icon = Icons.Default.Bookmark,
                label = "Saved",
                onClick = { /* TODO */ }
            )
        }
    }
}

@Composable
private fun QuickActionButton(
    icon: ImageVector,
    label: String,
    onClick: () -> Unit
) {
    IconButton(
        onClick = onClick,
        modifier = Modifier.padding(8.dp)
    ) {
        Column(
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Icon(
                icon, 
                contentDescription = label,
                tint = MaterialTheme.colorScheme.primary  // Using primary color (orange) for icons
            )
            Text(
                text = label,
                style = MaterialTheme.typography.labelSmall
            )
        }
    }
}

private data class EventCategory(
    val title: String,
    val icon: ImageVector,
    val route: String
)

private val eventCategories = listOf(
    EventCategory(
        "Sports",
        Icons.Default.SportsBasketball,
        "events/sports"
    ),
    EventCategory(
        "Tournaments",
        Icons.Default.EmojiEvents,
        "events/tournaments"
    ),
    EventCategory(
        "Training",
        Icons.Default.FitnessCenter,
        "events/training"
    ),
    EventCategory(
        "Charity",
        Icons.Default.Favorite,
        "events/charity"
    ),
    EventCategory(
        "Stakes",
        Icons.Default.AttachMoney,
        "events/stakes"
    ),
    EventCategory(
        "Teams",
        Icons.Default.Groups,
        "events/teams"
    )
) 