import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../core/config/api_config.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/helpers.dart';
import '../../models/product.dart';
import '../../providers/cart_provider.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _selectedImageIndex = 0;
  int _quantity = 1;
  bool _addedSuccess = false;

  List<String> get _images {
    if (widget.product.images.isNotEmpty) {
      return widget.product.images;
    }
    if (widget.product.imageUrl != null && widget.product.imageUrl!.isNotEmpty) {
      return [widget.product.imageUrl!];
    }
    return ['assets/producto_mate_16.svg'];
  }

  void _addToCart() {
    if (widget.product.stock <= 0) return;

    final cart = Provider.of<CartProvider>(context, listen: false);
    cart.addItem(widget.product, quantity: _quantity);

    setState(() {
      _addedSuccess = true;
    });

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(LucideIcons.check, color: AppTheme.success, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '$_quantity x "${widget.product.name}" agregado al carrito',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 2),
      ),
    );

    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) {
        setState(() {
          _addedSuccess = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final images = _images;
    final isAvailable = widget.product.stock > 0;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          constraints: const BoxConstraints(minWidth: 48, minHeight: 48), // Regla UX 3
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(widget.product.name),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              children: [
                // Contenido desplazable
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Visor principal de imagen
                        Container(
                          height: 300,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppTheme.surface,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: AppTheme.surfaceBorder),
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(24.0),
                                child: Image.network(
                                  ApiConfig.resolveImageUrl(images[_selectedImageIndex]),
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, _, _) => const Center(
                                    child: Icon(LucideIcons.package, color: AppTheme.woodLight, size: 64),
                                  ),
                                ),
                              ),
                              // Flecha anterior
                              if (images.length > 1)
                                Positioned(
                                  left: 12,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: AppTheme.surfaceCard.withValues(alpha: 0.85),
                                      shape: BoxShape.circle,
                                    ),
                                    child: IconButton(
                                      icon: const Icon(LucideIcons.chevronLeft, color: AppTheme.textLight),
                                      constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                                      onPressed: () {
                                        setState(() {
                                          _selectedImageIndex = (_selectedImageIndex - 1 + images.length) % images.length;
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              // Flecha siguiente
                              if (images.length > 1)
                                Positioned(
                                  right: 12,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: AppTheme.surfaceCard.withValues(alpha: 0.85),
                                      shape: BoxShape.circle,
                                    ),
                                    child: IconButton(
                                      icon: const Icon(LucideIcons.chevronRight, color: AppTheme.textLight),
                                      constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                                      onPressed: () {
                                        setState(() {
                                          _selectedImageIndex = (_selectedImageIndex + 1) % images.length;
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              // Badge de stock agotado
                              if (!isAvailable)
                                Positioned(
                                  top: 14,
                                  left: 14,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: AppTheme.danger.withValues(alpha: 0.9),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Text(
                                      'Agotado',
                                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12),
                                    ),
                                  ),
                                ),
                              // Contador de fotos
                              if (images.length > 1)
                                Positioned(
                                  bottom: 12,
                                  right: 14,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(alpha: 0.7),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      '${_selectedImageIndex + 1} / ${images.length}',
                                      style: const TextStyle(color: AppTheme.textMuted, fontSize: 11, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),

                        // Miniaturas si hay múltiples fotos
                        if (images.length > 1) ...[
                          const SizedBox(height: 14),
                          SizedBox(
                            height: 64,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: images.length,
                              separatorBuilder: (_, _) => const SizedBox(width: 10),
                              itemBuilder: (context, idx) {
                                final isSelected = idx == _selectedImageIndex;
                                return GestureDetector(
                                  onTap: () => setState(() => _selectedImageIndex = idx),
                                  child: Container(
                                    width: 64,
                                    height: 64,
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: AppTheme.surface,
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: isSelected ? AppTheme.woodLight : AppTheme.surfaceBorder,
                                        width: isSelected ? 2 : 1,
                                      ),
                                    ),
                                    child: Image.network(
                                      ApiConfig.resolveImageUrl(images[idx]),
                                      fit: BoxFit.contain,
                                      errorBuilder: (_, _, _) => const Icon(LucideIcons.image, size: 20, color: AppTheme.textMuted),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],

                        const SizedBox(height: 20),

                        // Categoría
                        if (widget.product.category != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                            decoration: BoxDecoration(
                              color: AppTheme.woodPrimary.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppTheme.woodPrimary.withValues(alpha: 0.3)),
                            ),
                            child: Text(
                              widget.product.category!.name.toUpperCase(),
                              style: const TextStyle(
                                color: AppTheme.woodLight,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),

                        const SizedBox(height: 10),

                        // Nombre del Producto
                        Text(
                          widget.product.name,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.textLight,
                            height: 1.25,
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Precio y Badge de Stock
                        Row(
                          children: [
                            Text(
                              Helpers.formatCurrency(widget.product.price),
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                color: AppTheme.woodLight,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: isAvailable ? AppTheme.success.withValues(alpha: 0.15) : AppTheme.danger.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isAvailable ? AppTheme.success.withValues(alpha: 0.3) : AppTheme.danger.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isAvailable ? LucideIcons.check : LucideIcons.x,
                                    size: 14,
                                    color: isAvailable ? AppTheme.success : AppTheme.danger,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    isAvailable ? 'En Stock (${widget.product.stock})' : 'Sin Stock',
                                    style: TextStyle(
                                      color: isAvailable ? AppTheme.success : AppTheme.danger,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),
                        const Divider(color: AppTheme.surfaceBorder, thickness: 1),
                        const SizedBox(height: 16),

                        // Descripción
                        const Text(
                          'Descripción del Producto',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textLight,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.product.description,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppTheme.textMuted,
                            height: 1.5,
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Selector de Cantidad
                        if (isAvailable) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Cantidad a ordenar:',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textLight,
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  color: AppTheme.surface,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: AppTheme.surfaceBorder),
                                ),
                                child: Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(LucideIcons.minus, size: 16, color: AppTheme.woodLight),
                                      constraints: const BoxConstraints(minWidth: 48, minHeight: 48), // Regla UX 3
                                      onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
                                    ),
                                    Container(
                                      constraints: const BoxConstraints(minWidth: 40),
                                      alignment: Alignment.center,
                                      child: Text(
                                        '$_quantity',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w800,
                                          color: AppTheme.textLight,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(LucideIcons.plus, size: 16, color: AppTheme.woodLight),
                                      constraints: const BoxConstraints(minWidth: 48, minHeight: 48), // Regla UX 3
                                      onPressed: _quantity < widget.product.stock ? () => setState(() => _quantity++) : null,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),

                // ZONA DEL PULGAR (Regla UX 2): Botón de Acción Principal Fijo en la Base
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: AppTheme.surfaceCard,
                    border: Border(top: BorderSide(color: AppTheme.surfaceBorder)),
                  ),
                  child: ElevatedButton(
                    onPressed: isAvailable ? _addToCart : null,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 54), // Regla UX 3
                      backgroundColor: _addedSuccess ? AppTheme.success : AppTheme.woodPrimary,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _addedSuccess ? LucideIcons.check : LucideIcons.shoppingBag,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          _addedSuccess
                              ? '¡Agregado al Carrito!'
                              : (isAvailable ? 'Agregar al Carrito de Compras' : 'Producto Sin Stock'),
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                        ),
                      ],
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
}
