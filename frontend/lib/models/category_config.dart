class CategoryConfig {
  final String id;
  final String name;
  final int order;
  final bool isVisible;

  CategoryConfig({
    required this.id,
    required this.name,
    required this.order,
    required this.isVisible,
  });

  factory CategoryConfig.fromJson(Map<String, dynamic> json) {
    return CategoryConfig(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      order: json['order'] ?? 0,
      isVisible: json['isVisible'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'order': order,
      'isVisible': isVisible,
    };
  }
}
