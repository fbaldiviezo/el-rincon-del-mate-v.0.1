import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';

class Helpers {
  static final NumberFormat _currencyFormat = NumberFormat('#,##0.00', 'es_BO');

  // Formateador de moneda oficial en Bolivianos
  static String formatCurrency(double amount) {
    return 'Bs. ${_currencyFormat.format(amount)}';
  }

  // Formateador de fecha
  static String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm', 'es_BO').format(date);
  }

  // Diálogo de confirmación seguro (Regla UX 6)
  static Future<bool> showConfirmDialog({
    required BuildContext context,
    required String title,
    required String message,
    String confirmLabel = 'Eliminar',
    String cancelLabel = 'Cancelar',
    bool isDestructive = true,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppTheme.surfaceBorder),
        ),
        title: Row(
          children: [
            Icon(
              isDestructive ? LucideIcons.alertTriangle : LucideIcons.helpCircle,
              color: isDestructive ? AppTheme.danger : AppTheme.woodLight,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textLight,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(
            fontSize: 14,
            color: AppTheme.textMuted,
            height: 1.4,
          ),
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            style: TextButton.styleFrom(
              minimumSize: const Size(48, 48), // Regla UX: 48x48
              foregroundColor: AppTheme.textMuted,
            ),
            child: Text(cancelLabel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(48, 48), // Regla UX: 48x48
              backgroundColor: isDestructive ? AppTheme.danger : AppTheme.woodPrimary,
            ),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  // Lanzador de WhatsApp para sucursales
  static Future<void> openWhatsApp({
    required String phone,
    String message = 'Hola El Rincón del Mate, quisiera consultar sobre sus productos.',
  }) async {
    final cleanPhone = phone.replaceAll(RegExp(r'\D'), '');
    final uri = Uri.parse(
      'https://wa.me/$cleanPhone?text=${Uri.encodeComponent(message)}',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
