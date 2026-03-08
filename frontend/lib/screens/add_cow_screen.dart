import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../api/cow_api.dart';

class AddCowScreen extends StatefulWidget {
  static const routeName = '/add-cow';
  const AddCowScreen({super.key});

  @override
  State<AddCowScreen> createState() => _AddCowScreenState();
}

/// Common cattle breeds – dairy, beef, and South Asian varieties.
const List<String> _cattleBreeds = [
  'Holstein / Holstein-Friesian',
  'Jersey',
  'Ayrshire',
  'Brown Swiss',
  'Guernsey',
  'Milking Shorthorn',
  'Friesian',
  'Sahiwal',
  'Tharparkar',
  'Gir (Gyr)',
  'Hariana',
  'Red Sindhi',
  'Ongole',
  'Kankrej',
  'Deoni',
  'Angus',
  'Hereford',
  'Simmental',
  'Limousin',
  'Charolais',
  'Brahman',
  'Shorthorn',
  'Belted Galloway',
  'Highland',
  'Dexter',
  'Nelore',
  'Zebu',
  'Lanka White (Sinhala)',
  'Other',
];

class _AddCowScreenState extends State<AddCowScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _lmCtrl = TextEditingController();
  final _parityCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();

  String? _selectedBreed;
  DateTime? _selectedBirthdate;
  File? _imageFile;
  bool _saving = false;
  String _generatedCowId = '…';

  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _fetchNextId();
  }

  Future<void> _fetchNextId() async {
    try {
      final id = await CowApi.getNextCowId();
      if (mounted) setState(() => _generatedCowId = id);
    } catch (_) {
      if (mounted) setState(() => _generatedCowId = 'COW-001');
    }
  }

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
    if (xfile != null) setState(() => _imageFile = File(xfile.path));
  }

  Future<void> _saveCow() async {
    if (!_formKey.currentState!.validate()) return;
    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add a cow image (required for identification)')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      await CowApi.storeCow(
        name: _nameCtrl.text.trim(),
        imageFile: _imageFile!,
        breed: _selectedBreed,
        birthdate: _selectedBirthdate != null
            ? _selectedBirthdate!.toIso8601String().substring(0, 10)
            : null,
        lactationMonth: _lmCtrl.text.trim().isEmpty
            ? null
            : int.tryParse(_lmCtrl.text.trim()),
        parity: _parityCtrl.text.trim().isEmpty
            ? null
            : int.tryParse(_parityCtrl.text.trim()),
        weight: _weightCtrl.text.trim().isEmpty
            ? null
            : double.tryParse(_weightCtrl.text.trim()),
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
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _lmCtrl.dispose();
    _parityCtrl.dispose();
    _weightCtrl.dispose();
    super.dispose();
  }

  InputDecoration _fieldDecor(String label, IconData icon) => InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white),
        prefixIcon: Icon(icon, color: Colors.white),
        fillColor: Colors.white.withOpacity(0.12),
      );

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
                            // ── Photo picker ────────────────────────────────
                            GestureDetector(
                              onTap: _pickImage,
                              child: Container(
                                width: 160,
                                height: 160,
                                decoration: BoxDecoration(
                                  color: cs.primaryContainer,
                                  borderRadius: BorderRadius.circular(18),
                                  image: _imageFile != null
                                      ? DecorationImage(
                                          image: FileImage(_imageFile!),
                                          fit: BoxFit.cover)
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
                                          Icon(Icons.add_a_photo,
                                              color: cs.onPrimaryContainer),
                                          const SizedBox(height: 8),
                                          Text('Add image',
                                              style: TextStyle(
                                                  color: cs.onPrimaryContainer)),
                                        ],
                                      )
                                    : null,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // ── Auto-generated Cow ID (read-only) ────────────
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 14),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.10),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: Colors.white.withOpacity(0.3)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.qr_code_2,
                                      color: Colors.white70, size: 20),
                                  const SizedBox(width: 10),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text('Cow ID (auto-generated)',
                                          style: TextStyle(
                                              color: Colors.white60,
                                              fontSize: 12)),
                                      Text(
                                        _generatedCowId,
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 16,
                                            letterSpacing: 1.2),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),

                            // ── Name ─────────────────────────────────────────
                            TextFormField(
                              controller: _nameCtrl,
                              style: const TextStyle(color: Colors.white),
                              decoration:
                                  _fieldDecor('Cow Name', Icons.pets),
                              validator: (v) =>
                                  (v == null || v.trim().isEmpty)
                                      ? 'Required'
                                      : null,
                            ),
                            const SizedBox(height: 12),

                            // ── Breed dropdown ───────────────────────────────
                            DropdownButtonFormField<String>(
                              value: _selectedBreed,
                              style: const TextStyle(color: Colors.white),
                              dropdownColor: const Color(0xFF2E5E3E),
                              decoration:
                                  _fieldDecor('Cow Breed', Icons.grass),
                              hint: const Text('Select breed',
                                  style:
                                      TextStyle(color: Colors.white60)),
                              items: _cattleBreeds
                                  .map((b) => DropdownMenuItem(
                                        value: b,
                                        child: Text(b,
                                            style: const TextStyle(
                                                color: Colors.white)),
                                      ))
                                  .toList(),
                              onChanged: (v) =>
                                  setState(() => _selectedBreed = v),
                              validator: (v) =>
                                  v == null ? 'Please select a breed' : null,
                            ),
                            const SizedBox(height: 12),

                            // ── Birthdate ────────────────────────────────────
                            GestureDetector(
                              onTap: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: _selectedBirthdate ?? DateTime.now(),
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime.now(),
                                  builder: (ctx, child) => Theme(
                                    data: Theme.of(ctx).copyWith(
                                      colorScheme: Theme.of(ctx)
                                          .colorScheme
                                          .copyWith(primary: Colors.green.shade700),
                                    ),
                                    child: child!,
                                  ),
                                );
                                if (picked != null) {
                                  setState(() => _selectedBirthdate = picked);
                                }
                              },
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 14),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.10),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: Colors.white.withOpacity(0.3)),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.cake,
                                        color: Colors.white70, size: 20),
                                    const SizedBox(width: 10),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text('Date of Birth (optional)',
                                            style: TextStyle(
                                                color: Colors.white60,
                                                fontSize: 12)),
                                        Text(
                                          _selectedBirthdate != null
                                              ? '${_selectedBirthdate!.year}-'
                                                '${_selectedBirthdate!.month.toString().padLeft(2, '0')}-'
                                                '${_selectedBirthdate!.day.toString().padLeft(2, '0')}'
                                              : 'Tap to select',
                                          style: TextStyle(
                                              color: _selectedBirthdate != null
                                                  ? Colors.white
                                                  : Colors.white54,
                                              fontWeight: _selectedBirthdate != null
                                                  ? FontWeight.w600
                                                  : FontWeight.normal,
                                              fontSize: 14),
                                        ),
                                      ],
                                    ),
                                    const Spacer(),
                                    if (_selectedBirthdate != null)
                                      GestureDetector(
                                        onTap: () => setState(
                                            () => _selectedBirthdate = null),
                                        child: const Icon(Icons.clear,
                                            color: Colors.white54, size: 18),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),

                            // ── Weight ───────────────────────────────────────
                            TextFormField(
                              controller: _weightCtrl,
                              style: const TextStyle(color: Colors.white),
                              decoration: _fieldDecor(
                                  'Weight (kg)', Icons.monitor_weight),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              validator: (v) {
                                if (v == null || v.trim().isEmpty)
                                  return null; // optional
                                final n = double.tryParse(v);
                                if (n == null || n < 0)
                                  return 'Enter a valid weight';
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),

                            // ── Parity ───────────────────────────────────────
                            TextFormField(
                              controller: _parityCtrl,
                              style: const TextStyle(color: Colors.white),
                              decoration: _fieldDecor(
                                  'Parity (number of calvings)', Icons.child_friendly),
                              keyboardType: TextInputType.number,
                              validator: (v) {
                                if (v == null || v.trim().isEmpty)
                                  return null; // optional
                                final n = int.tryParse(v);
                                if (n == null || n < 0 || n > 20)
                                  return 'Enter a number between 0 and 20';
                                return null;
                              },
                            ),
                            // ── Parity hint ──────────────────────────────────
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 4, left: 4, bottom: 4),
                              child: Row(
                                children: const [
                                  Icon(Icons.info_outline,
                                      color: Colors.white54, size: 13),
                                  SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      'Parity = total number of times this cow has calved (0 = never calved).',
                                      style: TextStyle(
                                          color: Colors.white54,
                                          fontSize: 11),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),

                            // ── Lactation Month ──────────────────────────────
                            TextFormField(
                              controller: _lmCtrl,
                              style: const TextStyle(color: Colors.white),
                              decoration: _fieldDecor(
                                  'Lactation Month', Icons.calendar_month),
                              keyboardType: TextInputType.number,
                              validator: (v) {
                                if (v == null || v.trim().isEmpty)
                                  return null; // optional
                                final n = int.tryParse(v);
                                if (n == null || n < 0)
                                  return 'Enter a valid number';
                                return null;
                              },
                            ),
                            // ── Lactation month hint ─────────────────────────
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 4, left: 4, bottom: 4),
                              child: Row(
                                children: const [
                                  Icon(Icons.info_outline,
                                      color: Colors.white54, size: 13),
                                  SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      'Lactation month = how many months since this cow last gave birth and started producing milk (0 = not currently lactating).',
                                      style: TextStyle(
                                          color: Colors.white54,
                                          fontSize: 11),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),

                            // ── Save button ──────────────────────────────────
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: _saving ? null : _saveCow,
                                icon: _saving
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2))
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

