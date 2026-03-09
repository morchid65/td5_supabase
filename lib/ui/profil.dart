import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../main.dart';
import 'avatar.dart';


class ProfileForm extends StatefulWidget {
  const ProfileForm({super.key});

  @override
  State<ProfileForm> createState() => ProfileFormState();
}

class ProfileFormState extends State<ProfileForm> {
  bool _loading = true;
  final _usernameController = TextEditingController();
  final _websiteController = TextEditingController();
  String? _avatarUrl;

  @override
  void initState() {
    super.initState();
    // On utilise microtask ou postFrameCallback pour ne pas bloquer le build initial
    Future.microtask(() => _loadProfile());
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  /// Chargement du profil
  Future<void> _loadProfile() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;

      final data = await supabase
          .from('profiles')
          .select()
          .eq('id', user.id) // Utilisation de .eq() est plus standard que .match() ici
          .maybeSingle();

      if (data != null && mounted) {
        setState(() {
          _usernameController.text = data['username'] ?? '';
          _websiteController.text = data['website'] ?? '';
          _avatarUrl = data['avatar_url'] as String?;
        });
      }
    } catch (e) {
      if (mounted) context.showSnackBar('Erreur lors du chargement du profil', isError: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  /// Sauvegarde via Upsert
  Future<void> _saveProfile() async {
    setState(() => _loading = true);
    try {
      final userId = supabase.auth.currentUser?.id;
      await supabase.from('profiles').upsert({
        'id': userId,
        'username': _usernameController.text.trim(),
        'website': _websiteController.text.trim(),
        'updated_at': DateTime.now().toIso8601String(),
      });
      if (mounted) context.showSnackBar('Profil mis à jour !');
    } catch (e) {
      if (mounted) context.showSnackBar('Erreur de sauvegarde', isError: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  /// Callback déclenché par le widget Avatar
  Future<void> _onUpload(String imageUrl) async {
    try {
      final userId = supabase.auth.currentUser?.id;
      await supabase.from('profiles').upsert({
        'id': userId,
        'avatar_url': imageUrl,
      });
      if (mounted) {
        setState(() => _avatarUrl = imageUrl);
        context.showSnackBar('Image de profil mise à jour !');
      }
    } catch (e) {
      if (mounted) context.showSnackBar('Erreur lors de la mise à jour de l\'image', isError: true);
    }
  }

  /// Déconnexion sécurisée
  Future<void> _signOut() async {
    try {
      await supabase.auth.signOut();
      if (mounted) {
        // pushAndRemoveUntil vide la pile pour éviter que l'utilisateur ne revienne en arrière
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      }
    } catch (e) {
      if (mounted) context.showSnackBar('Erreur lors de la déconnexion', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mon Profil')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Avatar(imageUrl: _avatarUrl, onUpload: _onUpload),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Nom d\'utilisateur',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _websiteController,
                  decoration: const InputDecoration(
                    labelText: 'Site Web',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _loading ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                  child: const Text('Enregistrer les modifications'),
                ),
                const Divider(height: 40),
                TextButton(
                  onPressed: _signOut,
                  child: const Text('Se déconnecter', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
    );
  }
}