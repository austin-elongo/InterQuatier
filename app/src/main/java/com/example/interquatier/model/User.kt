package com.example.interquatier.model

data class User(
    val uid: String = "",
    val email: String = "",
    val name: String = "",
    val age: String = "",
    val createdAt: Long = System.currentTimeMillis()
) 