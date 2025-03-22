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
    // Set loading state first, then notify
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Fetch data
      final ngos = await _databaseService.getAllNGOs();

      // Update state with fetched data
      _ngos = ngos;
      _isLoading = false;
      _error = null;

      // Notify after state is updated
      notifyListeners();
    } catch (e) {
      // Handle error
      _isLoading = false;
      _error = 'Failed to load NGOs: ${e.toString()}';
      notifyListeners();
    }
  }

  // Load user donations
  Future<void> loadUserDonations(String userId) async {
    // Set loading state first
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final donations = await _databaseService.getDonationsByConsumerId(userId);

      // Update state
      _userDonations = donations;
      _isLoading = false;

      // Notify listeners after state is updated
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
    // Set loading state first
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
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

      // Update state
      _userDonations.insert(0, savedDonation);
      _isLoading = false;

      // Notify after state is updated
      notifyListeners();
      return true;
    } catch (e) {
      // Handle error
      _isLoading = false;
      _error = 'Failed to create donation: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  // Get donation certificate
  Future<Donation?> getDonationById(String donationId) async {
    try {
      // Check if the donation is already in the local list
      final localDonation = _userDonations.firstWhere(
        (donation) => donation.id == donationId,
        orElse: () => Donation(
            id: '',
            consumerId: '',
            ngoId: '',
            amount: 0,
            donationDate: DateTime.now()),
      );

      if (localDonation.id.isNotEmpty) {
        return localDonation;
      }

      // If not found locally, fetch from the database
      try {
        final donation = await _databaseService.getDonationById(donationId);
        if (donation != null) {
          // Add to local list if not already there
          if (!_userDonations.any((d) => d.id == donation.id)) {
            // Create a new list to avoid modifying during build
            List<Donation> updatedDonations = List.from(_userDonations);
            updatedDonations.add(donation);

            // Update the list and notify listeners
            _userDonations = updatedDonations;
            notifyListeners();
          }
          return donation;
        }
      } catch (e) {
        _error = 'Failed to fetch donation: ${e.toString()}';
        notifyListeners();
      }

      return null;
    } catch (e) {
      _error = 'Failed to get donation: ${e.toString()}';
      notifyListeners();
      return null;
    }
  }
}
