import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../data/providers/providers.dart';
import '../../data/models/models.dart';

/// Firm Services Tab - Configure services and pricing
class FirmServicesTab extends ConsumerWidget {
  const FirmServicesTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final servicesAsync = ref.watch(activeServicesProvider);
    final firmAsync = ref.watch(currentFirmProvider);

    return firmAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Hata: $e')),
      data: (firm) {
        // DEV MODE: Use mock firm if null
        final displayFirm = firm ?? FirmModel(
          id: 'demo', uid: 'demo', name: 'Demo Firma', phone: '',
          address: AddressModel(city: '', district: '', area: '', neighborhood: '', fullAddress: ''),
          createdAt: DateTime.now(), smsBalance: 100,
        );

        return servicesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Hata: $e')),
          data: (services) {
            if (services.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.category, size: 64, color: AppTheme.lightGray),
                    SizedBox(height: 16),
                    Text('Henüz hizmet tanımlanmamış'),
                    Text(
                      'Yönetici tarafından hizmetler eklenecektir.',
                      style: TextStyle(color: AppTheme.mediumGray),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: services.length,
              itemBuilder: (context, index) {
                final service = services[index];
                final firmService = displayFirm.services.firstWhere(
                  (s) => s.serviceId == service.id,
                  orElse: () => ServicePriceModel(
                    serviceId: service.id,
                    serviceName: service.name,
                    enabled: false,
                    unit: service.units.first,
                    price: 0,
                  ),
                );

                return _ServiceCard(
                  service: service,
                  firmService: firmService,
                  onUpdate: (updatedService) async {
                    // Create a mutable copy of current services
                    final List<ServicePriceModel> currentServices = List.from(displayFirm.services);
                    
                    // Find index of existing service
                    final index = currentServices.indexWhere((s) => s.serviceId == updatedService.serviceId);
                    
                    if (index >= 0) {
                      currentServices[index] = updatedService;
                    } else {
                      currentServices.add(updatedService);
                    }
                    
                    // Update in Firestore
                    await ref.read(firmRepositoryProvider).updateFirm(displayFirm.id, {
                      'services': currentServices.map((s) => s.toMap()).toList(),
                    });
                    
                    // Invalidate provider to force refresh from Firestore
                    ref.invalidate(currentFirmProvider);
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}

class _ServiceCard extends StatefulWidget {
  final ServiceModel service;
  final ServicePriceModel firmService;
  final Function(ServicePriceModel) onUpdate;

  const _ServiceCard({
    required this.service,
    required this.firmService,
    required this.onUpdate,
  });

  @override
  State<_ServiceCard> createState() => _ServiceCardState();
}

class _ServiceCardState extends State<_ServiceCard> {
  late bool _enabled;
  late String _unit;
  late TextEditingController _priceController;


  @override
  void initState() {
    super.initState();
    _enabled = widget.firmService.enabled;
    
    // Fallback logic: If saved unit is not in current allowed units, use first allowed unit
    if (widget.service.units.contains(widget.firmService.unit)) {
      _unit = widget.firmService.unit;
    } else {
      _unit = widget.service.units.isNotEmpty ? widget.service.units.first : 'adet';
    }

    _priceController = TextEditingController(
      text: widget.firmService.price > 0
          ? widget.firmService.price.toStringAsFixed(0)
          : '',
    );
  }

  @override
  void didUpdateWidget(_ServiceCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.firmService != oldWidget.firmService) {
      // Sync enabled state
      if (widget.firmService.enabled != _enabled) {
        _enabled = widget.firmService.enabled;
      }
      
      // Sync unit
      if (widget.firmService.unit != _unit) {
         _unit = widget.firmService.unit;
      }

      // Sync price only if it changed externally to avoid cursor fights
      // But since we want to show the specific updated value, valid check:
      final newPriceStr = widget.firmService.price > 0 
          ? widget.firmService.price.toStringAsFixed(0) 
          : '';
      if (_priceController.text != newPriceStr) {
         // Only update if the user is NOT currently typing? 
         // Actually, if the user switches tabs and comes back, they arent typing.
         // If this update comes from the stream because the user saved it, we should update it.
         // The safe bet for this specific "switch tab" bug is to update it.
         _priceController.text = newPriceStr;
      }
    }
  }


  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  IconData _getServiceIcon(String iconName) {
    switch (iconName) {
      case 'carpet':
        return Icons.grid_4x4;
      case 'sofa':
        return Icons.weekend;
      case 'curtain':
        return Icons.curtains;
      case 'bed':
        return Icons.bed;
      case 'blanket':
        return Icons.layers;
      default:
        return Icons.category;
    }
  }

  String _getUnitLabel(String unit) {
    switch (unit) {
      case 'm2':
        return 'm²';
      case 'adet':
        return 'Adet';
      case 'takim':
        return 'Takım';
      case 'meter':
        return 'Metre';
      default:
        return unit;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getServiceIcon(widget.service.icon),
                  color: _enabled ? AppTheme.primaryBlue : AppTheme.mediumGray,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.service.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _enabled ? null : AppTheme.mediumGray,
                    ),
                  ),
                ),
                Switch(
                  value: _enabled,
                  onChanged: (value) {
                    setState(() => _enabled = value);
                    _saveChanges();
                  },
                  activeThumbColor: AppTheme.accentGreen,
                ),
              ],
            ),
            if (_enabled) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  // Birim seçimi
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _unit,
                      decoration: const InputDecoration(
                        labelText: 'Birim',
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      items: widget.service.units
                          .map((u) => DropdownMenuItem(
                                value: u,
                                child: Text(_getUnitLabel(u)),
                              ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _unit = value);
                          _saveChanges();
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Fiyat girişi
                  Expanded(
                    child: TextField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration( // Removed const here to allow dynamic suffixText
                        labelText: 'Fiyat (₺)',
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        suffixText: '/ ${_getUnitLabel(_unit)}', // Add suffix text for clarity
                      ),
                      onChanged: (_) => _saveChanges(),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _saveChanges() {
    final price = double.tryParse(_priceController.text) ?? 0;
    widget.onUpdate(ServicePriceModel(
      serviceId: widget.service.id,
      serviceName: widget.service.name,
      enabled: _enabled,
      unit: _unit,
      price: price,
    ));
  }
}
