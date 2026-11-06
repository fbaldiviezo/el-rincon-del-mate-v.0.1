import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../core/config/api_config.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/helpers.dart';
import '../../providers/cart_provider.dart';
import '../../providers/catalog_provider.dart';
import '../../services/api_service.dart';
import '../../services/storage_service.dart';
import '../order/order_tracking_screen.dart';

class CheckoutPaymentScreen extends StatefulWidget {
  final Map<String, dynamic> clientData;

  const CheckoutPaymentScreen({super.key, required this.clientData});

  @override
  State<CheckoutPaymentScreen> createState() => _CheckoutPaymentScreenState();
}

class _CheckoutPaymentScreenState extends State<CheckoutPaymentScreen> {
  final ApiService _apiService = ApiService();
  final ImagePicker _picker = ImagePicker();

  File? _proofFile;
  bool _isSubmitting = false;
  String? _errorMessage;

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1600,
      );
      if (picked != null) {
        final file = File(picked.path);
        final sizeInBytes = await file.length();
        if (sizeInBytes > 5 * 1024 * 1024) {
          setState(() {
            _errorMessage = 'El archivo supera el tamaño máximo permitido de 5 MB.';
          });
          return;
        }

        setState(() {
          _proofFile = file;
          _errorMessage = null;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'No se pudo seleccionar la imagen: $e';
      });
    }
  }

  void _showImageSourceModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Adjuntar Comprobante de Pago',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textLight,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(LucideIcons.camera, color: AppTheme.woodLight, size: 20),
                ),
                title: const Text('Tomar Foto con la Cámara', style: TextStyle(color: AppTheme.textLight, fontWeight: FontWeight.w700)),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _pickImage(ImageSource.camera);
                },
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(LucideIcons.image, color: AppTheme.woodLight, size: 20),
                ),
                title: const Text('Seleccionar de la Galería', style: TextStyle(color: AppTheme.textLight, fontWeight: FontWeight.w700)),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitOrder(CartProvider cart) async {
    if (_proofFile == null) {
      setState(() {
        _errorMessage = 'Es obligatorio adjuntar el comprobante fotográfico para completar la orden.';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final order = await _apiService.createOrderWithProof(
        clientData: widget.clientData,
        items: cart.items,
        proofFile: _proofFile!,
      );

      // Limpiar carrito y datos de sesión
      await cart.clearCart();
      await StorageService.clearCheckoutClient();

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => OrderTrackingScreen(orderNumber: order.orderNumber),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final catalog = Provider.of<CatalogProvider>(context);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          constraints: const BoxConstraints(minWidth: 48, minHeight: 48), // Regla UX 3
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Pago por QR'),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Indicador de Pasos (Stepper)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildStepBadge(number: '✓', label: 'Datos', isCompleted: true, isActive: false),
                            Container(width: 40, height: 2, color: AppTheme.woodLight),
                            _buildStepBadge(number: '2', label: 'Pago QR', isCompleted: false, isActive: true),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Tarjeta de Monto Total a Pagar
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceCard,
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(color: AppTheme.surfaceBorder),
                          ),
                          child: Column(
                            children: [
                              const Text(
                                'TOTAL A PAGAR',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.woodLight,
                                  letterSpacing: 0.8,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                Helpers.formatCurrency(cart.totalPrice),
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w900,
                                  color: AppTheme.textLight,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Tarjeta con Imagen del QR del Dueño
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppTheme.surface,
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(color: AppTheme.surfaceBorder),
                          ),
                          child: Column(
                            children: [
                              Container(
                                width: 220,
                                height: 220,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(color: AppTheme.woodLight, width: 2),
                                ),
                                child: catalog.activeQr != null && catalog.activeQr!.imageUrl.isNotEmpty
                                    ? Image.network(
                                        ApiConfig.resolveImageUrl(catalog.activeQr!.imageUrl),
                                        fit: BoxFit.contain,
                                        errorBuilder: (_, _, _) => const Center(
                                          child: Icon(LucideIcons.qrCode, color: Colors.black54, size: 64),
                                        ),
                                      )
                                    : const Center(
                                        child: CircularProgressIndicator(color: AppTheme.woodPrimary),
                                      ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(LucideIcons.qrCode, size: 16, color: AppTheme.woodLight),
                                  SizedBox(width: 8),
                                  Text(
                                    'Código QR Bancario Oficial',
                                    style: TextStyle(
                                      color: AppTheme.textLight,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Instrucciones de Pago
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceCard,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: AppTheme.surfaceBorder),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Instrucciones para transferir:',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.textLight,
                                ),
                              ),
                              const SizedBox(height: 12),
                              _buildInstructionItem('1', 'Escanea el código QR desde tu app bancaria (Banco Unión, BCP, BNB, etc.).'),
                              _buildInstructionItem('2', 'Transfiere el monto exacto de ${Helpers.formatCurrency(cart.totalPrice)}.'),
                              _buildInstructionItem('3', 'Guarda o toma captura de pantalla del comprobante bancario emitido.'),
                              _buildInstructionItem('4', 'Adjunta la captura a continuación y presiona "Enviar Pedido".'),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Selector y Previsualización del Comprobante
                        const Text(
                          'Comprobante de Pago *',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.textLight),
                        ),
                        const SizedBox(height: 8),
                        if (_proofFile == null)
                          GestureDetector(
                            onTap: () => _showImageSourceModal(context),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
                              decoration: BoxDecoration(
                                color: AppTheme.surface,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: AppTheme.woodPrimary.withValues(alpha: 0.5), style: BorderStyle.solid),
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    width: 54,
                                    height: 54,
                                    decoration: BoxDecoration(
                                      color: AppTheme.woodPrimary.withValues(alpha: 0.15),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(LucideIcons.camera, color: AppTheme.woodLight, size: 26),
                                  ),
                                  const SizedBox(height: 12),
                                  const Text(
                                    'Subir comprobante bancario',
                                    style: TextStyle(fontWeight: FontWeight.w800, color: AppTheme.textLight, fontSize: 14),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Toca aquí para tomar foto o elegir de tu galería (máx. 5MB)',
                                    style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppTheme.surface,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: AppTheme.success.withValues(alpha: 0.5)),
                            ),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.file(
                                    _proofFile!,
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: const [
                                          Icon(LucideIcons.check, size: 14, color: AppTheme.success),
                                          SizedBox(width: 4),
                                          Text(
                                            'Comprobante adjuntado',
                                            style: TextStyle(color: AppTheme.success, fontWeight: FontWeight.w800, fontSize: 12),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _proofFile!.path.split(Platform.pathSeparator).last,
                                        style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(LucideIcons.trash2, color: AppTheme.danger, size: 18),
                                  constraints: const BoxConstraints(minWidth: 48, minHeight: 48), // Regla UX 3
                                  onPressed: () => setState(() => _proofFile = null),
                                ),
                              ],
                            ),
                          ),

                        if (_errorMessage != null) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppTheme.danger.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppTheme.danger.withValues(alpha: 0.4)),
                            ),
                            child: Row(
                              children: [
                                const Icon(LucideIcons.alertTriangle, color: AppTheme.danger, size: 18),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    _errorMessage!,
                                    style: const TextStyle(color: AppTheme.danger, fontSize: 12, fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),

                // ZONA DEL PULGAR (Regla UX 2): Botón de Enviar Pedido
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: AppTheme.surfaceCard,
                    border: Border(top: BorderSide(color: AppTheme.surfaceBorder)),
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 54), // Regla UX 3
                      backgroundColor: AppTheme.woodPrimary,
                    ),
                    onPressed: (_proofFile != null && !_isSubmitting)
                        ? () => _submitOrder(cart)
                        : null,
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(LucideIcons.send, size: 18),
                              SizedBox(width: 10),
                              Text('Finalizar y Enviar Pedido', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
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

  Widget _buildStepBadge({required String number, required String label, required bool isCompleted, required bool isActive}) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isCompleted
                ? AppTheme.success
                : (isActive ? AppTheme.woodPrimary : AppTheme.surface),
            shape: BoxShape.circle,
            border: Border.all(color: isCompleted ? AppTheme.success : AppTheme.woodLight),
          ),
          child: Text(
            number,
            style: TextStyle(
              color: isCompleted || isActive ? Colors.white : AppTheme.textMuted,
              fontWeight: FontWeight.w900,
              fontSize: 13,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            color: isActive ? AppTheme.woodLight : (isCompleted ? AppTheme.textLight : AppTheme.textMuted),
            fontWeight: isActive ? FontWeight.w900 : FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildInstructionItem(String step, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppTheme.woodPrimary.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Text(
              step,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.woodLight),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 12, color: AppTheme.textMuted, height: 1.3),
            ),
          ),
        ],
      ),
    );
  }
}
