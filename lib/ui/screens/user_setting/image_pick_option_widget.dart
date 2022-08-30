import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../commons/custom_profile_image_view.dart';

class ImagePickOptionWidget extends StatelessWidget {
  final Function(ImageType imageType, String imagePath) imageCallBack;

  const ImagePickOptionWidget({required this.imageCallBack});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Divider(height: 1),
            ListTile(
              onTap: _openGallery,
              title: Text("Gallery"),
              leading: Icon(Icons.image, color: Theme.of(context).colorScheme.secondary),
            ),
            Divider(height: 1),
            ListTile(
              onTap: _openCamera,
              title: Text("Camera"),
              leading: Icon(Icons.camera, color: Theme.of(context).colorScheme.secondary),
            ),
          ],
        ),
      ),
    );
  }

  void _openGallery() async {
    XFile? pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    imageCallBack.call(ImageType.ASSENT_IMAGE, (pickedFile?.path ?? ""));
  }

  void _openCamera() async {
    XFile? pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);
    imageCallBack.call(ImageType.ASSENT_IMAGE, (pickedFile?.path ?? ""));
  }
}
