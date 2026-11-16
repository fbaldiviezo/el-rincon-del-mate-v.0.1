import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme/app_theme.dart';
import '../../services/location_service.dart';

class AddressPickerScreen extends StatefulWidget {
  final LatLng? initialPosition;
  final String? initialStreet;

  const AddressPickerScreen({
    super.key,
    this.initialPosition,
    this.initialStreet,
  });

  @override
  State<AddressPickerScreen> createState() => _AddressPickerScreenState();
}

class _AddressPickerScreenState extends State<AddressPickerScreen> {
  final MapController _mapController = MapController();
  final TextEditingController _detailCtrl = TextEditingController();

  late LatLng _currentCenter;
  AddressDetails? _currentAddress;
  bool _isLoadingAddress = false;
  bool _isLocatingGps = false;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _currentCenter = widget.initialPosition ?? LocationService.defaultBoliviaPosition;
    _initLocation();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _detailCtrl.dispose();
    super.dispose();
  }

  Future<void> _initLocation() async {
    // Si no se proporcionó posición previa, intentar obtener el GPS del dispositivo
    if (widget.initialPosition == null) {
      await _moveToCurrentGps();
    } else {
      _fetchAddressDetails(_currentCenter);
    }
  }

  Future<void> _moveToCurrentGps() async {
    setState(() => _isLocatingGps = true);

    final position = await LocationService.getCurrentDeviceLocation();
    if (mounted) {
      if (position != null) {
        final newCenter = LatLng(position.latitude, position.longitude);
        setState(() {
          _currentCenter = newCenter;
          _isLocatingGps = false;
        });
        _mapController.move(newCenter, 16.5);
        _fetchAddressDetails(newCenter);
      } else {
        setState(() => _isLocatingGps = false);
        _fetchAddressDetails(_currentCenter);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo acceder al GPS. Puedes ubicar tu dirección en el mapa.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _onMapMoved(LatLng newCenter) {
    _currentCenter = newCenter;
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _fetchAddressDetails(newCenter);
    });
  }

  Future<void> _fetchAddressDetails(LatLng coords) async {
    setState(() => _isLoadingAddress = true);
    final details = await LocationService.reverseGeocode(coords);
    if (mounted) {
      setState(() {
        _currentAddress = details;
        _isLoadingAddress = false;
      });
    }
  }

  void _confirmSelection() {
    if (_currentAddress == null) return;

    final extraDetail = _detailCtrl.text.trim();
    String finalAddress = _currentAddress!.formattedAddress;
    if (extraDetail.isNotEmpty) {
      finalAddress = '$finalAddress ($extraDetail)';
    }

    Navigator.of(context).pop({
      'address': finalAddress,
      'street': _currentAddress!.street,
      'city': _currentAddress!.city,
      'department': _currentAddress!.department,
      'latitude': _currentCenter.latitude,
      'longitude': _currentCenter.longitude,
      'reference': extraDetail,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          constraints: const BoxConstraints(minWidth: 48, minHeight: 48), // Regla UX 3
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Ubicación de Entrega'),
        actions: [
          IconButton(
            icon: _isLocatingGps
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.woodPrimary),
                  )
                : const Icon(LucideIcons.locateFixed, color: AppTheme.woodPrimary),
            tooltip: 'Usar mi GPS',
            constraints: const BoxConstraints(minWidth: 48, minHeight: 48), // Regla UX 3
            onPressed: _isLocatingGps ? null : _moveToCurrentGps,
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                // MAPA INTERACTIVO (OpenStreetMap)
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _currentCenter,
                    initialZoom: 16.0,
                    minZoom: 4.0,
                    maxZoom: 18.5,
                    onPositionChanged: (camera, hasGesture) {
                      if (hasGesture) {
                        _onMapMoved(camera.center);
                      }
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.elrincondelmate.mobile',
                    ),
                  ],
                ),

                // PIN FIJO AL CENTRO (Estilo Uber / Minimalista)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 38.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.woodPrimary,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.woodPrimary.withValues(alpha: 0.35),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            LucideIcons.mapPin,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: AppTheme.woodDark.withValues(alpha: 0.6),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // BOTÓN FLOTANTE GPS EN ZONA DEL PULGAR
                Positioned(
                  right: 16,
                  bottom: 270,
                  child: Material(
                    elevation: 3,
                    borderRadius: BorderRadius.circular(16),
                    color: AppTheme.surface,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: _isLocatingGps ? null : _moveToCurrentGps,
                      child: Container(
                        width: 52,
                        height: 52, // Regla UX 3: >= 48dp
                        alignment: Alignment.center,
                        child: _isLocatingGps
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.woodPrimary),
                              )
                            : const Icon(LucideIcons.crosshair, color: AppTheme.woodPrimary, size: 24),
                      ),
                    ),
                  ),
                ),

                // TARJETA INFERIOR EN ZONA DEL PULGAR (Regla UX 2)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 20,
                          offset: const Offset(0, -4),
                        ),
                      ],
                      border: const Border(top: BorderSide(color: AppTheme.surfaceBorder)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Píldora de arrastre superior
                        Center(
                          child: Container(
                            width: 38,
                            height: 4,
                            margin: const EdgeInsets.only(bottom: 14),
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceBorder,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),

                        // Dirección detectada
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppTheme.pastelSage,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(LucideIcons.mapPin, color: AppTheme.woodPrimary, size: 18),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _isLoadingAddress
                                        ? 'Localizando dirección...'
                                        : (_currentAddress?.formattedAddress ?? 'Selecciona un punto en el mapa'),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 14,
                                      color: AppTheme.textLight,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _currentAddress != null
                                        ? '${_currentAddress!.city}, ${_currentAddress!.department}'
                                        : 'Arrastra el mapa para ajustar el punto exacto',
                                    style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        // Campo adicional: N° de casa o referencia
                        TextField(
                          controller: _detailCtrl,
                          decoration: InputDecoration(
                            isDense: true,
                            hintText: 'N° de casa, dpto. o referencia (opcional)',
                            prefixIcon: const Icon(LucideIcons.home, size: 18, color: AppTheme.textMuted),
                            filled: true,
                            fillColor: AppTheme.pastelCream,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(color: AppTheme.surfaceBorder),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(color: AppTheme.surfaceBorder),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Botón de Confirmación Principal en la Zona del Pulgar (Regla UX 2)
                        ElevatedButton.icon(
                          icon: const Icon(LucideIcons.check, size: 18),
                          label: const Text('Confirmar este Punto de Entrega'),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 52), // Regla UX 3
                            backgroundColor: AppTheme.woodPrimary,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: _currentAddress != null ? _confirmSelection : null,
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
