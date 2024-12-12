import 'package:go_router/go_router.dart';
import 'package:interquatier/models/event.dart';
import 'package:interquatier/screens/events/event_details_screen.dart';
import 'package:interquatier/screens/events/events_menu_screen.dart';
import 'package:interquatier/screens/common/coming_soon_screen.dart';
import 'package:interquatier/screens/main_screen.dart';
import 'package:interquatier/screens/events/create_event_screen.dart';
import 'package:interquatier/screens/auth/register_screen.dart';
import 'package:interquatier/screens/events/category_events_screen.dart';
import 'package:interquatier/screens/rentals/rentals_menu_screen.dart';
import 'package:interquatier/screens/rentals/rental_items_screen.dart';
import 'package:interquatier/models/rental_item.dart';
import 'package:interquatier/screens/rentals/rental_details_screen.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const MainScreen(),
      routes: [
        GoRoute(
          path: 'events',
          builder: (context, state) => EventsMenuScreen(),
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
      builder: (context, state) => CategoryEventsScreen(
        category: state.pathParameters['category']!,
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
    GoRoute(
      path: '/rentals',
      builder: (context, state) => const RentalsMenuScreen(),
    ),
    GoRoute(
      path: '/rentals/:category',
      builder: (context, state) {
        final category = RentalCategory.values.firstWhere(
          (c) => c.toString().split('.').last == state.pathParameters['category'],
          orElse: () => RentalCategory.other,
        );
        return RentalItemsScreen(category: category);
      },
    ),
    GoRoute(
      path: '/rental/:id',
      builder: (context, state) {
        final item = state.extra as RentalItem;
        return RentalDetailsScreen(item: item);
      },
    ),
  ],
); 