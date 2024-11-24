package com.example.interquatier.model

import com.google.firebase.Timestamp

data class Event(
    val id: String = "",
    val creatorId: String = "",
    val title: String = "",
    val sport: String = "",
    val location: String = "",
    val dateTime: Timestamp = Timestamp.now(),
    val skillLevel: String = "",
    val participantLimit: Int = 0,
    val currentParticipants: List<String> = listOf(),
    val description: String = "",
    val status: String = "ACTIVE",
    val createdAt: Timestamp = Timestamp.now()
) 