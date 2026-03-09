import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../main.dart';

class Avatar extends StatefulWidget {
  const Avatar({
    super.key,
    required this.imageUrl,
    required this.onUpload,
  });

  final String? imageUrl;
  final void Function(String) onUpload;

  @override
  State<Avatar> createState() => _AvatarState();
}

class _AvatarState extends State<Avatar> {
  bool _isLoading = false;

  Future<void> _upload() async {
    final picker = ImagePicker();
    final imageFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 300,
      maxHeight: 300,
    );
    if (imageFile == null) return;

    setState(() => _isLoading = true);
    try {
      final bytes = await imageFile.readAsBytes();
      final fileExt = imageFile.path.split('.').last;
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExt';

      await supabase.storage.from('avatars').uploadBinary(
            fileName,
            bytes,
            fileOptions: FileOptions(contentType: imageFile.mimeType),
          );

      final signedUrl = await supabase.storage
          .from('avatars')
          .createSignedUrl(fileName, 60 * 60 * 24 * 365 * 10);
          
      widget.onUpload(signedUrl);
    } catch (error) {
      if (mounted) context.showSnackBar('Erreur upload : $error', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.imageUrl == null || widget.imageUrl!.isEmpty)
          Container(
            width: 150, height: 150,
            decoration: BoxDecoration(color: Colors.grey[300], shape: BoxShape.circle),
            child: const Icon(Icons.person, size: 50),
          )
        else
          ClipOval(
            child: Image.network(
              widget.imageUrl!,
              width: 150, height: 150, fit: BoxFit.cover,
            ),
          ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: _isLoading ? null : _upload,
          child: _isLoading ? const CircularProgressIndicator() : const Text('Changer photo'),
        ),
      ],
    );
  }
}