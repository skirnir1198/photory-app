import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:myapp/l10n/app_localizations.dart';
import 'package:myapp/services/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/milestone.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';

class EditAnniversaryScreen extends StatefulWidget {
  final Milestone milestone;

  const EditAnniversaryScreen({super.key, required this.milestone});

  @override
  State<EditAnniversaryScreen> createState() => _EditAnniversaryScreenState();
}

class _EditAnniversaryScreenState extends State<EditAnniversaryScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final StorageService _storageService = StorageService();
  final NotificationService _notificationService = NotificationService();

  late TextEditingController _titleController;
  late DateTime _selectedDate;
  File? _image;
  String? _imageUrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.milestone.title);
    _selectedDate = widget.milestone.date;
    _imageUrl = widget.milestone.imageUrl;
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _imageUrl = null; // Clear existing image url when new image is picked
      });
    }
  }

  Future<void> _removeImage() async {
    setState(() {
      _image = null;
      _imageUrl = null;
    });
  }

  Future<void> _updateAnniversary() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final l10n = AppLocalizations.of(context)!;

    if (_titleController.text.isEmpty) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Title cannot be empty.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final String? oldImageUrl = widget.milestone.imageUrl;
      String? newImageUrl = oldImageUrl;
      bool imageChanged = false;

      // Case 1: A new image was selected.
      if (_image != null) {
        newImageUrl = await _storageService.uploadImage(_image!);
        // After successful upload, delete the old image if it existed.
        if (oldImageUrl != null && oldImageUrl.isNotEmpty) {
          await _storageService.deleteImage(oldImageUrl);
        }
        imageChanged = true;
      }
      // Case 2: The existing image was removed, and no new image was selected.
      else if (_imageUrl == null &&
          oldImageUrl != null &&
          oldImageUrl.isNotEmpty) {
        newImageUrl = null;
        await _storageService.deleteImage(oldImageUrl);
        imageChanged = true;
      }

      // Create a map of the fields to update.
      final Map<String, dynamic> updates = {
        'title': _titleController.text,
        'date': _selectedDate,
      };
      if (imageChanged) {
        updates['imageUrl'] = newImageUrl;
      }

      await _firestoreService.updateMilestoneData(widget.milestone.id, updates);
      final updatedMilestone = await _firestoreService.getMilestone(
        widget.milestone.id,
      );
      if (updatedMilestone == null) return; // Or handle error
      await _scheduleNotification(updatedMilestone);

      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text(l10n.imageUpdated)),
      );

      int count = 0;
      navigator.popUntil((_) => count++ >= 2);
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Failed to update: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteAnniversary() async {
    final localizations = AppLocalizations.of(context)!;
    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    final bool? confirmed = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations.confirmDeleteTitle),
        content: Text(localizations.confirmDeleteContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(localizations.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(localizations.delete),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        setState(() {
          _isLoading = true;
        });

        if (widget.milestone.imageUrl != null) {
          await _storageService.deleteImage(widget.milestone.imageUrl!);
        }
        await _notificationService.cancelNotification(
          widget.milestone.id.hashCode,
        );
        await _firestoreService.deleteMilestone(widget.milestone.id);

        scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Anniversary deleted.')),
        );

        int count = 0;
        navigator.popUntil((_) => count++ >= 2);
      } catch (e) {
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Failed to delete: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _scheduleNotification(Milestone milestone) async {
    final prefs = await SharedPreferences.getInstance();
    final notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;

    if (!notificationsEnabled) {
      await _notificationService.cancelNotification(milestone.id.hashCode);
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
        title: 'Upcoming Anniversary!', // Localize this
        body:
            'Don\'t forget! ${milestone.title} is on ${DateFormat.yMd().format(milestone.date)}.', // Localize this
        scheduledDate: scheduledDate,
      );
    }
  }

  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.editAnniversary),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: l10n.deleteAnniversaryTooltip,
            onPressed: _deleteAnniversary,
          ),
        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: l10n.anniversaryName,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${l10n.date}: ${DateFormat.yMd().format(_selectedDate)}',
                        ),
                      ),
                      TextButton(
                        onPressed: () => _pickDate(context),
                        child: Text(l10n.chooseDate),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _image !=
                          null // New image picked
                      ? Image.file(_image!, height: 250, fit: BoxFit.contain)
                      : (_imageUrl != null &&
                            _imageUrl!
                                .isNotEmpty) // Existing image from network
                      ? Image.network(
                          _imageUrl!,
                          height: 250,
                          fit: BoxFit.contain,
                        )
                      : Text(l10n.noImageSelected), // No image
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton.icon(
                        icon: const Icon(Icons.image),
                        label: Text(l10n.changeImage),
                        onPressed: _pickImage,
                      ),
                      if (_image != null ||
                          (_imageUrl != null && _imageUrl!.isNotEmpty))
                        TextButton.icon(
                          icon: const Icon(Icons.delete_forever),
                          label: Text(l10n.removeImage),
                          onPressed: _removeImage,
                        ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: _updateAnniversary,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: Text(l10n.save),
                  ),
                ],
              ),
            ),
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
