import 'package:flutter/material.dart';
import '../models/category_config.dart';
import 'api_client.dart';

class CategoryService extends ChangeNotifier {
  List<CategoryConfig> _categories = [];
  bool _isLoading = false;
  String? _error;

  List<CategoryConfig> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<String> get categoryNames => _categories.map((c) => c.name).toList();

  Future<void> fetchCategories({bool adminAll = false}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final path = adminAll ? '/categories/admin' : '/categories';
      final data = await ApiClient.get(path);
      _categories = (data['categories'] as List)
          .map((c) => CategoryConfig.fromJson(c))
          .toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<CategoryConfig> createCategory(String name) async {
    final data = await ApiClient.post('/categories', {'name': name});
    final category = CategoryConfig.fromJson(data['category']);
    _categories.add(category);
    _categories.sort((a, b) => a.order.compareTo(b.order));
    notifyListeners();
    return category;
  }

  Future<CategoryConfig> updateCategory(
      String id, Map<String, dynamic> updates) async {
    final data = await ApiClient.put('/categories/$id', updates);
    final updated = CategoryConfig.fromJson(data['category']);
    final index = _categories.indexWhere((c) => c.id == id);
    if (index != -1) {
      _categories[index] = updated;
      notifyListeners();
    }
    return updated;
  }

  Future<void> deleteCategory(String id) async {
    await ApiClient.delete('/categories/$id');
    _categories.removeWhere((c) => c.id == id);
    notifyListeners();
  }

  Future<void> reorderCategories(List<String> orderedIds) async {
    final data = await ApiClient.post('/categories/reorder', {'orderedIds': orderedIds});
    _categories = (data['categories'] as List)
        .map((c) => CategoryConfig.fromJson(c))
        .toList();
    notifyListeners();
  }
}
