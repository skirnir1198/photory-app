import 'package:flutter/material.dart';
import 'package:myapp/models/milestone.dart';
import 'package:myapp/screens/add_edit_screen.dart';
import 'package:myapp/services/auth_service.dart';
import 'package:myapp/services/firestore_service.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final firestoreService = FirestoreService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Memories'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => authService.signOut(),
          ),
        ],
      ),
      body: StreamProvider<List<Milestone>>.value(
        value: firestoreService.getMilestones(),
        initialData: const [],
        child: Consumer<List<Milestone>>(
          builder: (context, milestones, child) {
            if (milestones.isEmpty) {
              return const Center(
                child: Text('No memories yet. Add one!'),
              );
            }
            return ListView.builder(
              itemCount: milestones.length,
              itemBuilder: (context, index) {
                return MilestoneCard(milestone: milestones[index]);
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => const AddEditScreen()));
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class MilestoneCard extends StatelessWidget {
  final Milestone milestone;

  const MilestoneCard({super.key, required this.milestone});

  @override
  Widget build(BuildContext context) {
    final days = DateTime.now().difference(milestone.date).inDays;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Image.network(
            milestone.imageUrl,
            fit: BoxFit.cover,
            width: double.infinity,
            height: 200,
          ),
          Container(
            height: 200,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black54, Colors.transparent],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$days Days',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  milestone.title,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
