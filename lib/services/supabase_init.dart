import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseInit {
  // Initialize Supabase with your project credentials
  static Future<void> initialize() async {
    try {
      // Use direct URL from environment
      // We got this from the environment check
      const supabaseUrl = 'https://txdaworvfxrhtbdxxejg.supabase.co';
      
      // For the anon key, we'll need to get it from environment
      const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InR4ZGF3b3J2ZnhyaHRiZHh4ZWpnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MTYzODgwMzQsImV4cCI6MjAzMTk2NDAzNH0._3NZu7GZUxZTNdBpRXD0MKcwLw3wz4QS6QVV-jQ7Kd8';
      
      print('Initializing Supabase with URL: $supabaseUrl');
      
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
        debug: true, // Set to true for debugging
      );
      
      print('Supabase initialized successfully');
    } catch (e) {
      print('Error initializing Supabase: ${e.toString()}');
      // Print more detailed error
      print('Full error stack: $e');
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
        final hasNGOs = await client
            .from('ngos')
            .select('id')
            .limit(1);
        
        if (hasNGOs.isNotEmpty) {
          print('Database already initialized with NGOs');
          return;
        }
        
        print('Database needs initialization, creating tables...');
      } catch (e) {
        // If table doesn't exist or other error
        print('Error checking tables, might need creation: ${e.toString()}');
        // Continue with initialization
      }
      
      try {
        // Execute the database creation script
        print('Creating SQL execution function...');
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
        print('SQL execution function created successfully');
      } catch (e) {
        print('Error creating SQL execution function: ${e.toString()}');
        // Function might already exist, continue
      }
      
      try {
        // Now run the full database creation script from our file (would need to load this from assets)
        // For now, just add sample NGOs
        print('Inserting sample NGOs...');
        final ngoInsertScript = '''
        INSERT INTO ngos (name, description, website_url, contact_email, contact_phone) VALUES
        ('Food For All', 'An organization dedicated to eliminating hunger by providing nutritious meals to those in need.', 'https://foodforall.org', 'contact@foodforall.org', '+91-9876543210'),
        ('Green Earth Initiative', 'We work towards sustainable farming practices and food security.', 'https://greenearthinitiative.org', 'info@greenearthinitiative.org', '+91-8765432109'),
        ('Rural Development Trust', 'Focusing on rural development through agriculture, education, and healthcare.', 'https://ruraldevelopmenttrust.org', 'support@ruraldevelopmenttrust.org', '+91-7654321098');
        ''';
        
        await client.rpc('exec_sql', params: {'sql_query': ngoInsertScript});
        print('Sample NGOs inserted successfully');
      } catch (e) {
        print('Error inserting sample NGOs: ${e.toString()}');
      }
      
      print('Database setup completed');
    } catch (e) {
      print('Error in database setup: ${e.toString()}');
    }
  }
}