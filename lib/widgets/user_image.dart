import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UserImagePicker extends StatefulWidget {
  const UserImagePicker({super.key, required this.onPickedImage});
  final Function (File pickedImage) onPickedImage;

  @override
  State<UserImagePicker> createState() => _UserImagePickerState();
}

class _UserImagePickerState extends State<UserImagePicker> {
  File? _pickedImageFile;

  void _pickedImage() async {
    final XFile? pickedImage = await ImagePicker()
        .pickImage(source: ImageSource.camera, maxWidth: 150, imageQuality: 50);

    if (pickedImage == null){
      log('pick image null');
      return;
    }

    setState(() {
      log('pick image true');
      _pickedImageFile = File(pickedImage.path);
    });
    widget.onPickedImage(_pickedImageFile!);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          radius: 40,
          foregroundImage: _pickedImageFile == null? null : FileImage(_pickedImageFile!),
        ),
        TextButton.icon(
          onPressed: _pickedImage,
          label: const Text('Add Image'),
          icon: const Icon(Icons.image_outlined),
        )
      ],
    );
  }
}
