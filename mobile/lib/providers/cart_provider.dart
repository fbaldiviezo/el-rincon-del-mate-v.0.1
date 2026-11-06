import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/cart_item.dart';
import '../services/storage_service.dart';
import '../core/utils/helpers.dart';
import '../core/theme/app_theme.dart';

class CartProvider extends ChangeNotifier {
  List<CartItem> _items = [];
  bool _isLoaded = false;

  List<CartItem> get items => _items;
  bool get isLoaded => _isLoaded;

  int get totalItems => _items.fold(0, (sum, it) => sum + it.quantity);

  double get totalPrice => _items.fold(0.0, (sum, it) => sum + it.subtotal);

  CartProvider() {
    _loadFromStorage();
  }

  Future<void> _loadFromStorage() async {
    _items = await StorageService.loadCart();
    _isLoaded = true;
    notifyListeners();
  }

  Future<void> _saveToStorage() async {
    await StorageService.saveCart(_items);
  }

  // Agregar producto al carrito
  void addItem(Product product, {int quantity = 1}) {
    final index = _items.indexWhere((it) => it.product.id == product.id);
    if (index >= 0) {
      _items[index].quantity += quantity;
    } else {
      _items.add(CartItem(product: product, quantity: quantity));
    }
    _saveToStorage();
    notifyListeners();
  }

  // Modificar cantidad directamente
  void updateQuantity(String productId, int newQuantity) {
    if (newQuantity <= 0) return;
    final index = _items.indexWhere((it) => it.product.id == productId);
    if (index >= 0) {
      _items[index].quantity = newQuantity;
      _saveToStorage();
      notifyListeners();
    }
  }

  // Eliminar producto con Confirmación en AlertDialog y opción "Deshacer" en SnackBar (Regla UX 6)
  Future<void> confirmAndRemoveItem(BuildContext context, String productId) async {
    final index = _items.indexWhere((it) => it.product.id == productId);
    if (index < 0) return;

    final targetItem = _items[index];

    final confirmed = await Helpers.showConfirmDialog(
      context: context,
      title: 'Quitar del Carrito',
      message: '¿Estás seguro de que deseas eliminar "${targetItem.product.name}" de tu carrito?',
      confirmLabel: 'Quitar',
      cancelLabel: 'Conservar',
    );

    if (confirmed == true) {
      // Elimina el elemento
      _items.removeAt(index);
      _saveToStorage();
      notifyListeners();

      if (context.mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Se eliminó "${targetItem.product.name}" del carrito.'),
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Deshacer',
              textColor: AppTheme.woodLight,
              onPressed: () {
                // Restaurar elemento eliminado
                _items.insert(index, targetItem);
                _saveToStorage();
                notifyListeners();
              },
            ),
          ),
        );
      }
    }
  }

  // Vaciar carrito
  Future<void> clearCart() async {
    _items.clear();
    await StorageService.clearCart();
    notifyListeners();
  }
}
