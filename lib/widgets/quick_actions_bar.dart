import 'package:flutter/material.dart';

class QuickActionsBar extends StatelessWidget {
  const QuickActionsBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildActionChip(
              context,
              label: 'Nearby',
              icon: Icons.location_on,
              onTap: () {},
            ),
            const SizedBox(width: 8),
            _buildActionChip(
              context,
              label: 'Today',
              icon: Icons.calendar_today,
              onTap: () {},
            ),
            const SizedBox(width: 8),
            _buildActionChip(
              context,
              label: 'Popular',
              icon: Icons.trending_up,
              onTap: () {},
            ),
            const SizedBox(width: 8),
            _buildActionChip(
              context,
              label: 'Free',
              icon: Icons.euro,
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionChip(
    BuildContext context, {
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ActionChip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      onPressed: onTap,
    );
  }
} 