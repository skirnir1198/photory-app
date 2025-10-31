import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:myapp/models/milestone.dart';
import 'package:myapp/services/firestore_service.dart';
import 'package:myapp/services/storage_service.dart';
import 'package:provider/provider.dart';

class AddEditScreen extends StatefulWidget {
  final Milestone? milestone;

  const AddEditScreen({super.key, this.milestone});

  @override
  State<AddEditScreen> createState() => _AddEditScreenState();
}

class _AddEditScreenState extends State<AddEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  late DateTime _date;
  XFile? _image;
  String? _imageUrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _title = widget.milestone?.title ?? '';
    _date = widget.milestone?.date ?? DateTime.now();
    _imageUrl = widget.milestone?.imageUrl;
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = image;
    });
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isLoading = true;
      });

      try {
        String? imageUrl = _imageUrl;
        if (_image != null) {
          final storageService = Provider.of<StorageService>(context, listen: false);
          imageUrl = await storageService.uploadImage(_image!);
        }

        if (imageUrl != null) {
          final firestoreService = Provider.of<FirestoreService>(context, listen: false);
          final milestone = Milestone(
            id: widget.milestone?.id,
            title: _title,
            date: _date,
            imageUrl: imageUrl,
          );

          if (widget.milestone == null) {
            await firestoreService.addMilestone(milestone);
          } else {
            await firestoreService.updateMilestone(milestone);
          }

          if (mounted) {
            Navigator.pop(context);
          }
        } else {
          // Handle image upload error
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to upload image.')),
            );
          }
        }
      } catch (e) {
        // Handle other errors
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('An error occurred: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.milestone == null ? 'Add Memory' : 'Edit Memory'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: _image != null
                            ? Image.file(File(_image!.path), fit: BoxFit.cover)
                            : _imageUrl != null
                                ? Image.network(_imageUrl!, fit: BoxFit.cover)
                                : const Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.add_a_photo, size: 50),
                                        SizedBox(height: 8),
                                        Text('Tap to select a photo'),
                                      ],
                                    ),
                                  ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: _title,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        hintText: "What's this milestone?",
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                      onSaved: (value) => _title = value!,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Date: ${_date.toLocal()} '.split(' ')[0],
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            final pickedDate = await showDatePicker(
                              context: context,
                              initialDate: _date,
                              firstDate: DateTime(1900),
                              lastDate: DateTime.now(),
                            );
                            if (pickedDate != null) {
                              setState(() {
                                _date = pickedDate;
                              });
                            }
                          },
                          child: const Text('Change'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _save,
                      child: const Text('Save'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
