package com.example.interquatier.admin.service

import com.example.interquatier.model.Event
import com.google.firebase.firestore.FirebaseFirestore
import org.springframework.stereotype.Service
import kotlinx.coroutines.tasks.await
import org.springframework.cache.annotation.Cacheable
import org.springframework.cache.annotation.CacheEvict

interface EventService {
    suspend fun getAllEvents(): List<Event>
    suspend fun getEvent(id: String): Event
    suspend fun updateEvent(id: String, event: Event): Event
    suspend fun deleteEvent(id: String)
    suspend fun getStats(): AdminStats
}

@Service
class EventServiceImpl(
    private val firestore: FirebaseFirestore
) : EventService {
    
    @Cacheable("events")
    override suspend fun getAllEvents(): List<Event> {
        return firestore.collection("events")
            .get()
            .await()
            .toObjects(Event::class.java)
    }

    @Cacheable("events", key = "#id")
    override suspend fun getEvent(id: String): Event {
        return firestore.collection("events")
            .document(id)
            .get()
            .await()
            .toObject(Event::class.java)
            ?: throw NotFoundException("Event not found")
    }

    @CacheEvict("events", allEntries = true)
    override suspend fun updateEvent(id: String, event: Event): Event {
        val updatedEvent = event.copy(id = id)
        firestore.collection("events")
            .document(id)
            .set(updatedEvent)
            .await()
        return updatedEvent
    }

    @CacheEvict("events", allEntries = true)
    override suspend fun deleteEvent(id: String) {
        firestore.collection("events")
            .document(id)
            .delete()
            .await()
    }

    override suspend fun getStats(): AdminStats {
        val events = getAllEvents()
        return AdminStats(
            totalEvents = events.size,
            activeEvents = events.count { it.status == "ACTIVE" },
            totalParticipants = events.sumOf { it.currentParticipants.size },
            eventsByType = events.groupBy { it.eventType }
                .mapValues { it.value.size },
            eventsBySport = events.groupBy { it.sport }
                .mapValues { it.value.size }
        )
    }
} 