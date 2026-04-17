import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/product_service.dart';
import '../services/cart_service.dart';
import '../services/auth_service.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/category_tabs.dart';
import '../widgets/subcategory_circles.dart';
import '../widgets/promo_banner.dart';
import '../widgets/product_card.dart';
import '../widgets/bottom_nav_bar.dart';
import '../models/product.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _navIndex = 0;
  String _selectedCategory = '';

  final List<String> _mainCategories = [
    'Femenino',
    'Masculino',
    'Infantil',
    'Deportes',
  ];

  final List<SubcategoryItem> _subcategories = [
    SubcategoryItem(
      label: 'Tenis Mujer',
      icon: Icons.directions_run,
      bgColor: const Color(0xFFE8D5D5),
    ),
    SubcategoryItem(
      label: 'Tenis Hombre',
      icon: Icons.sports_handball,
      bgColor: const Color(0xFFD5E0F0),
    ),
    SubcategoryItem(
      label: 'Sneakers',
      icon: Icons.accessibility_new,
      bgColor: const Color(0xFFE8E8E8),
    ),
    SubcategoryItem(
      label: 'Ropa Hombre',
      icon: Icons.checkroom,
      bgColor: const Color(0xFFD5E8F0),
    ),
    SubcategoryItem(
      label: 'Ropa Mujer',
      icon: Icons.dry_cleaning,
      bgColor: const Color(0xFFF0D5E8),
    ),
    SubcategoryItem(
      label: 'Accesorios',
      icon: Icons.watch,
      bgColor: const Color(0xFFE8F0D5),
    ),
  ];

  final List<PromoBanner> _banners = [
    PromoBanner(
      title: 'MADRES',
      subtitle: 'Dia de las',
      price: '\$179.900',
      bgColor: const Color(0xFF2E7D5E),
      accentColor: const Color(0xFFF8C8D0),
    ),
    PromoBanner(
      title: 'VERANO',
      subtitle: 'Nueva coleccion',
      price: '\$99.900',
      bgColor: const Color(0xFF1565C0),
      accentColor: const Color(0xFFFFEB3B),
    ),
    PromoBanner(
      title: 'DEPORTES',
      subtitle: 'Lo mejor en',
      price: '\$249.900',
      bgColor: const Color(0xFFB71C1C),
      accentColor: const Color(0xFFFFFFFF),
    ),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductService>().fetchProducts();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    context.read<ProductService>().fetchProducts(
          search: value.isEmpty ? null : value,
          category: _selectedCategory.isEmpty ? null : _selectedCategory,
        );
  }

  void _onCategorySelected(String category) {
    setState(() => _selectedCategory = category);
    context.read<ProductService>().fetchProducts(
          category: category.isEmpty ? null : category,
          search: _searchController.text.isEmpty ? null : _searchController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Consumer<CartService>(
              builder: (_, cart, __) => SearchBarWidget(
                controller: _searchController,
                onChanged: _onSearchChanged,
                cartCount: cart.itemCount,
                onCartTap: () {},
              ),
            ),
            Expanded(
              child: _navIndex == 0
                  ? _HomeContent(
                      mainCategories: _mainCategories,
                      subcategories: _subcategories,
                      banners: _banners,
                      onCategorySelected: _onCategorySelected,
                    )
                  : const _PlaceholderScreen(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _navIndex,
        onTap: (i) => setState(() => _navIndex = i),
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  final List<String> mainCategories;
  final List<SubcategoryItem> subcategories;
  final List<PromoBanner> banners;
  final ValueChanged<String>? onCategorySelected;

  const _HomeContent({
    required this.mainCategories,
    required this.subcategories,
    required this.banners,
    this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          CategoryTabs(
            categories: mainCategories,
            onSelected: onCategorySelected,
          ),
          const SizedBox(height: 16),
          SubcategoryCircles(
            items: subcategories,
            onTap: (label) {
              onCategorySelected?.call(label);
            },
          ),
          const SizedBox(height: 16),
          PromoBannerCarousel(banners: banners),
          const SizedBox(height: 24),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Te puede gustar',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const _ProductsSection(),
          const SizedBox(height: 24),
          _SecondaryBanner(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _ProductsSection extends StatelessWidget {
  const _ProductsSection();

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductService>(
      builder: (_, service, __) {
        if (service.isLoading) {
          return const SizedBox(
            height: 260,
            child: Center(
              child: CircularProgressIndicator(color: Colors.black),
            ),
          );
        }

        if (service.error != null) {
          return SizedBox(
            height: 260,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.wifi_off, size: 40, color: Colors.grey),
                  const SizedBox(height: 8),
                  Text(
                    'No se pudo conectar al servidor',
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Verifica que el backend esté corriendo',
                    style: TextStyle(color: Colors.grey[400], fontSize: 12),
                  ),
                ],
              ),
            ),
          );
        }

        if (service.products.isEmpty) {
          return SizedBox(
            height: 260,
            child: Center(
              child: _MockProductRow(),
            ),
          );
        }

        return SizedBox(
          height: 260,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: service.products.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: ProductCard(
                  product: service.products[index],
                  onAddToCart: () async {
                    final auth = context.read<AuthService>();
                    if (!auth.isAuthenticated) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Inicia sesion para agregar al carrito'),
                        ),
                      );
                      return;
                    }
                    try {
                      await context
                          .read<CartService>()
                          .addToCart(service.products[index].id);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Producto agregado al carrito'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(e.toString())),
                        );
                      }
                    }
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _MockProductRow extends StatelessWidget {
  final List<_MockProduct> mockProducts = const [
    _MockProduct('Tenis Reebok Zig Rise Marfil', '\$ 345.900', '-11%', Icons.directions_run, Color(0xFFF5F5F5)),
    _MockProduct('Camiseta Nike Sb T-Shirt-Marr...', '\$ 155.240', '-20%', Icons.checkroom, Color(0xFFF0F0E8)),
    _MockProduct('Tenis asics Patriot 14 Azul', '\$ 279.900', null, Icons.sports_handball, Color(0xFFEEF0F5)),
  ];

  const _MockProductRow();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 260,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: mockProducts.length,
        itemBuilder: (_, i) => _MockProductCard(product: mockProducts[i]),
      ),
    );
  }
}

class _MockProduct {
  final String name;
  final String price;
  final String? discount;
  final IconData icon;
  final Color bgColor;

  const _MockProduct(this.name, this.price, this.discount, this.icon, this.bgColor);
}

class _MockProductCard extends StatelessWidget {
  final _MockProduct product;

  const _MockProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Container(
                  height: 150,
                  width: double.infinity,
                  color: product.bgColor,
                  child: Icon(product.icon, size: 64, color: const Color(0xFFBDBDBD)),
                ),
              ),
              if (product.discount != null)
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE91E63),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      product.discount!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.black87),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  product.price,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.black),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SecondaryBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Nueva Coleccion',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Running 2024',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Ver productos →',
                    style: TextStyle(
                      color: Color(0xFF64B5F6),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.directions_run,
              size: 70,
              color: Colors.white12,
            ),
            const SizedBox(width: 16),
          ],
        ),
      ),
    );
  }
}

class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Proximamente',
        style: TextStyle(fontSize: 18, color: Colors.grey),
      ),
    );
  }
}
