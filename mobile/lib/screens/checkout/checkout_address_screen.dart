import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme/app_theme.dart';
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
  final TextEditingController _cityCtrl = TextEditingController();
  final TextEditingController _addressCtrl = TextEditingController();
  final TextEditingController _notesCtrl = TextEditingController();

  String _selectedDepartment = 'Tarija';

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNamePaternoCtrl.dispose();
    _lastNameMaternoCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _ciNitCtrl.dispose();
    _cityCtrl.dispose();
    _addressCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _proceedToPayment() {
    if (_formKey.currentState?.validate() ?? false) {
      final fullName = [
        _firstNameCtrl.text.trim(),
        _lastNamePaternoCtrl.text.trim(),
        _lastNameMaternoCtrl.text.trim(),
      ].where((part) => part.isNotEmpty).join(' ');

      final formattedCity = _selectedDepartment == _cityCtrl.text.trim()
          ? _cityCtrl.text.trim()
          : '${_cityCtrl.text.trim()}, $_selectedDepartment';

      final clientData = {
        'clientName': fullName,
        'clientEmail': _emailCtrl.text.trim().toLowerCase(),
        'clientPhone': _phoneCtrl.text.trim(),
        'clientCiNit': _ciNitCtrl.text.trim(),
        'clientDepartment': _selectedDepartment,
        'clientCity': formattedCity,
        'clientAddress': _addressCtrl.text.trim(),
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
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Stepper
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildStepBadge(number: '1', label: 'Datos', isActive: true),
                              Container(width: 40, height: 2, color: AppTheme.surfaceBorder),
                              _buildStepBadge(number: '2', label: 'Pago QR', isActive: false),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // SECCIÓN 1: DATOS PERSONALES
                          _buildSectionHeader(LucideIcons.user, 'Información Personal'),
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

                          // SECCIÓN 2: CONTACTO E IDENTIFICACIÓN
                          _buildSectionHeader(LucideIcons.phone, 'Contacto e Identificación'),
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

                          // SECCIÓN 3: LUGAR DE ENTREGA
                          _buildSectionHeader(LucideIcons.mapPin, 'Lugar de Entrega (Bolivia)'),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            initialValue: _selectedDepartment,
                            dropdownColor: AppTheme.surfaceCard,
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
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _cityCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Ciudad / Localidad *',
                              hintText: 'Ej. Tarija, Cercado / El Alto / Cochabamba',
                            ),
                            validator: (val) => val == null || val.trim().isEmpty ? 'Ingresa la ciudad o localidad' : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _addressCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Dirección Exacta de Entrega *',
                              hintText: 'Calle, número, barrio o referencia',
                            ),
                            validator: (val) => val == null || val.trim().isEmpty ? 'Ingresa la dirección detallada' : null,
                          ),

                          const SizedBox(height: 20),

                          // SECCIÓN 4: NOTAS
                          TextFormField(
                            controller: _notesCtrl,
                            maxLines: 2,
                            decoration: const InputDecoration(
                              labelText: 'Indicaciones Especiales (Opcional)',
                              hintText: 'Ej. Entregar en horario de la tarde / Llamar antes...',
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
                    color: AppTheme.surfaceCard,
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

  Widget _buildSectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppTheme.woodLight),
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
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isActive ? AppTheme.woodPrimary : AppTheme.surface,
            shape: BoxShape.circle,
            border: Border.all(color: isActive ? AppTheme.woodLight : AppTheme.surfaceBorder),
          ),
          child: Text(
            number,
            style: TextStyle(
              color: isActive ? Colors.white : AppTheme.textMuted,
              fontWeight: FontWeight.w900,
              fontSize: 13,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            color: isActive ? AppTheme.woodLight : AppTheme.textMuted,
            fontWeight: isActive ? FontWeight.w900 : FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
