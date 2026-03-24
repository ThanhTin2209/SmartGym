import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_config.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';
import '../models/cart_model.dart';

class EcommerceService {
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // --- CATEGORIES ---
  Future<List<ProductCategory>> fetchCategories() async {
    try {
      final url = Uri.parse("${ApiConfig.baseUrl}/ProductCategory");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => ProductCategory.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print("Error fetching categories: $e");
      return [];
    }
  }

  // --- PRODUCTS ---
  Future<List<Product>> fetchProducts({int? categoryId, String? searchQuery}) async {
    try {
      String path = "${ApiConfig.baseUrl}/Product";
      Map<String, String> queryParams = {};
      
      if (categoryId != null) {
        queryParams['categoryId'] = categoryId.toString();
      }
      if (searchQuery != null && searchQuery.isNotEmpty) {
        queryParams['search'] = searchQuery;
      }
      
      final  uri = Uri.parse(path).replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        // Client-side filter if API doesn't support it (though backend usually should)
        var products = data.map((json) => Product.fromJson(json)).toList();
        // Since backend now supports server-side filtering, we can rely on it.
        // But if we want to be safe or if backend update isn't live yet:
        // if (categoryId != null) {
        //   products = products.where((p) => p.categoryId == categoryId).toList();
        // }
        // For now, trusting backend results as primary.
        return products;
      }
      return [];
    } catch (e) {
      print("Error fetching products: $e");
      return [];
    }
  }

  // --- CART ---
  Future<List<CartItem>> fetchCart() async {
    final token = await _getToken();
    if (token == null) return [];

    try {
      final url = Uri.parse("${ApiConfig.baseUrl}/Cart");
      final response = await http.get(url, headers: {
        "Authorization": "Bearer $token",
      });

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<dynamic> items = data['items'];
        return items.map((json) => CartItem.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print("Error fetching cart: $e");
      return [];
    }
  }

  Future<bool> addToCart(int productId, int quantity) async {
    final token = await _getToken();
    if (token == null) return false;

    try {
      final url = Uri.parse("${ApiConfig.baseUrl}/Cart");
      final body = jsonEncode({
        "productId": productId,
        "quantity": quantity
      });

      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: body,
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("Error adding to cart: $e");
      return false;
    }
  }

  Future<bool> removeFromCart(int cartItemId) async {
    final token = await _getToken();
    if (token == null) return false;

    try {
      final url = Uri.parse("${ApiConfig.baseUrl}/Cart/$cartItemId");
      final response = await http.delete(
        url,
        headers: {
          "Authorization": "Bearer $token",
        },
      );

      return response.statusCode == 204 || response.statusCode == 200;
    } catch (e) {
      print("Error removing from cart: $e");
      return false;
    }
  }
}
