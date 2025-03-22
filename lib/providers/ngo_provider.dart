import 'package:flutter/foundation.dart';

import '../models/ngo.dart';
import '../models/donation.dart';
import '../services/database_service.dart';

class NGOProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  
  List<NGO> _ngos = [];
  List<Donation> _userDonations = [];
  bool _isLoading = false;
  String? _error;
  
  // Getters
  List<NGO> get ngos => _ngos;
  List<Donation> get userDonations => _userDonations;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Load all NGOs
  Future<void> loadNGOs() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      final ngos = await _databaseService.getAllNGOs();
      _ngos = ngos;
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to load NGOs: ${e.toString()}';
      notifyListeners();
    }
  }
  
  // Load user donations
  Future<void> loadUserDonations(String userId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      final donations = await _databaseService.getDonationsByConsumerId(userId);
      _userDonations = donations;
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to load donations: ${e.toString()}';
      notifyListeners();
    }
  }
  
  // Create a donation
  Future<bool> createDonation({
    required String consumerId,
    required String ngoId,
    required double amount,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      // Get NGO details for the UI
      final ngo = await _databaseService.getNGOById(ngoId);
      
      // Create donation
      final donation = Donation.create(
        consumerId: consumerId,
        ngoId: ngoId,
        amount: amount,
        ngoName: ngo?.name,
        ngoLogo: ngo?.logoUrl,
      );
      
      // Save donation to database
      final savedDonation = await _databaseService.createDonation(donation);
      
      // Add to local list
      _userDonations.insert(0, savedDonation);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to create donation: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }
  
  // Get donation certificate (for future implementation)
  Future<String?> getDonationCertificate(String donationId) async {
    // This would be implemented to generate or fetch a certificate for a donation
    // For now, just return a placeholder
    return null;
  }
}