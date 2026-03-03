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
 var _loading = true;
 final _usernameController = TextEditingController();
 final _websiteController = TextEditingController();
 String? _avatarUrl;
 @override
 void initState() {
 super.initState();
 WidgetsBinding.instance.addPostFrameCallback((_) => _loadProfile());
 }
 @override
 void dispose() {
 _usernameController.dispose();
 _websiteController.dispose();
 super.dispose();
 }
 // Chargement du profil depuis Supabase
 Future<void> _loadProfile() async {
 final scaffoldMessenger = ScaffoldMessenger.of(context);
 
 try {
 final userId = supabase.auth.currentUser!.id;
 final data = await supabase
 .from('profiles')
 .select()
 .match({'id': userId})
 .maybeSingle();
 setState(() {
 if (data != null) {
 _usernameController.text = data['username'] ?? '';
 _websiteController.text = data['website'] ?? '';
 _avatarUrl = (data['avatar_url'] ?? '') as String;
 }
 _loading = false;
 });
 } catch (e) {
 setState(() => _loading = false);
 if (mounted) {
 scaffoldMessenger.showSnackBar(const SnackBar(
 content: Text('Error occurred while getting profile'),
 backgroundColor: Colors.red,
 ));
 }
 }
 }
 // Sauvegarde du profil via upsert (insert ou update)
 Future<void> _saveProfile() async {
 final scaffoldMessenger = ScaffoldMessenger.of(context);
 setState(() => _loading = true);
 try {
 final userId = supabase.auth.currentUser!.id;
 await supabase.from('profiles').upsert({
 'id': userId,
 'username': _usernameController.text,
 'website': _websiteController.text,
 'updated_at': DateTime.now().toIso8601String(),
 });
 if (mounted) {
 scaffoldMessenger.showSnackBar(
 const SnackBar(content: Text('Saved profile')),
 );
 }
 } catch (e) {
 scaffoldMessenger.showSnackBar(const SnackBar(
 content: Text('Error saving profile'),
 backgroundColor: Colors.red,
 ));
 }
 setState(() => _loading = false);
 }
 // Mise à jour de l'URL d'avatar après upload
 Future<void> _onUpload(String imageUrl) async {
 
 try {
 final userId = supabase.auth.currentUser!.id;
 await supabase.from('profiles').upsert({
 'id': userId,
 'avatar_url': imageUrl,
 });
 if (mounted) context.showSnackBar('Updated your profile image!');
 } on PostgrestException catch (error) {
 if (mounted) context.showSnackBar(error.message, isError: true);
 } catch (error) {
 if (mounted) context.showSnackBar('Unexpected error occurred',
isError: true);
 }
 if (!mounted) return;
 setState(() => _avatarUrl = imageUrl);
 }
 @override
 Widget build(BuildContext context) {
 return Scaffold(
 appBar: AppBar(title: const Text('Profile')),
 body: _loading
 ? const Center(child: CircularProgressIndicator())
 : ListView(
 padding: const EdgeInsets.symmetric(horizontal: 16,
vertical: 20),
 children: [
 Avatar(imageUrl: _avatarUrl, onUpload: _onUpload),
 const SizedBox(height: 16),
 TextFormField(
 controller: _usernameController,
 decoration: const InputDecoration(label:
Text('Username')),
 ),
 const SizedBox(height: 16),
 TextFormField(
 controller: _websiteController,
 decoration: const InputDecoration(label:
Text('Website')),
 ),
 const SizedBox(height: 16),
 ElevatedButton(onPressed: _saveProfile, child: const
Text('Save')),
 const SizedBox(height: 16),
 TextButton(
 onPressed: () {
 supabase.auth.signOut();
 Navigator.pop(context);
 },
 child: const Text('Sign Out'),
 ),
 ],
 ),
 );
 
 
 }
}