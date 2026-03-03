import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../main.dart';

class RegistrationScreen extends StatefulWidget {
 const RegistrationScreen({super.key});
 @override
 State<RegistrationScreen> createState() => _RegistrationScreenState();
}
class _RegistrationScreenState extends State<RegistrationScreen> {
 final TextEditingController emailController =
TextEditingController();
 final TextEditingController passwordController =
TextEditingController();
 AuthResponse? response;
 @override
 Widget build(BuildContext context) {
 return Scaffold(
 appBar: AppBar(title: Text('Register')),
 body: Padding(
 padding: const EdgeInsets.all(16.0),
 child: Column(
 children: [
 TextField(
 controller: emailController,
 decoration: InputDecoration(labelText: 'Email'),
 ),
 TextField(
 controller: passwordController,
 decoration: InputDecoration(labelText: 'Password'),
 obscureText: true,
 ),
 SizedBox(height: 16),
 ElevatedButton(
 onPressed: () async {
 try {
 response = await supabase.auth.signUp(
 email: emailController.text,
 password: passwordController.text,
 );
 } catch (e) {
 if (mounted) context.showSnackBar(e.toString(), isError:
true);
 }
 if (response?.user != null) {
 Navigator.pop(context); // retour au login
 } else {
 if (mounted) context.showSnackBar('Registration error',
isError: true);
 }
 },
 child: Text('Register'),
 ),
 ],
 ),

 ),
 );
 }
 @override
 void dispose() {
 emailController.dispose();
 passwordController.dispose();
 super.dispose();
 }
}