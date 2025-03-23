import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/user.dart';
import '../../providers/auth_provider.dart';
import '../../utils/constants.dart';
import '../../utils/theme.dart';
import '../../utils/localization_helper.dart';
import '../../widgets/badge_icon.dart';

class AllFarmersScreen extends StatefulWidget {
  const AllFarmersScreen({Key? key}) : super(key: key);

  @override
  State<AllFarmersScreen> createState() => _AllFarmersScreenState();
}

class _AllFarmersScreenState extends State<AllFarmersScreen> {
  bool _isLoading = true;
  bool _isGridView = true;
  List<UserModel> _farmers = [];
  final TextEditingController _searchController = TextEditingController();
  List<UserModel> _filteredFarmers = [];

  @override
  void initState() {
    super.initState();
    _loadFarmers();
  }

  Future<void> _loadFarmers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // Get all farmers sorted by rating (highest first)
      _farmers = await authProvider.getFeaturedFarmers();
      _farmers.sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0));

      _applyFilters();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading farmers: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _applyFilters() {
    final searchQuery = _searchController.text.toLowerCase();

    setState(() {
      _filteredFarmers = _farmers.where((farmer) {
        // Apply search filter
        final matchesSearch = searchQuery.isEmpty ||
            (farmer.name != null &&
                farmer.name!.toLowerCase().contains(searchQuery)) ||
            (farmer.address != null &&
                farmer.address!.toLowerCase().contains(searchQuery));

        return matchesSearch;
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text('Top Rated Farmers'),
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        actions: [
          // Toggle view mode
          IconButton(
            icon: Icon(
              _isGridView ? Icons.view_list : Icons.grid_view,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search farmers...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                contentPadding: EdgeInsets.zero,
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onChanged: (_) => _applyFilters(),
            ),
          ),

          // Farmers List/Grid
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )
                : _filteredFarmers.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No farmers found',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    : _isGridView
                        ? _buildFarmersGrid()
                        : _buildFarmersList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFarmersGrid() {
    return RefreshIndicator(
      onRefresh: _loadFarmers,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: _filteredFarmers.length,
        itemBuilder: (context, index) {
          return _buildFarmerCard(_filteredFarmers[index]);
        },
      ),
    );
  }

  Widget _buildFarmersList() {
    return RefreshIndicator(
      onRefresh: _loadFarmers,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _filteredFarmers.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          return _buildFarmerListItem(_filteredFarmers[index]);
        },
      ),
    );
  }

  Widget _buildFarmerCard(UserModel farmer) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/farmer-detail',
          arguments: farmer.id,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            // Farmer Image
            Stack(
              alignment: Alignment.center,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: farmer.profileImage != null
                      ? NetworkImage(farmer.profileImage!)
                      : null,
                  child: farmer.profileImage == null
                      ? const Icon(
                          Icons.person,
                          size: 50,
                          color: Colors.grey,
                        )
                      : null,
                ),
                if (farmer.badgeType != null)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 2,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.eco,
                        color: farmer.badgeType == 'green'
                            ? Colors.green
                            : Colors.orange,
                        size: 18,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Farmer Name
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                farmer.name ?? 'Farmer',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 4),

            // Farmer Rating
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.star,
                  color: Colors.amber,
                  size: 18,
                ),
                const SizedBox(width: 4),
                Text(
                  '${farmer.rating?.toStringAsFixed(1) ?? '0.0'} (${farmer.totalRatings ?? 0})',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Address
            if (farmer.address != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 14,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        farmer.address!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFarmerListItem(UserModel farmer) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/farmer-detail',
          arguments: farmer.id,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
            ),
          ],
        ),
        child: Row(
          children: [
            // Farmer Image
            Padding(
              padding: const EdgeInsets.all(12),
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.grey[200],
                    backgroundImage: farmer.profileImage != null
                        ? NetworkImage(farmer.profileImage!)
                        : null,
                    child: farmer.profileImage == null
                        ? const Icon(
                            Icons.person,
                            size: 40,
                            color: Colors.grey,
                          )
                        : null,
                  ),
                  if (farmer.badgeType != null)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 2,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.eco,
                          color: farmer.badgeType == 'green'
                              ? Colors.green
                              : Colors.orange,
                          size: 16,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Farmer Details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Farmer Name
                    Text(
                      farmer.name ?? 'Farmer',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // Farmer Rating
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${farmer.rating?.toStringAsFixed(1) ?? '0.0'} (${farmer.totalRatings ?? 0} ratings)',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Farmer Address
                    if (farmer.address != null)
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              farmer.address!,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),

                    // Badge info
                    if (farmer.badgeType != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: farmer.badgeType == 'green'
                                ? Colors.green[50]
                                : Colors.orange[50],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            farmer.badgeType == 'green'
                                ? 'Certified Organic'
                                : 'Natural Farming',
                            style: TextStyle(
                              fontSize: 10,
                              color: farmer.badgeType == 'green'
                                  ? Colors.green[800]
                                  : Colors.orange[800],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // View Button
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: AppColors.primary,
                  ),
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/farmer-detail',
                      arguments: farmer.id,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
