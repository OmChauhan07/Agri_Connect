import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/product.dart';
import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';
import '../../utils/constants.dart';
import '../../utils/theme.dart';
import '../../widgets/product_card.dart';
import 'add_product_screen.dart';

class ProductListingScreen extends StatefulWidget {
  const ProductListingScreen({Key? key}) : super(key: key);

  @override
  State<ProductListingScreen> createState() => _ProductListingScreenState();
}

class _ProductListingScreenState extends State<ProductListingScreen> {
  bool _isLoading = true;
  bool _isGridView = true;
  String _filterOption = 'All';
  final TextEditingController _searchController = TextEditingController();
  List<Product> _filteredProducts = [];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
      if (user == null) return;

      final productProvider = Provider.of<ProductProvider>(context, listen: false);
      await productProvider.fetchFarmerProducts(user.id);
      
      // Apply initial filtering
      _applyFilters();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading products: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _applyFilters() {
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    final allProducts = productProvider.farmerProducts;
    final searchQuery = _searchController.text.toLowerCase();
    
    setState(() {
      _filteredProducts = allProducts.where((product) {
        // Apply search filter
        final matchesSearch = searchQuery.isEmpty ||
            product.name.toLowerCase().contains(searchQuery) ||
            product.description.toLowerCase().contains(searchQuery);
            
        // Apply category filter
        bool matchesFilter = true;
        if (_filterOption == 'Available') {
          matchesFilter = product.isAvailable;
        } else if (_filterOption == 'Out of Stock') {
          matchesFilter = !product.isAvailable || product.stockQuantity <= 0;
        }
        
        return matchesSearch && matchesFilter;
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
      body: Column(
        children: [
          // Search and Filter Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                // Search Field
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search products...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                  onChanged: (_) => _applyFilters(),
                ),
                const SizedBox(height: 16),
                
                // Filter and View Toggle Row
                Row(
                  children: [
                    // Filter Dropdown
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _filterOption,
                            icon: const Icon(Icons.filter_list),
                            isExpanded: true,
                            items: const [
                              DropdownMenuItem(
                                value: 'All',
                                child: Text('All Products'),
                              ),
                              DropdownMenuItem(
                                value: 'Available',
                                child: Text('Available'),
                              ),
                              DropdownMenuItem(
                                value: 'Out of Stock',
                                child: Text('Out of Stock'),
                              ),
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _filterOption = value;
                                });
                                _applyFilters();
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    
                    // View Toggle
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          // Grid View
                          InkWell(
                            onTap: () {
                              setState(() {
                                _isGridView = true;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: _isGridView
                                    ? AppColors.primaryColor
                                    : Colors.transparent,
                                borderRadius: const BorderRadius.horizontal(
                                  left: Radius.circular(9),
                                ),
                              ),
                              child: Icon(
                                Icons.grid_view,
                                color: _isGridView ? Colors.white : Colors.grey,
                              ),
                            ),
                          ),
                          // List View
                          InkWell(
                            onTap: () {
                              setState(() {
                                _isGridView = false;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: !_isGridView
                                    ? AppColors.primaryColor
                                    : Colors.transparent,
                                borderRadius: const BorderRadius.horizontal(
                                  right: Radius.circular(9),
                                ),
                              ),
                              child: Icon(
                                Icons.view_list,
                                color: !_isGridView ? Colors.white : Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Products List
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryColor,
                    ),
                  )
                : _filteredProducts.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inventory,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No products found',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const AddProductScreen(),
                                  ),
                                ).then((_) => _loadProducts());
                              },
                              icon: const Icon(Icons.add),
                              label: const Text('Add New Product'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryColor,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadProducts,
                        color: AppColors.primaryColor,
                        child: _isGridView
                            ? GridView.builder(
                                padding: const EdgeInsets.all(16),
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 0.75,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                ),
                                itemCount: _filteredProducts.length,
                                itemBuilder: (context, index) {
                                  final product = _filteredProducts[index];
                                  return ProductCard(
                                    product: product,
                                    isFarmerView: true,
                                    isGridView: true,
                                    onTap: () {
                                      // Navigate to edit product
                                      // TODO: Implement edit product screen
                                    },
                                  );
                                },
                              )
                            : ListView.separated(
                                padding: const EdgeInsets.all(16),
                                itemCount: _filteredProducts.length,
                                separatorBuilder: (context, index) => const SizedBox(height: 16),
                                itemBuilder: (context, index) {
                                  final product = _filteredProducts[index];
                                  return ProductCard(
                                    product: product,
                                    isFarmerView: true,
                                    isGridView: false,
                                    onTap: () {
                                      // Navigate to edit product
                                      // TODO: Implement edit product screen
                                    },
                                  );
                                },
                              ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryColor,
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddProductScreen()),
          ).then((_) => _loadProducts());
        },
      ),
    );
  }
}
