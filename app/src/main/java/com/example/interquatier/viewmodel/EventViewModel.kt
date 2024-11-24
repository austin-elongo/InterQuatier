package com.example.interquatier.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.example.interquatier.model.Event
import com.example.interquatier.repository.EventRepository
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch

sealed class EventState {
    object Loading : EventState()
    data class Success(val events: List<Event>) : EventState()
    data class Error(val message: String) : EventState()
}

class EventViewModel : ViewModel() {
    private val repository = EventRepository()
    private val _eventState = MutableStateFlow<EventState>(EventState.Loading)
    val eventState: StateFlow<EventState> = _eventState

    init {
        loadEvents()
    }

    fun loadEvents() {
        viewModelScope.launch {
            _eventState.value = EventState.Loading
            repository.getEvents()
                .onSuccess { events ->
                    _eventState.value = EventState.Success(events)
                }
                .onFailure { exception ->
                    _eventState.value = EventState.Error(exception.message ?: "Failed to load events")
                }
        }
    }

    fun createEvent(event: Event) {
        viewModelScope.launch {
            repository.createEvent(event)
                .onSuccess { 
                    loadEvents() // Reload events after creation
                }
                .onFailure { exception ->
                    _eventState.value = EventState.Error(exception.message ?: "Failed to create event")
                }
        }
    }
} 