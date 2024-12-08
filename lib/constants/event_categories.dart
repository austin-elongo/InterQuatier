import 'package:flutter/material.dart';

class EventCategory {
  final String title;
  final IconData icon;
  final String route;

  const EventCategory({
    required this.title,
    required this.icon,
    required this.route,
  });
}

final List<EventCategory> eventCategories = [
  EventCategory(
    title: 'Football',
    icon: Icons.sports_soccer_rounded,
    route: 'football',
  ),
  EventCategory(
    title: 'Basketball',
    icon: Icons.sports_basketball_rounded,
    route: 'basketball',
  ),
  EventCategory(
    title: 'Tennis',
    icon: Icons.sports_tennis_rounded,
    route: 'tennis',
  ),
  EventCategory(
    title: 'Volleyball',
    icon: Icons.sports_volleyball_rounded,
    route: 'volleyball',
  ),
  EventCategory(
    title: 'Rugby',
    icon: Icons.sports_rugby_rounded,
    route: 'rugby',
  ),
  EventCategory(
    title: 'Other Sports',
    icon: Icons.sports_rounded,
    route: 'other',
  ),
]; 