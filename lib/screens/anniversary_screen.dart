import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:myapp/l10n/app_localizations.dart';
import 'package:myapp/services/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/milestone.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';
import 'anniversary_detail_screen.dart';
import 'settings_screen.dart';

class AnniversaryScreen extends StatefulWidget {
  final String userId;
  const AnniversaryScreen({super.key, required this.userId});

  @override
  State<AnniversaryScreen> createState() => _AnniversaryScreenState();
}

class _AnniversaryScreenState extends State<AnniversaryScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final StorageService _storageService = StorageService();
  final NotificationService _notificationService = NotificationService();
  final TextEditingController _titleController = TextEditingController();
  DateTime? _selectedDate;
  File? _image;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  void _presentDatePicker() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
    ).then((pickedDate) {
      if (pickedDate == null) {
        return;
      }
      setState(() {
        _selectedDate = pickedDate;
      });
    });
  }

  Future<void> _addAnniversary() async {
    final navigator = Navigator.of(context);
    final title = _titleController.text;
    if (title.isEmpty || _selectedDate == null) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      String? imageUrl;
      if (_image != null) {
        imageUrl = await _storageService.uploadImage(_image!);
      }

      final docRef = await _firestoreService.addMilestone(
        title,
        _selectedDate!,
        imageUrl: imageUrl,
      );

      final newMilestone = Milestone(
        id: docRef.id,
        title: title,
        date: _selectedDate!,
        imageUrl: imageUrl,
        userId: widget.userId,
      );
      await _scheduleNotification(newMilestone);

      _titleController.clear();
      setState(() {
        _selectedDate = null;
        _image = null;
      });
      navigator.pop(); // Close the drawer
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _scheduleNotification(Milestone milestone) async {
    final prefs = await SharedPreferences.getInstance();
    final notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;

    if (!notificationsEnabled) {
      return;
    }

    final timingDays = prefs.getInt('notificationTimingDays') ?? 0;
    final timeHour = prefs.getInt('notificationTimeHour') ?? 9;
    final timeMinute = prefs.getInt('notificationTimeMinute') ?? 0;

    final now = DateTime.now();
    DateTime notificationDate = DateTime(
      milestone.date.year,
      milestone.date.month,
      milestone.date.day,
      timeHour,
      timeMinute,
    );

    if (notificationDate.isBefore(now)) {
      notificationDate = DateTime(
        now.year + 1,
        milestone.date.month,
        milestone.date.day,
        timeHour,
        timeMinute,
      );
    }

    final scheduledDate = notificationDate.subtract(Duration(days: timingDays));

    if (scheduledDate.isAfter(now)) {
      await _notificationService.scheduleNotification(
        id: milestone.id.hashCode,
        title: 'Upcoming Anniversary!',
        body:
            'Don\'t forget! ${milestone.title} is on ${DateFormat.yMd().format(milestone.date)}.',
        scheduledDate: scheduledDate,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const SettingsScreen()),
            );
          },
        ),
        title: Text(l10n.anniversaryList),
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                Scaffold.of(context).openEndDrawer();
              },
            ),
          ),
        ],
      ),
      endDrawer: Drawer(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              const SizedBox(height: 40),
              TextField(
                controller: _titleController,
                decoration: InputDecoration(labelText: l10n.anniversaryName),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _selectedDate == null
                          ? l10n.noDateChosen
                          : '${l10n.pickedDatePrefix} ${DateFormat.yMd().format(_selectedDate!)}',
                    ),
                  ),
                  TextButton(
                    onPressed: _presentDatePicker,
                    child: Text(
                      l10n.chooseDate,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _image == null
                  ? TextButton.icon(
                      icon: const Icon(Icons.image),
                      label: Text(l10n.pickImage),
                      onPressed: _pickImage,
                    )
                  : Column(
                      children: [
                        Image.file(_image!, height: 250, fit: BoxFit.contain),
                        TextButton.icon(
                          icon: const Icon(Icons.refresh),
                          label: Text(l10n.changeImage),
                          onPressed: _pickImage,
                        ),
                      ],
                    ),
              const Spacer(),
              ElevatedButton(
                onPressed: _addAnniversary,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(l10n.addAnniversary),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          StreamBuilder<QuerySnapshot>(
            stream: _firestoreService.getMilestonesStream(widget.userId),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Text('${l10n.errorPrefix} ${snapshot.error}'),
                );
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final milestones = snapshot.data!.docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return Milestone.fromJson(data).copyWith(id: doc.id);
              }).toList();

              if (milestones.isEmpty) {
                return Center(
                  child: Text(
                    l10n.noAnniversariesPrompt,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(8.0),
                itemCount: milestones.length,
                itemBuilder: (context, index) {
                  final milestone = milestones[index];
                  final daysPassed = DateTime.now()
                      .difference(milestone.date)
                      .inDays;

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      leading:
                          (milestone.imageUrl != null &&
                              milestone.imageUrl!.isNotEmpty)
                          ? Image.network(
                              milestone.imageUrl!,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            )
                          : null,
                      title: Text(
                        milestone.title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        '${l10n.daysPassed} $daysPassed ${l10n.days}',
                      ),
                      onTap: () {
                        Navigator.of(context)
                            .push(
                              MaterialPageRoute(
                                builder: (context) => AnniversaryDetailScreen(
                                  milestone: milestone,
                                ),
                              ),
                            )
                            .then((_) {
                              _scheduleNotification(milestone);
                            });
                      },
                    ),
                  );
                },
              );
            },
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
