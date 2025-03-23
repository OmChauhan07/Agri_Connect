# Farmers Marketplace

A Flutter application that connects farmers and consumers directly.

## Getting Started

This project uses Flutter and Supabase as its backend.

### Prerequisites

- Flutter SDK (latest version recommended)
- Supabase account

### Setup

1. Clone the repository
   ```
   git clone https://github.com/yourusername/FarmersMarketplace.git
   cd FarmersMarketplace
   ```

2. Install dependencies
   ```
   flutter pub get
   ```

3. Set up environment variables
   - Copy the `.env.example` file to create a new `.env` file:
     ```
     cp .env.example .env
     ```
   - Open the `.env` file and add your Supabase credentials:
     ```
     SUPABASE_URL=your_supabase_project_url
     SUPABASE_ANON_KEY=your_supabase_anon_key
     ```
   - You can find these values in your Supabase dashboard under Project Settings > API

4. Run the application
   ```
   flutter run
   ```

## Features

- User authentication with Supabase
- Browse and search for farm products
- Place orders directly from farmers
- Track order status
- Farmer dashboard to manage products and orders

## Architecture

This project follows a provider-based state management approach with a service-oriented architecture:

- `lib/main.dart`: Application entry point
- `lib/services/`: API and service integrations
- `lib/models/`: Data models
- `lib/providers/`: State management
- `lib/screens/`: UI screens
- `lib/components/`: Reusable UI components

## Troubleshooting

If you encounter a `PostgrestException` with a 401 code, it indicates an invalid Supabase API key. Check your `.env` file to ensure you've entered the correct credentials from the Supabase dashboard.

Odoo x Gujarat Vidhyapith 
Hackathon '25

Team 25 

video link: https://drive.google.com/drive/folders/19nWJHweTjhogcyqt6xxbqKAUEKoUxeN5

Team Members: 
Ansh Patel
Raj Patel
Trushar Patel
Om Chauhan