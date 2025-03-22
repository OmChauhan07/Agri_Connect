import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/ngo.dart';
import '../../providers/auth_provider.dart';
import '../../providers/ngo_provider.dart';
import '../../widgets/ngo_card.dart';
import '../../widgets/donation_history_item.dart';
import '../../utils/constants.dart';

class DonationScreen extends StatefulWidget {
  const DonationScreen({Key? key}) : super(key: key);

  @override
  State<DonationScreen> createState() => _DonationScreenState();
}

class _DonationScreenState extends State<DonationScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _amountController = TextEditingController();
  NGO? _selectedNGO;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _amountController.dispose();
    super.dispose();
  }
  
  Future<void> _loadData() async {
    final ngoProvider = Provider.of<NGOProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    await ngoProvider.loadNGOs();
    if (authProvider.currentUser != null) {
      await ngoProvider.loadUserDonations(authProvider.currentUser!.id);
    }
  }

  Future<void> _makeDonation() async {
    final ngoProvider = Provider.of<NGOProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    if (_selectedNGO == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an NGO')),
      );
      return;
    }
    
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }
    
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Processing donation...'),
          ],
        ),
      ),
    );
    
    final success = await ngoProvider.createDonation(
      consumerId: authProvider.currentUser!.id,
      ngoId: _selectedNGO!.id,
      amount: amount,
    );
    
    // Pop loading dialog
    Navigator.pop(context);
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Donation successful! Thank you for your contribution.')),
      );
      
      setState(() {
        _selectedNGO = null;
        _amountController.clear();
      });
      
      // Switch to donation history tab
      _tabController.animateTo(1);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ngoProvider.error ?? 'Failed to process donation. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Donations'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Donate'),
            Tab(text: 'Donation History'),
          ],
        ),
      ),
      body: Consumer<NGOProvider>(
        builder: (context, ngoProvider, child) {
          if (ngoProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (ngoProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error: ${ngoProvider.error}',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadData,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          
          return TabBarView(
            controller: _tabController,
            children: [
              // Donate Tab
              _buildDonateTab(ngoProvider),
              
              // History Tab
              _buildHistoryTab(ngoProvider),
            ],
          );
        },
      ),
    );
  }
  
  Widget _buildDonateTab(NGOProvider ngoProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Support Sustainable Agriculture',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Your donations help NGOs working with farmers to promote sustainable agriculture and food security.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Select an NGO',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: ngoProvider.ngos.length,
            itemBuilder: (context, index) {
              final ngo = ngoProvider.ngos[index];
              final isSelected = _selectedNGO?.id == ngo.id;
              
              return NGOCard(
                ngo: ngo,
                isSelected: isSelected,
                onTap: () {
                  setState(() {
                    _selectedNGO = isSelected ? null : ngo;
                  });
                },
              );
            },
          ),
          const SizedBox(height: 24),
          const Text(
            'Donation Amount',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              hintText: 'Enter amount',
              prefixIcon: Icon(Icons.currency_rupee),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _makeDonation,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Donate Now',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildHistoryTab(NGOProvider ngoProvider) {
    if (ngoProvider.userDonations.isEmpty) {
      return const Center(
        child: Text(
          'You have not made any donations yet.',
          style: TextStyle(fontSize: 16),
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: ngoProvider.userDonations.length,
      itemBuilder: (context, index) {
        final donation = ngoProvider.userDonations[index];
        return DonationHistoryItem(donation: donation);
      },
    );
  }
}