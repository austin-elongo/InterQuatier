package com.example.interquatier.model

import com.google.firebase.Timestamp

data class AudioReview(
    val id: String = "",
    val eventId: String = "",
    val userId: String = "",
    val audioUrl: String = "",
    val createdAt: Timestamp = Timestamp.now(),
    val expiresAt: Timestamp? = null,
    val isPermanent: Boolean = false
) 