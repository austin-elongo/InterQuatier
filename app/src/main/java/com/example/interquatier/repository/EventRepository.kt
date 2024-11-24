package com.example.interquatier.repository

import com.google.firebase.firestore.FirebaseFirestore
import com.google.firebase.storage.FirebaseStorage
import com.example.interquatier.model.Event
import kotlinx.coroutines.tasks.await
import java.util.UUID

class EventRepository {
    private val firestore = FirebaseFirestore.getInstance()
    private val storage = FirebaseStorage.getInstance()
    private val eventsCollection = firestore.collection("events")

    suspend fun createEvent(event: Event): Result<Event> {
        return try {
            val eventId = UUID.randomUUID().toString()
            val newEvent = event.copy(id = eventId)
            eventsCollection.document(eventId).set(newEvent).await()
            Result.success(newEvent)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun getEvents(): Result<List<Event>> {
        return try {
            val snapshot = eventsCollection
                .orderBy("dateTime")
                .get()
                .await()
            Result.success(snapshot.toObjects(Event::class.java))
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun joinEvent(eventId: String, userId: String): Result<Unit> {
        return try {
            eventsCollection.document(eventId).update(
                "currentParticipants", com.google.firebase.firestore.FieldValue.arrayUnion(userId)
            ).await()
            Result.success(Unit)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }
} 