import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/helpers.dart';
import '../../models/order.dart';
import '../../services/api_service.dart';

class OrderTrackingScreen extends StatefulWidget {
  final String orderNumber;

  const OrderTrackingScreen({super.key, required this.orderNumber});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  final ApiService _apiService = ApiService();
  Order? _order;
  bool _isLoading = true;
  bool _isRefreshing = false;
  String? _error;
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _fetchOrder(initial: true);
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchOrder({bool initial = false}) async {
    if (initial) {
      setState(() => _isLoading = true);
    } else {
      setState(() => _isRefreshing = true);
    }

    try {
      final order = await _apiService.getOrderById(widget.orderNumber);
      if (mounted) {
        setState(() {
          _order = order;
          _isLoading = false;
          _isRefreshing = false;
          _error = null;
        });

        // Si está pendiente de verificación, activar sondeo en vivo cada 4 segundos
        if (order.paymentStatus == 'PENDING_VERIFICATION') {
          _startPolling();
        } else {
          _pollingTimer?.cancel();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
          _isRefreshing = false;
        });
      }
    }
  }

  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 4), (_) async {
      try {
        final order = await _apiService.getOrderById(widget.orderNumber);
        if (mounted) {
          setState(() => _order = order);
          if (order.paymentStatus != 'PENDING_VERIFICATION') {
            _pollingTimer?.cancel();
          }
        }
      } catch (_) {}
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          constraints: const BoxConstraints(minWidth: 48, minHeight: 48), // Regla UX 3
          onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
        ),
        title: const Text('Estado del Pedido'),
        actions: [
          IconButton(
            icon: Icon(
              LucideIcons.rotateCw,
              color: _isRefreshing ? AppTheme.woodLight : AppTheme.textMuted,
            ),
            tooltip: 'Comprobar ahora',
            constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
            onPressed: () => _fetchOrder(),
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (_isLoading) {
              return const Center(child: CircularProgressIndicator(color: AppTheme.woodPrimary));
            }

            if (_error != null || _order == null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(LucideIcons.alertTriangle, color: AppTheme.danger, size: 40),
                      const SizedBox(height: 16),
                      Text(
                        _error ?? 'No se pudo cargar el pedido',
                        style: const TextStyle(color: AppTheme.textLight, fontSize: 15),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(minimumSize: const Size(140, 48)),
                        onPressed: () => _fetchOrder(initial: true),
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                ),
              );
            }

            final order = _order!;
            final isPending = order.paymentStatus == 'PENDING_VERIFICATION';
            final isApproved = order.paymentStatus == 'APPROVED';
            final isRejected = order.paymentStatus == 'REJECTED';

            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Tarjeta de Cabecera y Estado del Pago
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceCard,
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(color: AppTheme.surfaceBorder),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'CONFIRMACIÓN DE ORDEN',
                                        style: TextStyle(
                                          color: AppTheme.woodLight,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 0.8,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '#${order.orderNumber}',
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w900,
                                          color: AppTheme.textLight,
                                        ),
                                      ),
                                    ],
                                  ),
                                  // Badge de estado
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: isApproved
                                          ? AppTheme.success.withValues(alpha: 0.15)
                                          : isRejected
                                              ? AppTheme.danger.withValues(alpha: 0.15)
                                              : AppTheme.warning.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isApproved
                                            ? AppTheme.success.withValues(alpha: 0.4)
                                            : isRejected
                                                ? AppTheme.danger.withValues(alpha: 0.4)
                                                : AppTheme.warning.withValues(alpha: 0.4),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          isApproved
                                              ? LucideIcons.check
                                              : isRejected
                                                  ? LucideIcons.x
                                                  : LucideIcons.clock,
                                          size: 14,
                                          color: isApproved
                                              ? AppTheme.success
                                              : isRejected
                                                  ? AppTheme.danger
                                                  : AppTheme.warning,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          isApproved
                                              ? 'Verificado'
                                              : isRejected
                                                  ? 'Rechazado'
                                                  : 'En Revisión',
                                          style: TextStyle(
                                            color: isApproved
                                                ? AppTheme.success
                                                : isRejected
                                                    ? AppTheme.danger
                                                    : AppTheme.warning,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Fecha de registro: ${Helpers.formatDate(order.createdAt)}',
                                style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Banner informativo según el estado
                        if (isPending)
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppTheme.warning.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppTheme.warning.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Icon(LucideIcons.clock, color: AppTheme.warning, size: 20),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Tu comprobante está siendo revisado por el equipo administrativo. Esta pantalla se actualizará automáticamente en vivo.',
                                    style: TextStyle(color: AppTheme.textLight, fontSize: 13, height: 1.4),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        if (isApproved)
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppTheme.success.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppTheme.success.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Icon(LucideIcons.checkCheck, color: AppTheme.success, size: 20),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    '¡Pago verificado con éxito! Tu pedido ha sido aprobado y se encuentra en preparación para el despacho.',
                                    style: TextStyle(color: AppTheme.textLight, fontSize: 13, height: 1.4),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        if (isRejected)
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppTheme.danger.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppTheme.danger.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(LucideIcons.alertTriangle, color: AppTheme.danger, size: 20),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Pago Rechazado: "${order.payment?.rejectionReason ?? 'Comprobante no válido o importe discordante'}". Por favor comunícate con nosotros por WhatsApp para solucionarlo.',
                                    style: const TextStyle(color: AppTheme.textLight, fontSize: 13, height: 1.4),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        const SizedBox(height: 24),

                        // Detalle de Productos
                        const Text(
                          'Detalle de Productos',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.textLight),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceCard,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: AppTheme.surfaceBorder),
                          ),
                          child: ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: order.items.length,
                            separatorBuilder: (_, _) => const Divider(color: AppTheme.surfaceBorder, height: 1),
                            itemBuilder: (context, idx) {
                              final item = order.items[idx];
                              return ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                title: Text(
                                  item.product?.name ?? 'Producto de la orden',
                                  style: const TextStyle(fontWeight: FontWeight.w800, color: AppTheme.textLight, fontSize: 13),
                                ),
                                subtitle: Text(
                                  '${item.quantity} unidades × ${Helpers.formatCurrency(item.unitPrice)}',
                                  style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                                ),
                                trailing: Text(
                                  Helpers.formatCurrency(item.subtotal),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.woodLight,
                                    fontSize: 13,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Datos de Entrega
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceCard,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: AppTheme.surfaceBorder),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Lugar de Envío',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.textLight),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(LucideIcons.mapPin, size: 16, color: AppTheme.woodLight),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      '${order.address}, ${order.city}',
                                      style: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(LucideIcons.phone, size: 16, color: AppTheme.woodLight),
                                  const SizedBox(width: 8),
                                  Text(
                                    order.phone,
                                    style: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Resumen de Totales
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.surface,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: AppTheme.surfaceBorder),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Subtotal:', style: TextStyle(color: AppTheme.textMuted, fontSize: 13)),
                                  Text(Helpers.formatCurrency(order.subtotal), style: const TextStyle(color: AppTheme.textLight, fontWeight: FontWeight.w700)),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Envío a Bolivia:', style: TextStyle(color: AppTheme.textMuted, fontSize: 13)),
                                  const Text('GRATIS', style: TextStyle(color: AppTheme.success, fontWeight: FontWeight.w800, fontSize: 12)),
                                ],
                              ),
                              const Divider(height: 20, color: AppTheme.surfaceBorder),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Total:', style: TextStyle(color: AppTheme.textLight, fontWeight: FontWeight.w900, fontSize: 16)),
                                  Text(
                                    Helpers.formatCurrency(order.total),
                                    style: const TextStyle(color: AppTheme.woodLight, fontWeight: FontWeight.w900, fontSize: 20),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ZONA DEL PULGAR (Regla UX 2): Botón de Retorno al Inicio
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: AppTheme.surfaceCard,
                    border: Border(top: BorderSide(color: AppTheme.surfaceBorder)),
                  ),
                  child: ElevatedButton.icon(
                    icon: const Icon(LucideIcons.home, size: 18),
                    label: const Text('Volver al Inicio'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 54), // Regla UX 3
                    ),
                    onPressed: () {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
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
