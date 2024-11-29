package com.example.interquatier.admin.exception

class NotFoundException(message: String) : RuntimeException(message)
class UnauthorizedException(message: String) : RuntimeException(message)
class ValidationException(message: String) : RuntimeException(message) 