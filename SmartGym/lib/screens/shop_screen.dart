import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../models/category_model.dart';
import '../../models/product_model.dart';
import '../../services/ecommerce_service.dart';
import '../constants/app_theme.dart';
import '../widgets/scale_tap.dart';
import 'cart_screen.dart';
import 'checkout_screen.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  final EcommerceService _service = EcommerceService();
  List<ProductCategory> _categories = [];
  List<Product> _products = [];
  bool _isLoading = true;
  int? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  
  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // Modified load data to use current state
  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final cats = await _service.fetchCategories();
    final prods = await _service.fetchProducts(
      categoryId: _selectedCategoryId, 
      searchQuery: _searchController.text
    );
    if (mounted) {
      setState(() {
        _categories = cats;
        _products = prods;
        _isLoading = false;
      });
    }
  }

  Future<void> _onCategorySelected(int? id) async {
    setState(() {
      _selectedCategoryId = id;
      _isLoading = true;
    });
    // Keep search query when changing category
    final prods = await _service.fetchProducts(
      categoryId: id, 
      searchQuery: _searchController.text
    );
    if (mounted) {
      setState(() {
        _products = prods;
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _performSearch();
    });
  }

  Future<void> _performSearch() async {
    setState(() => _isLoading = true);
    final prods = await _service.fetchProducts(
      categoryId: _selectedCategoryId, 
      searchQuery: _searchController.text
    );
    if (mounted) {
      setState(() {
        _products = prods;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.primaryGradient,
          ),
        ),
        title: const Text("Cửa hàng SmartGym", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: ScaleTap(
          onTap: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacementNamed(context, '/home');
            }
          },
          child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
        ),
        actions: [
          ScaleTap(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen())),
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.shopping_cart_outlined, color: Colors.white, size: 22),
            ),
          )
        ],
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm sản phẩm...',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: _isLoading && _products.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Categories
                Container(
                  height: 60,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _categories.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        final isSelected = _selectedCategoryId == null;
                        return _buildCategoryChip("Tất cả", isSelected, () => _onCategorySelected(null));
                      }
                      final cat = _categories[index - 1];
                      final isSelected = _selectedCategoryId == cat.id;
                      return _buildCategoryChip(cat.name, isSelected, () => _onCategorySelected(cat.id));
                    },
                  ),
                ),
                
                // Products Grid with Staggered Animation
                Expanded(
                  child: AnimationLimiter(
                    child: GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.65, 
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: _products.length,
                      itemBuilder: (context, index) {
                        return AnimationConfiguration.staggeredGrid(
                          position: index,
                          duration: const Duration(milliseconds: 500),
                          columnCount: 2,
                          child: SlideAnimation(
                            verticalOffset: 50.0,
                            child: FadeInAnimation(
                              child: ProductItem(
                                product: _products[index],
                                onAddToCart: _addToCart,
                                onBuyNow: _buyNow,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildCategoryChip(String label, bool isSelected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: ScaleTap(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.white,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: isSelected ? Colors.transparent : Colors.grey.withOpacity(0.2),
            ),
            boxShadow: isSelected 
              ? [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6))] 
              : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.textSecondary,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> _addToCart(Product product, {int quantity = 1}) async {
    final success = await _service.addToCart(product.id, quantity);
    if (!mounted) return success;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_outline, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(child: Text("Đã thêm ${product.name} vào giỏ")),
            ],
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
          elevation: 4,
          duration: const Duration(seconds: 1),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi thêm vào giỏ"), backgroundColor: AppColors.error, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), margin: EdgeInsets.all(16)),
      );
    }
    return success;
  }

  Future<void> _buyNow(Product product, int quantity) async {
    // 1. Add to cart
    final added = await _addToCart(product, quantity: quantity);
    if (!added) return;

    // 2. Fetch updated cart to get total
    try {
      final cartItems = await _service.fetchCart();
      double total = 0;
      for (var item in cartItems) {
        if (item.product != null) {
          total += item.product!.price * item.quantity;
        }
      }

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => CheckoutScreen(totalAmount: total)),
      );
    } catch (e) {
      print("Error preparing checkout: $e");
    }
  }
}

class ProductItem extends StatefulWidget {
  final Product product;
  final Function(Product, {int quantity}) onAddToCart;
  final Function(Product, int quantity) onBuyNow;

  const ProductItem({
    super.key,
    required this.product,
    required this.onAddToCart,
    required this.onBuyNow,
  });

  @override
  State<ProductItem> createState() => _ProductItemState();
}

class _ProductItemState extends State<ProductItem> {
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

    return ScaleTap(
      onTap: () {
        // Optional: Open detail view
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 20,
              offset: const Offset(0, 8),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Expanded(
              flex: 5,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    child: SizedBox(
                      width: double.infinity,
                      child: widget.product.imageUrl.isNotEmpty
                          ? Image.network(widget.product.imageUrl, fit: BoxFit.cover)
                          : Container(
                              color: Colors.grey[50],
                              child: Icon(Icons.inventory_2_outlined, size: 40, color: Colors.grey[300]),
                            ),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)],
                      ),
                      child: const Icon(Icons.favorite_border, size: 16, color: Colors.grey),
                    ),
                  )
                ],
              ),
            ),
      
            // Info & Controls
            Expanded(
              flex: 6,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Title & Price
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.product.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary, height: 1.2),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          currencyFormat.format(widget.product.price),
                          style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 15),
                        ),
                      ],
                    ),
      
                    // Quantity Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Số lượng", style: TextStyle(fontSize: 11, color: Colors.grey[500], fontWeight: FontWeight.w500)),
                        Container(
                          height: 26,
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              _buildQtyBtn(Icons.remove, () {
                                if (_quantity > 1) setState(() => _quantity--);
                              }),
                              SizedBox(
                                width: 24,
                                child: Text('$_quantity', 
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                ),
                              ),
                              _buildQtyBtn(Icons.add, () {
                                setState(() => _quantity++);
                              }),
                            ],
                          ),
                        ),
                      ],
                    ),
      
                    const SizedBox(height: 8),
      
                    // Actions
                    Row(
                      children: [
                        ScaleTap(
                          onTap: () => widget.onAddToCart(widget.product, quantity: _quantity),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.add_shopping_cart, color: AppColors.primary, size: 18),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ScaleTap(
                            onTap: () => widget.onBuyNow(widget.product, _quantity),
                            child: Container(
                              height: 38,
                              decoration: BoxDecoration(
                                gradient: AppColors.primaryGradient,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
                              ),
                              alignment: Alignment.center,
                              child: const Text("Mua ngay", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQtyBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Icon(icon, size: 14, color: Colors.grey[600]),
      ),
    );
  }
}
