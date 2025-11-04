import 'package:flutter/material.dart';
import 'package:myapp/l10n/app_localizations.dart';
import '../models/milestone.dart';
import 'edit_anniversary_screen.dart';

class AnniversaryDetailScreen extends StatelessWidget {
  final Milestone milestone;

  const AnniversaryDetailScreen({super.key, required this.milestone});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final daysPassed = DateTime.now().difference(milestone.date).inDays;

    return Scaffold(
      appBar: AppBar(
        title: Text(milestone.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: localizations.editAnniversary,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) =>
                      EditAnniversaryScreen(milestone: milestone),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (milestone.imageUrl != null && milestone.imageUrl!.isNotEmpty)
              Image.network(
                milestone.imageUrl!,
                height: 250,
                fit: BoxFit.contain,
              ),
            const SizedBox(height: 20),
            Text(
              milestone.title,
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Text(
              '${localizations.date}: ${milestone.date.toLocal().toString().split(' ')[0]}',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Text(
              '${localizations.daysPassed} $daysPassed ${localizations.days}',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
