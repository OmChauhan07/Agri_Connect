import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseInit {
  // Initialize Supabase with your project credentials
  static Future<void> initialize() async {
    try {
      await Supabase.initialize(
        url: const String.fromEnvironment('SUPABASE_URL', 
          defaultValue: 'https://xyzcompany.supabase.co'),
        anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY',
          defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.example'),
        debug: false,
      );
      
      debugPrint('Supabase initialized successfully');
    } catch (e) {
      debugPrint('Error initializing Supabase: ${e.toString()}');
    }
  }
  
  // Run database migrations/initialization
  static Future<void> setupDatabase() async {
    try {
      final client = Supabase.instance.client;
      
      // Check if the database has been initialized
      final hasNGOs = await client
          .from('ngos')
          .select('id')
          .limit(1);
      
      if (hasNGOs.isNotEmpty) {
        debugPrint('Database already initialized');
        return;
      }
      
      // Execute the database creation script
      final sqlScript = '''
      -- Create RPC function to execute SQL
      CREATE OR REPLACE FUNCTION exec_sql(sql_query TEXT) RETURNS VOID AS \$\$
      BEGIN
        EXECUTE sql_query;
      END;
      \$\$ LANGUAGE plpgsql SECURITY DEFINER;
      ''';
      
      // Execute the SQL function creation
      await client.rpc('exec_sql', params: {'sql_query': sqlScript});
      
      // Now run the full database creation script from our file (would need to load this from assets)
      // For now, just add sample NGOs
      final ngoInsertScript = '''
      INSERT INTO ngos (name, description, website_url, contact_email, contact_phone) VALUES
      ('Food For All', 'An organization dedicated to eliminating hunger by providing nutritious meals to those in need.', 'https://foodforall.org', 'contact@foodforall.org', '+91-9876543210'),
      ('Green Earth Initiative', 'We work towards sustainable farming practices and food security.', 'https://greenearthinitiative.org', 'info@greenearthinitiative.org', '+91-8765432109'),
      ('Rural Development Trust', 'Focusing on rural development through agriculture, education, and healthcare.', 'https://ruraldevelopmenttrust.org', 'support@ruraldevelopmenttrust.org', '+91-7654321098');
      ''';
      
      await client.rpc('exec_sql', params: {'sql_query': ngoInsertScript});
      
      debugPrint('Database initialized successfully');
    } catch (e) {
      debugPrint('Error initializing database: ${e.toString()}');
    }
  }
}