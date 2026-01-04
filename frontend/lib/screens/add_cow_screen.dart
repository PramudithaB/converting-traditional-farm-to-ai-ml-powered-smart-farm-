import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../db/app_db.dart';

class AddCowScreen extends StatefulWidget {
  static const routeName = '/add-cow';
  const AddCowScreen({super.key});

  @override
  State<AddCowScreen> createState() => _AddCowScreenState();
}

class _AddCowScreenState extends State<AddCowScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cowIdCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _breedCtrl = TextEditingController();
  final _lmCtrl = TextEditingController();
  File? _imageFile;
  bool _saving = false;

  final _picker = ImagePicker();

  Future<void> _pickImage() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Camera'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;
    final xfile = await _picker.pickImage(source: source, imageQuality: 75);
    if (xfile != null) {
      setState(() => _imageFile = File(xfile.path));
    }
  }

  Future<void> _saveCow() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await AppDb.instance.addCow(
        cowId: _cowIdCtrl.text.trim(),
        name: _nameCtrl.text.trim(),
        breed: _breedCtrl.text.trim(),
        lactationMonth: int.parse(_lmCtrl.text.trim()),
        imagePath: _imageFile?.path,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cow added successfully')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
    } finally {
      setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    _cowIdCtrl.dispose();
    _nameCtrl.dispose();
    _breedCtrl.dispose();
    _lmCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Add Cow')),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [cs.primary, cs.secondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: BackdropFilter(
                    filter: ui.ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white.withOpacity(0.25)),
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            GestureDetector(
                              onTap: _pickImage,
                              child: Container(
                                width: 160,
                                height: 160,
                                decoration: BoxDecoration(
                                  color: cs.primaryContainer,
                                  borderRadius: BorderRadius.circular(18),
                                  image: _imageFile != null
                                      ? DecorationImage(image: FileImage(_imageFile!), fit: BoxFit.cover)
                                      : null,
                                  boxShadow: [
                                    BoxShadow(
                                      color: cs.primary.withOpacity(0.1),
                                      blurRadius: 10,
                                      offset: const Offset(0, 6),
                                    )
                                  ],
                                ),
                                child: _imageFile == null
                                    ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_a_photo, color: cs.onPrimaryContainer),
                                    const SizedBox(height: 8),
                                    Text('Add image',
                                        style: TextStyle(color: cs.onPrimaryContainer)),
                                  ],
                                )
                                    : null,
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _cowIdCtrl,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: 'Cow ID',
                                labelStyle: const TextStyle(color: Colors.white),
                                prefixIcon: const Icon(Icons.qr_code_2, color: Colors.white),
                                fillColor: Colors.white.withOpacity(0.12),
                              ),
                              validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _nameCtrl,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: 'Cow Name',
                                labelStyle: const TextStyle(color: Colors.white),
                                prefixIcon: const Icon(Icons.pets, color: Colors.white),
                                fillColor: Colors.white.withOpacity(0.12),
                              ),
                              validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _breedCtrl,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: 'Cow Breed',
                                labelStyle: const TextStyle(color: Colors.white),
                                prefixIcon: const Icon(Icons.grass, color: Colors.white),
                                fillColor: Colors.white.withOpacity(0.12),
                              ),
                              validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _lmCtrl,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: 'Lactation Month',
                                labelStyle: const TextStyle(color: Colors.white),
                                prefixIcon: const Icon(Icons.calendar_month, color: Colors.white),
                                fillColor: Colors.white.withOpacity(0.12),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) return 'Required';
                                final n = int.tryParse(v);
                                if (n == null || n < 0) return 'Enter a valid number';
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: _saving ? null : _saveCow,
                                icon: _saving
                                    ? const SizedBox(
                                    height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                                    : const Icon(Icons.save),
                                label: const Text('Save'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}