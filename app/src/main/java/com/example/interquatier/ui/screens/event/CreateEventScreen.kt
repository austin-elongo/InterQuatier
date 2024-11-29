package com.example.interquatier.ui.screens.event

import android.net.Uri
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.clickable
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowBack
import androidx.compose.material.icons.filled.AddPhotoAlternate
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.unit.dp
import androidx.lifecycle.viewmodel.compose.viewModel
import androidx.navigation.NavController
import coil.compose.AsyncImage
import com.example.interquatier.model.Event
import com.example.interquatier.ui.components.*
import com.example.interquatier.util.EventConstants
import com.example.interquatier.util.ImageUploader
import com.example.interquatier.viewmodel.EventViewModel
import com.google.firebase.Timestamp
import kotlinx.coroutines.launch
import java.text.SimpleDateFormat
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
    var dateTime by remember { mutableStateOf(Calendar.getInstance().time) }
    var skillLevel by remember { mutableStateOf("") }
    var participantLimit by remember { mutableStateOf("") }
    var description by remember { mutableStateOf("") }
    var eventType by remember { mutableStateOf("") }
    var entryFee by remember { mutableStateOf("") }
    var equipmentProvided by remember { mutableStateOf("") }
    var ageGroup by remember { mutableStateOf("") }
    var duration by remember { mutableStateOf("") }
    var genderRestriction by remember { mutableStateOf("") }
    var weatherBackupPlan by remember { mutableStateOf("") }
    var specialRequirements by remember { mutableStateOf(setOf<String>()) }
    var additionalNotes by remember { mutableStateOf("") }
    
    var showDatePicker by remember { mutableStateOf(false) }
    var showTimePicker by remember { mutableStateOf(false) }
    var selectedImageUri by remember { mutableStateOf<Uri?>(null) }
    val context = LocalContext.current
    val scope = rememberCoroutineScope()

    val imagePickerLauncher = rememberLauncherForActivityResult(
        contract = ActivityResultContracts.GetContent()
    ) { uri: Uri? ->
        selectedImageUri = uri
    }

    if (showDatePicker) {
        DatePickerDialog(
            onDismissRequest = { showDatePicker = false },
            onDateSelected = { selectedDate ->
                val calendar = Calendar.getInstance().apply {
                    time = dateTime
                    set(Calendar.YEAR, selectedDate.year)
                    set(Calendar.MONTH, selectedDate.monthValue - 1)
                    set(Calendar.DAY_OF_MONTH, selectedDate.dayOfMonth)
                }
                dateTime = calendar.time
                showDatePicker = false
                showTimePicker = true
            }
        )
    }

    if (showTimePicker) {
        TimePickerDialog(
            onDismissRequest = { showTimePicker = false },
            onTimeSelected = { hour, minute ->
                val calendar = Calendar.getInstance().apply {
                    time = dateTime
                    set(Calendar.HOUR_OF_DAY, hour)
                    set(Calendar.MINUTE, minute)
                }
                dateTime = calendar.time
                showTimePicker = false
            }
        )
    }

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
        LazyColumn(
            modifier = Modifier
                .fillMaxSize()
                .padding(padding)
                .padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            // Image Picker
            item {
                Card(
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(200.dp)
                        .clickable { imagePickerLauncher.launch("image/*") }
                ) {
                    Box(
                        modifier = Modifier.fillMaxSize(),
                        contentAlignment = Alignment.Center
                    ) {
                        if (selectedImageUri != null) {
                            AsyncImage(
                                model = selectedImageUri,
                                contentDescription = "Selected event banner",
                                modifier = Modifier.fillMaxSize(),
                                contentScale = ContentScale.Crop
                            )
                        } else {
                            Column(
                                horizontalAlignment = Alignment.CenterHorizontally,
                                verticalArrangement = Arrangement.Center
                            ) {
                                Icon(
                                    imageVector = Icons.Default.AddPhotoAlternate,
                                    contentDescription = "Add photo",
                                    modifier = Modifier.size(48.dp)
                                )
                                Spacer(modifier = Modifier.height(8.dp))
                                Text("Add Event Banner")
                            }
                        }
                    }
                }
            }

            // Basic Information
            item {
                OutlinedTextField(
                    value = title,
                    onValueChange = { title = it },
                    label = { Text("Event Title") },
                    modifier = Modifier.fillMaxWidth(),
                    singleLine = true
                )
            }

            item {
                DropdownField(
                    value = sport,
                    onValueChange = { sport = it },
                    label = "Sport",
                    options = EventConstants.SPORTS
                )
            }

            item {
                OutlinedTextField(
                    value = location,
                    onValueChange = { location = it },
                    label = { Text("Location") },
                    modifier = Modifier.fillMaxWidth(),
                    singleLine = true
                )
            }

            item {
                DateTimePickerField(
                    value = SimpleDateFormat("dd/MM/yyyy HH:mm", Locale.getDefault())
                        .format(dateTime),
                    onClick = { showDatePicker = true },
                    label = "Date & Time"
                )
            }

            // Event Details
            item {
                DropdownField(
                    value = skillLevel,
                    onValueChange = { skillLevel = it },
                    label = "Skill Level",
                    options = EventConstants.SKILL_LEVELS
                )
            }

            item {
                OutlinedTextField(
                    value = participantLimit,
                    onValueChange = { participantLimit = it.filter { it.isDigit() } },
                    label = { Text("Participant Limit") },
                    modifier = Modifier.fillMaxWidth(),
                    keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
                    singleLine = true
                )
            }

            // Additional Details
            item {
                DropdownField(
                    value = eventType,
                    onValueChange = { eventType = it },
                    label = "Event Type",
                    options = EventConstants.EVENT_TYPES
                )
            }

            item {
                OutlinedTextField(
                    value = entryFee,
                    onValueChange = { if (it.isEmpty() || it.matches(Regex("^\\d*\\.?\\d*$"))) entryFee = it },
                    label = { Text("Entry Fee") },
                    modifier = Modifier.fillMaxWidth(),
                    keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Decimal),
                    leadingIcon = { Text("$", modifier = Modifier.padding(start = 8.dp)) },
                    singleLine = true
                )
            }

            // Equipment and Requirements
            item {
                DropdownField(
                    value = equipmentProvided,
                    onValueChange = { equipmentProvided = it },
                    label = "Equipment Provided",
                    options = EventConstants.EQUIPMENT_OPTIONS
                )
            }

            item {
                MultiSelectDropdown(
                    selected = specialRequirements,
                    options = EventConstants.SPECIAL_REQUIREMENTS,
                    onSelectionChanged = { specialRequirements = it },
                    label = "Special Requirements"
                )
            }

            // Event Settings
            item {
                DropdownField(
                    value = ageGroup,
                    onValueChange = { ageGroup = it },
                    label = "Age Group",
                    options = EventConstants.AGE_GROUPS
                )
            }

            item {
                DropdownField(
                    value = duration,
                    onValueChange = { duration = it },
                    label = "Duration",
                    options = EventConstants.DURATIONS
                )
            }

            item {
                DropdownField(
                    value = genderRestriction,
                    onValueChange = { genderRestriction = it },
                    label = "Gender Restriction",
                    options = EventConstants.GENDER_RESTRICTIONS
                )
            }

            item {
                DropdownField(
                    value = weatherBackupPlan,
                    onValueChange = { weatherBackupPlan = it },
                    label = "Weather Backup Plan",
                    options = EventConstants.WEATHER_BACKUP_PLANS
                )
            }

            // Description and Notes
            item {
                OutlinedTextField(
                    value = description,
                    onValueChange = { description = it },
                    label = { Text("Description") },
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(120.dp),
                    maxLines = 5
                )
            }

            item {
                OutlinedTextField(
                    value = additionalNotes,
                    onValueChange = { additionalNotes = it },
                    label = { Text("Additional Notes") },
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(80.dp),
                    maxLines = 3
                )
            }

            // Create Button
            item {
                Button(
                    onClick = {
                        scope.launch {
                            val imageUrl = selectedImageUri?.let { uri ->
                                ImageUploader.uploadEventImage(context, uri).getOrNull()
                            } ?: ""

                            val event = Event(
                                title = title,
                                bannerImageUrl = imageUrl,
                                sport = sport,
                                location = location,
                                dateTime = Timestamp(dateTime),
                                skillLevel = skillLevel,
                                participantLimit = participantLimit.toIntOrNull() ?: 0,
                                description = description,
                                eventType = eventType,
                                entryFee = entryFee.toDoubleOrNull() ?: 0.0,
                                equipmentProvided = equipmentProvided,
                                ageGroup = ageGroup,
                                duration = duration,
                                genderRestriction = genderRestriction,
                                weatherBackupPlan = weatherBackupPlan,
                                specialRequirements = specialRequirements.toList(),
                                additionalNotes = additionalNotes
                            )
                            eventViewModel.createEvent(event)
                            navController.navigateUp()
                        }
                    },
                    modifier = Modifier.fillMaxWidth(),
                    enabled = title.isNotBlank() && sport.isNotBlank() && location.isNotBlank()
                ) {
                    Text("Create Event")
                }
            }

            item { Spacer(modifier = Modifier.height(32.dp)) }
        }
    }
}

@Composable
private fun DateTimePicker(
    dateTime: Date,
    onDateTimeSelected: (Date) -> Unit
) {
    // Implementation of date/time picker
    // This would use Material3 DatePicker and TimePicker
}

@Composable
private fun MultiSelectDropdown(
    selected: Set<String>,
    options: List<String>,
    onSelectionChanged: (Set<String>) -> Unit,
    label: String
) {
    // Implementation of multi-select dropdown
} 