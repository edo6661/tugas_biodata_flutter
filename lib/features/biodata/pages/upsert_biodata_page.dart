import 'package:biodata/entity/biodata.dart';
import 'package:biodata/features/biodata/widgets/avatar.dart';
import 'package:biodata/features/home/pages/home_page.dart';
import 'package:biodata/main.dart';
import 'package:biodata/ui/utils/snackbar.dart';
import 'package:biodata/utils/log_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UpsertBiodataPage extends StatefulWidget {
  final Biodata? biodata;
  static route({Biodata? biodata}) => MaterialPageRoute(
        builder: (context) => UpsertBiodataPage(biodata: biodata),
      );
  const UpsertBiodataPage({super.key, this.biodata});

  @override
  State<UpsertBiodataPage> createState() => _UpsertBiodataPageState();
}

class _UpsertBiodataPageState extends State<UpsertBiodataPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _ageController = TextEditingController();
  final _addressController = TextEditingController();

  String? _avatarUrl;
  XFile? _selectedImage;

  @override
  void initState() {
    super.initState();
    if (widget.biodata != null) {
      _usernameController.text = widget.biodata!.username;
      _ageController.text = widget.biodata!.age;
      _addressController.text = widget.biodata!.address;
      _avatarUrl = widget.biodata!.avatarUrl;
    }
  }

  Future<void> _upsertProfile() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedImage == null && _avatarUrl == null) {
      SnackBarUtil.showSnackBar(
        context: context,
        message: 'Avatar tidak boleh kosong',
        type: SnackBarType.error,
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      SnackBarUtil.showSnackBar(
        context: context,
        message: 'User not found',
        type: SnackBarType.error,
      );
      return;
    }
    try {
      String? imageUrl;
      if (_selectedImage != null) {
        final bytes = await _selectedImage!.readAsBytes();
        final fileExt = _selectedImage!.path.split('.').last;
        final fileName = '${DateTime.now().toIso8601String()}.$fileExt';

        await supabase.storage.from('images').uploadBinary(
              fileName,
              bytes,
              fileOptions: FileOptions(contentType: _selectedImage!.mimeType),
            );

        final response = await supabase.storage
            .from('images')
            .createSignedUrl(fileName, 60 * 60 * 24 * 365 * 10);
        imageUrl = response;
      }

      final biodataData = {
        'userId': user.uid,
        'username': _usernameController.text.trim(),
        'age': _ageController.text.trim(),
        'address': _addressController.text.trim(),
        'avatar_url': imageUrl ?? _avatarUrl,
      };

      final collection = FirebaseFirestore.instance.collection('biodata');

      if (widget.biodata == null) {
        await collection.add({
          ...biodataData,
          'createdAt': FieldValue.serverTimestamp(),
        });
      } else {
        await collection.doc(widget.biodata!.docId).update(biodataData);
      }

      if (mounted) {
        SnackBarUtil.showSnackBar(
          context: context,
          message: 'Profil berhasil disimpan',
        );
        setState(() {
          _avatarUrl = imageUrl ?? _avatarUrl;
          _selectedImage = null;
        });
        Navigator.of(context).pushAndRemoveUntil(
          HomePage.route(),
          (route) => false,
        );
      }
    } catch (error) {
      LogService.e("Error: $error");
      SnackBarUtil.showSnackBar(
        context: context,
        message: 'Gagal menyimpan profil',
        type: SnackBarType.error,
      );
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _ageController.dispose();
    _addressController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
        children: [
          Avatar(
            imageUrl: _avatarUrl,
            onImageSelected: (file) {
              setState(() {
                _selectedImage = file;
              });
            },
          ),
          const SizedBox(height: 18),
          Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(labelText: 'User Name'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Username tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 18),
                TextFormField(
                  controller: _ageController,
                  decoration: const InputDecoration(labelText: 'Age'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Age tidak boleh kosong';
                    }
                    if (int.tryParse(value.trim()) == null) {
                      return 'Masukkan angka yang valid untuk Age';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 18),
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(labelText: 'Address'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Address tidak boleh kosong';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          ElevatedButton(
            onPressed: _upsertProfile,
            child: const Text('Save Profile'),
          ),
        ],
      ),
    );
  }
}
