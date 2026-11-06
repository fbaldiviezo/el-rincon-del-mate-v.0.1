import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../providers/cart_provider.dart';
import 'home/home_screen.dart';
import 'catalog/catalog_screen.dart';
import 'categories/categories_screen.dart';
import 'cart/cart_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    final screens = [
      HomeScreen(onNavigateTab: _onTabSelected),
      const CatalogScreen(),
      const CategoriesScreen(),
      CartScreen(onExploreCatalog: () => _onTabSelected(1)),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      // ZONA DEL PULGAR (Regla UX 2): Barra inferior táctil accesible
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppTheme.surfaceCard,
          border: Border(top: BorderSide(color: AppTheme.surfaceBorder, width: 1)),
        ),
        child: NavigationBarTheme(
          data: NavigationBarThemeData(
            backgroundColor: AppTheme.surfaceCard,
            indicatorColor: AppTheme.woodPrimary.withValues(alpha: 0.25),
            labelTextStyle: WidgetStateProperty.resolveWith((states) {
              final isSelected = states.contains(WidgetState.selected);
              return TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                color: isSelected ? AppTheme.woodLight : AppTheme.textMuted,
              );
            }),
            iconTheme: WidgetStateProperty.resolveWith((states) {
              final isSelected = states.contains(WidgetState.selected);
              return IconThemeData(
                color: isSelected ? AppTheme.woodLight : AppTheme.textMuted,
                size: 22,
              );
            }),
          ),
          child: NavigationBar(
            height: 68,
            selectedIndex: _currentIndex,
            onDestinationSelected: _onTabSelected,
            destinations: [
              const NavigationDestination(
                icon: Icon(LucideIcons.home),
                selectedIcon: Icon(LucideIcons.home, color: AppTheme.woodLight),
                label: 'Inicio',
              ),
              const NavigationDestination(
                icon: Icon(LucideIcons.shoppingBag),
                selectedIcon: Icon(LucideIcons.shoppingBag, color: AppTheme.woodLight),
                label: 'Catálogo',
              ),
              const NavigationDestination(
                icon: Icon(LucideIcons.layers),
                selectedIcon: Icon(LucideIcons.layers, color: AppTheme.woodLight),
                label: 'Categorías',
              ),
              NavigationDestination(
                icon: Badge(
                  isLabelVisible: cart.totalItems > 0,
                  backgroundColor: AppTheme.woodPrimary,
                  textColor: Colors.white,
                  label: Text('${cart.totalItems}'),
                  child: const Icon(LucideIcons.shoppingCart),
                ),
                selectedIcon: Badge(
                  isLabelVisible: cart.totalItems > 0,
                  backgroundColor: AppTheme.woodPrimary,
                  textColor: Colors.white,
                  label: Text('${cart.totalItems}'),
                  child: const Icon(LucideIcons.shoppingCart, color: AppTheme.woodLight),
                ),
                label: 'Carrito',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
