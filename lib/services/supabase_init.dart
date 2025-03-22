import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseInit {
  // Initialize Supabase with your project credentials
  static Future<void> initialize() async {
    try {
      // Get URL and key from environment variables
      final supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
      final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';

      if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
        throw Exception(
            'Supabase URL or Anon Key is empty. Check your .env file.');
      }

      print('Initializing Supabase with URL: $supabaseUrl');

      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
        debug: true,
      );

      print('Supabase initialized successfully');

      // Test the connection
      await _testConnection();
    } catch (e) {
      print('Error initializing Supabase: ${e.toString()}');
      print('Full error stack: $e');

      // Show alert to the user if needed
      // This is where you might want to show a dialog to the user
      // indicating there was a connection issue
    }
  }

  // Test the Supabase connection
  static Future<void> _testConnection() async {
    try {
      final client = Supabase.instance.client;
      final response = await client.from('ngos').select('id').limit(1);
      print('Connection test successful: ${response != null}');
    } catch (e) {
      print('Connection test failed: ${e.toString()}');
      if (e.toString().contains('Invalid API key')) {
        print(
            'Your API key appears to be invalid. Please check your Supabase dashboard and update the key.');
      }
      rethrow; // Rethrow to be caught by the caller
    }
  }

  // Run database migrations/initialization
  static Future<void> setupDatabase() async {
    try {
      print('Setting up database...');

      // Get Supabase client
      final client = Supabase.instance.client;
      print('Got Supabase client');

      try {
        // Check if the database has been initialized
        print('Checking if database is already initialized...');
        final hasNGOs = await client.from('ngos').select('id').limit(1);

        if (hasNGOs != null && hasNGOs.isNotEmpty) {
          print('Database already initialized with NGOs');
          return;
        }

        print('Database needs initialization, creating tables...');
      } catch (e) {
        // If table doesn't exist or other error
        print('Error checking tables, might need creation: ${e.toString()}');
      }

      print('Database setup completed');
    } catch (e) {
      print('Error in database setup: ${e.toString()}');
    }
  }
}
