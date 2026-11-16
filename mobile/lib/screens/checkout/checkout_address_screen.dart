import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme/app_theme.dart';
import '../../services/location_service.dart';
import 'address_picker_screen.dart';
import 'checkout_payment_screen.dart';

class CheckoutAddressScreen extends StatefulWidget {
  const CheckoutAddressScreen({super.key});

  @override
  State<CheckoutAddressScreen> createState() => _CheckoutAddressScreenState();
}

class _CheckoutAddressScreenState extends State<CheckoutAddressScreen> {
  final _formKey = GlobalKey<FormState>();

  // 9 Departamentos de Bolivia
  final List<String> _departments = [
    'Beni',
    'Chuquisaca',
    'Cochabamba',
    'La Paz',
    'Oruro',
    'Pando',
    'Potosí',
    'Santa Cruz',
    'Tarija',
  ];

  final TextEditingController _firstNameCtrl = TextEditingController();
  final TextEditingController _lastNamePaternoCtrl = TextEditingController();
  final TextEditingController _lastNameMaternoCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _phoneCtrl = TextEditingController();
  final TextEditingController _ciNitCtrl = TextEditingController();
  final TextEditingController _notesCtrl = TextEditingController();

  // Datos seleccionados del Picker de Dirección
  String _selectedDepartment = 'Tarija';
  String _pickedAddress = '';
  String _pickedCity = 'Tarija';
  double? _pickedLatitude;
  double? _pickedLongitude;
  bool _isLocatingGps = false;

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNamePaternoCtrl.dispose();
    _lastNameMaternoCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _ciNitCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  // Abre el Picker Interactivo de Ubicación
  Future<void> _openAddressPicker() async {
    final result = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(
        builder: (_) => AddressPickerScreen(
          initialPosition: (_pickedLatitude != null && _pickedLongitude != null)
              ? LatLng(_pickedLatitude!, _pickedLongitude!)
              : null,
          initialStreet: _pickedAddress,
        ),
      ),
    );

