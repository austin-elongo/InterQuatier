package com.example.interquatier.viewmodel

import android.app.Application
import android.util.Log
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import com.google.firebase.auth.FirebaseAuth
import com.google.firebase.firestore.FirebaseFirestore
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch
import com.example.interquatier.model.User

class AuthViewModel(application: Application) : AndroidViewModel(application) {
    private val auth = FirebaseAuth.getInstance()
    private val firestore = FirebaseFirestore.getInstance()
    
    private val _authState = MutableStateFlow<AuthState>(AuthState.Initial)
    val authState: StateFlow<AuthState> = _authState

    fun register(email: String, password: String, name: String, age: String) {
        viewModelScope.launch {
            try {
                _authState.value = AuthState.Loading
                Log.d("AuthViewModel", "Starting registration for email: $email")
                
                // Create user with email and password
                auth.createUserWithEmailAndPassword(email, password)
                    .addOnSuccessListener { result ->
                        Log.d("AuthViewModel", "User created successfully in Auth")
                        // Create user profile in Firestore
                        result.user?.let { firebaseUser ->
                            val user = User(
                                uid = firebaseUser.uid,
                                email = email,
                                name = name,
                                age = age
                            )
                            
                            Log.d("AuthViewModel", "Saving user data to Firestore")
                            firestore.collection("users")
                                .document(firebaseUser.uid)
                                .set(user)
                                .addOnSuccessListener {
                                    Log.d("AuthViewModel", "User data saved successfully")
                                    _authState.value = AuthState.Success
                                }
                                .addOnFailureListener { e ->
                                    Log.e("AuthViewModel", "Failed to save user data", e)
                                    _authState.value = AuthState.Error(e.message ?: "Failed to save user data")
                                }
                        } ?: run {
                            Log.e("AuthViewModel", "Firebase user is null after successful registration")
                            _authState.value = AuthState.Error("Failed to create user profile")
                        }
                    }
                    .addOnFailureListener { e ->
                        Log.e("AuthViewModel", "Registration failed", e)
                        _authState.value = AuthState.Error(e.message ?: "Registration failed")
                    }
            } catch (e: Exception) {
                Log.e("AuthViewModel", "Unexpected error during registration", e)
                _authState.value = AuthState.Error(e.message ?: "Registration failed")
            }
        }
    }

    fun login(email: String, password: String) {
        viewModelScope.launch {
            try {
                _authState.value = AuthState.Loading
                auth.signInWithEmailAndPassword(email, password)
                    .addOnSuccessListener {
                        _authState.value = AuthState.Success
                    }
                    .addOnFailureListener { e ->
                        _authState.value = AuthState.Error(e.message ?: "Login failed")
                    }
            } catch (e: Exception) {
                _authState.value = AuthState.Error(e.message ?: "Login failed")
            }
        }
    }

    fun logout() {
        auth.signOut()
        _authState.value = AuthState.Initial
    }

    fun isLoggedIn() = auth.currentUser != null

    fun resetState() {
        _authState.value = AuthState.Initial
    }
}

sealed class AuthState {
    object Initial : AuthState()
    object Loading : AuthState()
    object Success : AuthState()
    data class Error(val message: String) : AuthState()
} 