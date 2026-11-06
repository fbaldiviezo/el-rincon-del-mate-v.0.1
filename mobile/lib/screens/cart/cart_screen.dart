import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../core/config/api_config.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/helpers.dart';
import '../../providers/cart_provider.dart';
import '../checkout/checkout_address_screen.dart';

class CartScreen extends StatelessWidget {
  final VoidCallback? onExploreCatalog;

  const CartScreen({super.key, this.onExploreCatalog});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Carrito de Compras'),
        actions: [
          if (cart.items.isNotEmpty)
            IconButton(
              icon: const Icon(LucideIcons.trash2, color: AppTheme.danger),
              tooltip: 'Vaciar carrito',
              constraints: const BoxConstraints(minWidth: 48, minHeight: 48), // Regla UX 3
              onPressed: () async {
                // Confirmación segura (Regla UX 6)
                final confirmed = await Helpers.showConfirmDialog(
                  context: context,
                  title: 'Vaciar Carrito',
                  message: '¿Estás seguro de que deseas eliminar todos los productos del carrito?',
                  confirmLabel: 'Vaciar Todo',
                );
                if (confirmed == true) {
                  await cart.clearCart();
                }
              },
            ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (cart.items.isEmpty) {
              return _buildEmptyCart(context);
            }

            return Column(
              children: [
                // Lista de productos
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: cart.items.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = cart.items[index];
                      return _buildCartItemCard(context, item, cart);
                    },
                  ),
                ),

                // Resumen de la Compra y ZONA DEL PULGAR (Regla UX 2)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: AppTheme.surfaceCard,
                    border: Border(top: BorderSide(color: AppTheme.surfaceBorder)),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Subtotal y envío
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Cantidad de ítems (${cart.totalItems}):',
                            style: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
                          ),
                          Text(
                            Helpers.formatCurrency(cart.totalPrice),
                            style: const TextStyle(color: AppTheme.textLight, fontWeight: FontWeight.w700, fontSize: 13),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text('Costo de Envío:', style: TextStyle(color: AppTheme.textMuted, fontSize: 13)),
                          Text(
                            '¡GRATIS!',
                            style: TextStyle(
                              color: AppTheme.success,
                              fontWeight: FontWeight.w900,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const Divider(color: AppTheme.surfaceBorder, height: 1),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total a Pagar:',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppTheme.textLight),
                          ),
                          Text(
                            Helpers.formatCurrency(cart.totalPrice),
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppTheme.woodLight),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Botón Primario Sticky en zona del pulgar
                      ElevatedButton.icon(
                        icon: const Icon(LucideIcons.arrowRight, size: 18),
                        label: const Text('Continuar con Datos de Envío'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 54), // Regla UX 3
                        ),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const CheckoutAddressScreen()),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildCartItemCard(BuildContext context, dynamic item, CartProvider cart) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.surfaceBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Imagen miniatura
          Container(
            width: 72,
            height: 72,
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.surfaceBorder),
            ),
            child: Image.network(
              ApiConfig.resolveImageUrl(item.product.imageUrl),
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => const Icon(LucideIcons.package, color: AppTheme.woodLight, size: 28),
            ),
          ),
          const SizedBox(width: 14),

          // Detalles y precio
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textLight,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  Helpers.formatCurrency(item.product.price),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.woodLight,
                  ),
                ),
                const SizedBox(height: 8),

                // Controles de cantidad
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppTheme.surfaceBorder),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(LucideIcons.minus, size: 14, color: AppTheme.woodLight),
                            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                            onPressed: () {
                              if (item.quantity > 1) {
                                cart.updateQuantity(item.product.id, item.quantity - 1);
                              } else {
                                // Regla UX 6: Confirmación al quitar a 0
                                cart.confirmAndRemoveItem(context, item.product.id);
                              }
                            },
                          ),
                          Container(
                            constraints: const BoxConstraints(minWidth: 32),
                            alignment: Alignment.center,
                            child: Text(
                              '${item.quantity}',
                              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppTheme.textLight),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(LucideIcons.plus, size: 14, color: AppTheme.woodLight),
                            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                            onPressed: () {
                              if (item.quantity < item.product.stock) {
                                cart.updateQuantity(item.product.id, item.quantity + 1);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),

                    // Subtotal
                    Text(
                      Helpers.formatCurrency(item.subtotal),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.textLight,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Botón de eliminar con diálogo de seguridad (Regla UX 6)
          IconButton(
            icon: const Icon(LucideIcons.trash2, color: AppTheme.danger, size: 18),
            constraints: const BoxConstraints(minWidth: 48, minHeight: 48), // Regla UX 3
            onPressed: () => cart.confirmAndRemoveItem(context, item.product.id),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: AppTheme.woodPrimary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.woodPrimary.withValues(alpha: 0.25)),
              ),
              child: const Icon(LucideIcons.shoppingBag, color: AppTheme.woodLight, size: 44),
            ),
            const SizedBox(height: 24),
            const Text(
              'Tu carrito está vacío',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: AppTheme.textLight,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Aún no has agregado productos a tu orden. Explora nuestras colecciones de mates y accesorios.',
              style: TextStyle(fontSize: 13, color: AppTheme.textMuted, height: 1.4),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(LucideIcons.arrowLeft, size: 18),
              label: const Text('Explorar Catálogo'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(220, 50), // Regla UX 3
              ),
              onPressed: onExploreCatalog,
            ),
          ],
        ),
      ),
    );
  }
}
