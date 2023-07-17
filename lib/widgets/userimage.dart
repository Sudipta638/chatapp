import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UserImage extends StatefulWidget {
  const UserImage({super.key, required this.onpickedimage});
  final void Function(File selectediamge) onpickedimage;
  @override
  State<UserImage> createState() => _UserImageState();
}

class _UserImageState extends State<UserImage> {
  File? _uplaodimage;
  void _onphototake() async {
    final _takeimage = await ImagePicker()
        .pickImage(source: ImageSource.camera, maxWidth: 150, imageQuality: 50);
    if (_takeimage == null) {
      return;
    }
    setState(() {
      _uplaodimage = File(_takeimage.path);
    });
    widget.onpickedimage(_uplaodimage!);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: Colors.grey,
          foregroundImage:
              _uplaodimage == null ? null : FileImage(_uplaodimage!),
        ),
        TextButton.icon(
          onPressed: _onphototake,
          icon: const Icon(Icons.image),
          label: Text("Add iamge",
              style: TextStyle(color: Theme.of(context).colorScheme.primary)),
        )
      ],
    );
  }
}
