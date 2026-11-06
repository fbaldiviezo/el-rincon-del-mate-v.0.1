import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../core/config/api_config.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/helpers.dart';
import '../../models/product.dart';
import '../../providers/catalog_provider.dart';
import '../../providers/cart_provider.dart';
import '../product_detail/product_detail_screen.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query, CatalogProvider provider) {
    provider.setSearchQuery(query);
  }

  @override
  Widget build(BuildContext context) {
    final catalog = Provider.of<CatalogProvider>(context);
    final cart = Provider.of<CartProvider>(context, listen: false);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Catálogo de Productos'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.rotateCw),
            tooltip: 'Actualizar catálogo',
            constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
            onPressed: () => catalog.init(),
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              children: [
                // Barra de Búsqueda y Filtros
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  color: AppTheme.background,
                  child: Column(
                    children: [
                      // Buscador
                      TextField(
                        controller: _searchCtrl,
                        onChanged: (val) => _onSearchChanged(val, catalog),
                        decoration: InputDecoration(
                          hintText: 'Buscar por nombre, tipo o material...',
                          prefixIcon: const Icon(LucideIcons.search, color: AppTheme.woodLight, size: 20),
                          suffixIcon: _searchCtrl.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(LucideIcons.x, color: AppTheme.textMuted, size: 18),
                                  constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                                  onPressed: () {
                                    _searchCtrl.clear();
                                    catalog.setSearchQuery('');
                                  },
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Chips horizontales de categorías
                      SizedBox(
                        height: 40,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            _buildCategoryChip(
                              label: 'Todas',
                              isSelected: catalog.selectedCategoryId == null,
                              onTap: () => catalog.setSelectedCategory(null),
                            ),
                            ...catalog.categories.map((cat) {
                              final isSelected = catalog.selectedCategoryId == cat.id;
                              return Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: _buildCategoryChip(
                                  label: cat.name,
                                  isSelected: isSelected,
                                  onTap: () => catalog.setSelectedCategory(isSelected ? null : cat.id),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const Divider(height: 1, color: AppTheme.surfaceBorder),

                // Lista de productos o estados
                Expanded(
                  child: catalog.isLoadingProducts
                      ? const Center(
                          child: CircularProgressIndicator(color: AppTheme.woodPrimary),
                        )
                      : catalog.products.isEmpty
                          ? _buildEmptyState(catalog)
                          : RefreshIndicator(
                              color: AppTheme.woodPrimary,
                              onRefresh: () => catalog.init(),
                              child: GridView.builder(
                                padding: const EdgeInsets.all(16),
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  mainAxisSpacing: 14,
                                  crossAxisSpacing: 14,
                                  childAspectRatio: 0.65,
                                ),
                                itemCount: catalog.products.length,
                                itemBuilder: (context, index) {
                                  final product = catalog.products[index];
                                  return _buildProductCard(context, product, cart);
                                },
                              ),
                            ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildCategoryChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 40, minWidth: 48), // Regla UX 3
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.woodPrimary : AppTheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppTheme.woodLight : AppTheme.surfaceBorder,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppTheme.textMuted,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(CatalogProvider catalog) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.woodPrimary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppTheme.woodPrimary.withValues(alpha: 0.25)),
            ),
            child: const Icon(LucideIcons.package, color: AppTheme.woodLight, size: 36),
          ),
          const SizedBox(height: 20),
          const Text(
            'No se encontraron productos',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppTheme.textLight,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'No hay artículos que coincidan con tus criterios de búsqueda. Prueba restableciendo los filtros.',
            style: TextStyle(fontSize: 13, color: AppTheme.textMuted, height: 1.4),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(LucideIcons.rotateCw, size: 16),
            label: const Text('Restablecer Filtros'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(200, 48), // Regla UX 3
            ),
            onPressed: () {
              _searchCtrl.clear();
              catalog.resetFilters();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, Product product, CartProvider cart) {
    final isAvailable = product.stock > 0;

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product)),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surfaceCard,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppTheme.surfaceBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen del producto
            Expanded(
              flex: 5,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Image.network(
                      ApiConfig.resolveImageUrl(product.imageUrl),
                      fit: BoxFit.contain,
                      errorBuilder: (_, _, _) => const Icon(LucideIcons.package, color: AppTheme.woodLight, size: 36),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.75),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        Helpers.formatCurrency(product.price),
                        style: const TextStyle(
                          color: AppTheme.woodLight,
                          fontWeight: FontWeight.w900,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Detalles y Acción
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (product.category != null)
                          Text(
                            product.category!.name.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.woodLight,
                              letterSpacing: 0.5,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        const SizedBox(height: 2),
                        Text(
                          product.name,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textLight,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),

                    // Botón de Agregar Rápido (mínimo 48x48)
                    SizedBox(
                      width: double.infinity,
                      height: 48, // Regla UX 3
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 48),
                          backgroundColor: isAvailable ? AppTheme.woodPrimary : AppTheme.surface,
                          foregroundColor: isAvailable ? Colors.white : AppTheme.textMuted,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: isAvailable
                            ? () {
                                cart.addItem(product);
                                ScaffoldMessenger.of(context).clearSnackBars();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('"${product.name}" agregado al carrito'),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              }
                            : null,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              isAvailable ? LucideIcons.shoppingBag : LucideIcons.x,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              isAvailable ? 'Agregar' : 'Sin Stock',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                            ),
                          ],
                        ),
                      ),
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
}
