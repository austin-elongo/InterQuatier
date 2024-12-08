import 'package:go_router/go_router.dart';
import 'package:interquatier/models/event.dart';
import 'package:interquatier/screens/events/event_details_screen.dart';
import 'package:interquatier/screens/events/events_menu_screen.dart';
import 'package:interquatier/screens/common/coming_soon_screen.dart';
import 'package:interquatier/screens/main_screen.dart';
import 'package:interquatier/screens/events/create_event_screen.dart';
import 'package:interquatier/screens/auth/register_screen.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const MainScreen(),
      routes: [
        GoRoute(
          path: 'events',
          builder: (context, state) => const EventsMenuScreen(),
        ),
        GoRoute(
          path: 'chat',
          builder: (context, state) => const ComingSoonScreen(
            title: 'Chat',
            message: 'Chat feature coming soon!',
          ),
        ),
        GoRoute(
          path: 'profile',
          builder: (context, state) => const ComingSoonScreen(
            title: 'Profile',
            message: 'Profile feature coming soon!',
          ),
        ),
      ],
    ),
    GoRoute(
      path: '/create-event',
      builder: (context, state) => const CreateEventScreen(),
    ),
    GoRoute(
      path: '/events/:category',
      builder: (context, state) => ComingSoonScreen(
        title: '${state.pathParameters['category']} Events',
        message: '${state.pathParameters['category']} events coming soon!',
      ),
    ),
    GoRoute(
      path: '/event/:id',
      builder: (context, state) {
        final event = state.extra as Event;
        return EventDetailsScreen(event: event);
      },
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
  ],
); 