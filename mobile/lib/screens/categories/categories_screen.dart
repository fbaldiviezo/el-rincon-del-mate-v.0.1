import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../core/config/api_config.dart';
import '../../core/theme/app_theme.dart';
import '../../models/category.dart';
import '../../providers/catalog_provider.dart';
import 'category_products_screen.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final catalog = Provider.of<CatalogProvider>(context);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Categorías'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.rotateCw),
            tooltip: 'Actualizar categorías',
            constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
            onPressed: () => catalog.init(),
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (catalog.isLoading) {
              return const Center(child: CircularProgressIndicator(color: AppTheme.woodPrimary));
            }

            if (catalog.categories.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(LucideIcons.layers, size: 40, color: AppTheme.woodLight),
                    const SizedBox(height: 16),
                    const Text('No hay categorías disponibles', style: TextStyle(color: AppTheme.textLight, fontSize: 16)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(minimumSize: const Size(140, 48)),
                      onPressed: () => catalog.init(),
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              color: AppTheme.woodPrimary,
              onRefresh: () => catalog.init(),
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                itemCount: catalog.categories.length,
                separatorBuilder: (_, _) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final cat = catalog.categories[index];
                  return _buildCategoryCard(context, cat);
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, Category cat) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => CategoryProductsScreen(category: cat)),
        );
      },
      child: Container(
        height: 160,
        decoration: BoxDecoration(
          color: AppTheme.surfaceCard,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppTheme.surfaceBorder),
        ),
        child: Stack(
          children: [
            // Contenido con texto y badges
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.woodPrimary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          cat.productsCount > 0 ? '${cat.productsCount} PRODUCTOS' : 'COLECCIÓN',
                          style: const TextStyle(
                            color: AppTheme.woodLight,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        cat.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.textLight,
                        ),
                      ),
                      if (cat.description != null && cat.description!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        SizedBox(
                          width: 200,
                          child: Text(
                            cat.description!,
                            style: const TextStyle(fontSize: 12, color: AppTheme.textMuted, height: 1.3),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),

                  // Botón explorador táctil (mínimo 48x48)
                  Row(
                    children: const [
                      Text(
                        'Explorar colección',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.woodLight,
                        ),
                      ),
                      SizedBox(width: 6),
                      Icon(LucideIcons.arrowRight, size: 16, color: AppTheme.woodLight),
                    ],
                  ),
                ],
              ),
            ),

            // Imagen decorativa a la derecha
            Positioned(
              right: 14,
              bottom: 14,
              top: 14,
              child: SizedBox(
                width: 110,
                child: Image.network(
                  ApiConfig.resolveImageUrl(cat.imageUrl),
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) => const Icon(LucideIcons.package, size: 48, color: AppTheme.woodLight),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
