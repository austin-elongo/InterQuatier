package com.example.interquatier.admin.model

data class AdminStats(
    val totalEvents: Int,
    val activeEvents: Int,
    val totalParticipants: Int,
    val eventsByType: Map<String, Int>,
    val eventsBySport: Map<String, Int>
) 