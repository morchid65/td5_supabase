import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:td5_supabase/ui/login.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
WidgetsFlutterBinding.ensureInitialized();
 await dotenv.load(fileName: '.env'); // chargement du fichier
 await Supabase.initialize(
 url: dotenv.env['SUPABASE_URL']!,
 anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
 );
 runApp(MaterialApp(home: LoginScreen()));
}
// Instance globale du client Supabase
final supabase = Supabase.instance.client;

// Extension utilitaire pour afficher des messages
extension ContextExtension on BuildContext {
 void showSnackBar(String message, {bool isError = false}) {
 ScaffoldMessenger.of(this).showSnackBar(
 SnackBar(
 content: Text(message),
 backgroundColor: isError
 ? Theme.of(this).colorScheme.error
 : Theme.of(this).snackBarTheme.backgroundColor,

 ),
 );
 }
}