    if (result != null && mounted) {
      setState(() {
        _pickedAddress = result['address'] ?? '';
        _pickedCity = result['city'] ?? 'Tarija';
        _pickedLatitude = result['latitude'];
        _pickedLongitude = result['longitude'];

        // Sincronizar departamento si coincide con alguno de Bolivia
        final state = (result['department'] as String? ?? '').trim();
        for (final dept in _departments) {
          if (state.toLowerCase().contains(dept.toLowerCase())) {
            _selectedDepartment = dept;
            break;
          }
        }
      });
    }
  }

  // Detección directa por GPS del dispositivo
  Future<void> _quickGpsDetect() async {
    setState(() => _isLocatingGps = true);
    final pos = await LocationService.getCurrentDeviceLocation();
    if (!mounted) return;

    if (pos != null) {
      final coords = LatLng(pos.latitude, pos.longitude);
      final details = await LocationService.reverseGeocode(coords);
      if (!mounted) return;

      setState(() {
        _pickedLatitude = pos.latitude;
        _pickedLongitude = pos.longitude;
        _pickedAddress = details.formattedAddress;
        _pickedCity = details.city;

        for (final dept in _departments) {
          if (details.department.toLowerCase().contains(dept.toLowerCase())) {
            _selectedDepartment = dept;
            break;
          }
        }
        _isLocatingGps = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ubicación GPS detectada: ${details.formattedAddress}'),
          duration: const Duration(seconds: 3),
        ),
      );
    } else {
      setState(() => _isLocatingGps = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo acceder al GPS. Abre el mapa para seleccionar tu punto.'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  void _proceedToPayment() {
    if (_pickedAddress.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor selecciona tu dirección en el mapa antes de continuar.'),
          backgroundColor: AppTheme.danger,
        ),
      );
      return;
    }

    if (_formKey.currentState?.validate() ?? false) {
      final fullName = [
        _firstNameCtrl.text.trim(),
        _lastNamePaternoCtrl.text.trim(),
        _lastNameMaternoCtrl.text.trim(),
      ].where((part) => part.isNotEmpty).join(' ');

      final formattedCity = _selectedDepartment == _pickedCity.trim()
          ? _pickedCity.trim()
          : '${_pickedCity.trim()}, $_selectedDepartment';

      final clientData = {
        'clientName': fullName,
        'clientEmail': _emailCtrl.text.trim().toLowerCase(),
        'clientPhone': _phoneCtrl.text.trim(),
        'clientCiNit': _ciNitCtrl.text.trim(),
        'clientDepartment': _selectedDepartment,
        'clientCity': formattedCity,
        'clientAddress': _pickedAddress,
        'latitude': _pickedLatitude,
        'longitude': _pickedLongitude,
        'notes': _notesCtrl.text.trim(),
      };

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => CheckoutPaymentScreen(clientData: clientData),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          constraints: const BoxConstraints(minWidth: 48, minHeight: 48), // Regla UX 3
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Datos de Envío'),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Stepper Minimalista
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildStepBadge(number: '1', label: 'Envío', isActive: true),
                              Container(width: 36, height: 2, color: AppTheme.surfaceBorder),
                              _buildStepBadge(number: '2', label: 'Pago QR', isActive: false),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // SECCIÓN: PICKER DE DIRECCIÓN Y GPS
                          _buildSectionHeader(LucideIcons.mapPin, 'Ubicación de Entrega'),
                          const SizedBox(height: 10),

                          _buildAddressPickerCard(),

                          const SizedBox(height: 24),

                          // SECCIÓN 2: INFORMACIÓN PERSONAL
                          _buildSectionHeader(LucideIcons.user, 'Información del Cliente'),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _firstNameCtrl,
                            decoration: const InputDecoration(labelText: 'Nombre(s) *', hintText: 'Ej. Leonardo'),
                            validator: (val) => val == null || val.trim().isEmpty ? 'Ingresa tu nombre' : null,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _lastNamePaternoCtrl,
                                  decoration: const InputDecoration(labelText: 'Apellido Paterno *', hintText: 'Ej. Pérez'),
                                  validator: (val) => val == null || val.trim().isEmpty ? 'Ingresa el apellido' : null,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextFormField(
                                  controller: _lastNameMaternoCtrl,
                                  decoration: const InputDecoration(labelText: 'Apellido Materno', hintText: 'Ej. Gómez'),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // SECCIÓN 3: CONTACTO E IDENTIFICACIÓN
                          _buildSectionHeader(LucideIcons.phone, 'Contacto y Comprobante'),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _emailCtrl,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(labelText: 'Correo Electrónico *', hintText: 'correo@ejemplo.com'),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) return 'Ingresa tu correo';
                              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(val.trim())) {
                                return 'Formato de correo no válido';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _phoneCtrl,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                  decoration: const InputDecoration(
                                    labelText: 'Teléfono / WhatsApp *',
                                    hintText: 'Ej. 69891494',
                                  ),
                                  validator: (val) {
                                    if (val == null || val.trim().isEmpty) return 'Ingresa tu teléfono';
                                    if (val.trim().length < 6) return 'Mínimo 6 dígitos';
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextFormField(
                                  controller: _ciNitCtrl,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                  decoration: const InputDecoration(
                                    labelText: 'CI / NIT (Opcional)',
                                    hintText: 'Ej. 12345678',
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // SECCIÓN 4: DEPARTAMENTO Y NOTAS
                          _buildSectionHeader(LucideIcons.map, 'Departamento y Destino'),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            initialValue: _selectedDepartment,
                            dropdownColor: AppTheme.surface,
                            decoration: const InputDecoration(labelText: 'Departamento *'),
                            items: _departments.map((dept) {
                              return DropdownMenuItem(
                                value: dept,
                                child: Text(dept, style: const TextStyle(color: AppTheme.textLight)),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _selectedDepartment = val);
                            },
                          ),

                          const SizedBox(height: 16),

                          TextFormField(
                            controller: _notesCtrl,
                            maxLines: 2,
                            decoration: const InputDecoration(
                              labelText: 'Indicaciones Especiales (Opcional)',
                              hintText: 'Ej. Timbre azul / Entregar en horario de la tarde...',
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),

                // ZONA DEL PULGAR (Regla UX 2): Botón Continuar
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: AppTheme.surface,
                    border: Border(top: BorderSide(color: AppTheme.surfaceBorder)),
                  ),
                  child: ElevatedButton.icon(
                    icon: const Icon(LucideIcons.arrowRight, size: 18),
                    label: const Text('Continuar al Pago por QR'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 54), // Regla UX 3
                    ),
                    onPressed: _proceedToPayment,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildAddressPickerCard() {
    final hasAddress = _pickedAddress.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: hasAddress ? AppTheme.pastelSage : AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: hasAddress ? AppTheme.woodLight.withValues(alpha: 0.4) : AppTheme.surfaceBorder,
          width: 1.5,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: hasAddress ? AppTheme.woodPrimary : AppTheme.pastelCream,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  hasAddress ? LucideIcons.mapPin : LucideIcons.compass,
                  color: hasAddress ? Colors.white : AppTheme.woodPrimary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hasAddress ? 'Punto de Entrega Confirmado' : 'Selecciona tu Punto en el Mapa',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: hasAddress ? AppTheme.woodDark : AppTheme.textLight,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      hasAddress
                          ? _pickedAddress
                          : 'Usa el mapa interactivo o tu GPS para fijar el lugar exacto de entrega.',
                      style: TextStyle(
                        fontSize: 12,
                        color: hasAddress ? AppTheme.textLight : AppTheme.textMuted,
                        height: 1.3,
                      ),
                    ),
                    if (hasAddress && _pickedLatitude != null && _pickedLongitude != null) ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppTheme.surfaceBorder),
                        ),
                        child: Text(
                          'GPS: ${_pickedLatitude!.toStringAsFixed(4)}, ${_pickedLongitude!.toStringAsFixed(4)}',
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.textMuted),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              // Botón Abrir Mapa
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(LucideIcons.map, size: 16),
                  label: Text(hasAddress ? 'Cambiar en Mapa' : 'Abrir Mapa'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48), // Regla UX 3
                    backgroundColor: Colors.white,
                    side: BorderSide(color: hasAddress ? AppTheme.woodPrimary : AppTheme.surfaceBorder),
                  ),
                  onPressed: _openAddressPicker,
                ),
              ),
              const SizedBox(width: 10),
              // Botón rápido GPS
              IconButton.filledTonal(
                icon: _isLocatingGps
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.woodPrimary),
                      )
                    : const Icon(LucideIcons.locateFixed, size: 20),
                tooltip: 'Usar mi GPS actual',
                style: IconButton.styleFrom(
                  minimumSize: const Size(48, 48), // Regla UX 3
                  backgroundColor: AppTheme.pastelCream,
                  foregroundColor: AppTheme.woodPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: _isLocatingGps ? null : _quickGpsDetect,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppTheme.woodPrimary),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: AppTheme.textLight,
          ),
        ),
      ],
    );
  }

  Widget _buildStepBadge({required String number, required String label, required bool isActive}) {
    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isActive ? AppTheme.woodPrimary : AppTheme.pastelCream,
            shape: BoxShape.circle,
            border: Border.all(color: isActive ? AppTheme.woodPrimary : AppTheme.surfaceBorder),
          ),
          child: Text(
            number,
            style: TextStyle(
              color: isActive ? Colors.white : AppTheme.textMuted,
              fontWeight: FontWeight.w900,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            color: isActive ? AppTheme.woodPrimary : AppTheme.textMuted,
            fontWeight: isActive ? FontWeight.w900 : FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
