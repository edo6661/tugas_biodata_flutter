import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class Avatar extends StatefulWidget {
  const Avatar({
    super.key,
    required this.imageUrl,
    required this.onImageSelected,
  });

  final String? imageUrl;
  final void Function(XFile) onImageSelected;

  @override
  State<Avatar> createState() => _AvatarState();
}

class _AvatarState extends State<Avatar> {
  XFile? _selectedImage;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final imageFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 300,
      maxHeight: 300,
    );
    if (imageFile == null) return;

    setState(() {
      _selectedImage = imageFile;
    });

    widget.onImageSelected(imageFile);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _selectedImage != null
            ? Image.file(
                File(_selectedImage!.path),
                width: 150,
                height: 150,
                fit: BoxFit.cover,
              )
            : widget.imageUrl != null && widget.imageUrl!.isNotEmpty
                ? Image.network(
                    widget.imageUrl!,
                    width: 150,
                    height: 150,
                    fit: BoxFit.cover,
                  )
                : Container(
                    width: 150,
                    height: 150,
                    color: Colors.grey,
                    child: const Center(child: Text('Avatar Masih Kosong')),
                  ),
        ElevatedButton(
          onPressed: _pickImage,
          child: const Text('Select Avatar'),
        ),
      ],
    );
  }
}
