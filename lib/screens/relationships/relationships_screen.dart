import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interquatier/models/relationship_badge.dart';
import 'package:interquatier/providers/relationship_provider.dart';
import 'package:interquatier/providers/auth_provider.dart';
import 'package:interquatier/widgets/relationships/relationship_list_item.dart';
import 'package:interquatier/widgets/relationships/add_relationship_form.dart';
import 'package:interquatier/providers/user_provider.dart';
import 'package:interquatier/models/relationship.dart';

class RelationshipsScreen extends ConsumerWidget {
  const RelationshipsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);
    if (user == null) return const SizedBox();

    final relationshipsAsync = ref.watch(userRelationshipsProvider(user.uid));

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Relationships'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'All'),
              Tab(text: 'Pending'),
              Tab(text: 'Confirmed'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.person_add),
              onPressed: () => _showAddRelationship(context, ref),
            ),
          ],
        ),
        body: relationshipsAsync.when(
          data: (relationships) => TabBarView(
            children: [
              _RelationshipList(
                relationships: relationships,
                filter: (badge) => true,
              ),
              _RelationshipList(
                relationships: relationships,
                filter: (badge) => badge.status == BadgeStatus.pending,
              ),
              _RelationshipList(
                relationships: relationships,
                filter: (badge) => badge.status == BadgeStatus.accepted,
              ),
            ],
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Text('Error: $error'),
          ),
        ),
      ),
    );
  }

  void _showAddRelationship(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: const AddRelationshipForm(),
      ),
    );
  }
}

class _RelationshipList extends ConsumerWidget {
  final List<RelationshipBadge> relationships;
  final bool Function(RelationshipBadge) filter;

  const _RelationshipList({
    required this.relationships,
    required this.filter,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);
    if (user == null) return const SizedBox();

    final filteredRelationships = relationships.where(filter).toList();

    if (filteredRelationships.isEmpty) {
      return const Center(
        child: Text('No relationships found'),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: filteredRelationships.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        final badge = filteredRelationships[index];
        return RelationshipListItem(
          relationship: Relationship(
            id: badge.id,
            user: ref.watch(userProfileProvider(badge.toUserId)).value!,
            badge: badge,
            isReceiver: badge.toUserId == user.uid,
          ),
        );
      },
    );
  }
} 