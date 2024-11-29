package com.example.interquatier.model

import com.google.firebase.Timestamp

data class Event(
    val id: String = "",
    val creatorId: String = "",
    val title: String = "",
    val bannerImageUrl: String = "",
    val sport: String = "",
    val location: String = "",
    val dateTime: Timestamp = Timestamp.now(),
    val skillLevel: String = "",
    val participantLimit: Int = 0,
    val currentParticipants: List<String> = listOf(),
    val description: String = "",
    val status: String = "ACTIVE",
    val createdAt: Timestamp = Timestamp.now(),
    val eventType: String = "",
    val entryFee: Double = 0.0,
    val equipmentProvided: String = "",
    val ageGroup: String = "",
    val duration: String = "",
    val genderRestriction: String = "",
    val weatherBackupPlan: String = "",
    val specialRequirements: List<String> = listOf(),
    val venueType: String = "",
    val additionalNotes: String = ""
) 