@RestController
@RequestMapping("/api/admin")
class AdminController(
    private val eventService: EventService,
    private val userService: UserService
) {
    @GetMapping("/events")
    fun getAllEvents(): List<Event> = eventService.getAllEvents()

    @GetMapping("/events/{id}")
    fun getEvent(@PathVariable id: String): Event = eventService.getEvent(id)

    @PutMapping("/events/{id}")
    fun updateEvent(@PathVariable id: String, @RequestBody event: Event): Event =
        eventService.updateEvent(id, event)

    @DeleteMapping("/events/{id}")
    fun deleteEvent(@PathVariable id: String) = eventService.deleteEvent(id)

    @GetMapping("/users")
    fun getAllUsers(): List<User> = userService.getAllUsers()

    @GetMapping("/stats")
    fun getStats(): AdminStats = eventService.getStats()
} 