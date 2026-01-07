
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/customer_theme.dart';
import '../../core/utils/image_utils.dart';
import '../../data/models/models.dart';
import '../../data/providers/providers.dart';

class CreateOrderSheet extends ConsumerStatefulWidget {
  final Function(String firmId) onComplete;
  final VoidCallback onNavigateToFirms;
  final FirmModel? initialFirm;

  const CreateOrderSheet({
    super.key,
    required this.onComplete,
    required this.onNavigateToFirms,
    this.initialFirm,
  });

  @override
  ConsumerState<CreateOrderSheet> createState() => _CreateOrderSheetState();
}

class _CreateOrderSheetState extends ConsumerState<CreateOrderSheet> {
  int _currentStep = 0;
  
  // Step 1 data
  final Set<String> _selectedServices = {};
  String _selectedPaymentMethod = FirmModel.paymentCash;
  
  // Step 2 data
  FirmModel? _selectedFirm;
  
  // Step 3 data
  final Map<String, int> _quantities = {};
  PromoCodeModel? _appliedPromoCode;
  final TextEditingController _promoCodeController = TextEditingController();
  bool _isCheckingPromo = false;
  String? _promoError;

  @override
  void initState() {
    super.initState();
    if (widget.initialFirm != null) {
      _selectedFirm = widget.initialFirm;
      // Pre-select all available services from the firm
      _selectedServices.addAll(
        widget.initialFirm!.services
            .where((s) => s.enabled)
            .map((s) => s.serviceId)
      );
      // Skip directly to Step 3 (Order Details)
      _currentStep = 2;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch active services from provider
    final servicesAsync = ref.watch(activeServicesProvider);

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: CustomerTheme.divider,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildStepIndicator(),
              ],
            ),
          ),
          
          // Step Content
          Expanded(
            child: servicesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Hata: $e')),
              data: (services) {
                if (services.isEmpty) {
                  return const Center(child: Text('Aktif hizmet bulunamadı.'));
                }
                return _buildStepContent(services);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    // If started with a specific firm, show a simplified indicator or just the relevant step
    if (widget.initialFirm != null) {
       return Container(
         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
         decoration: BoxDecoration(
           color: CustomerTheme.primary.withAlpha(20),
           borderRadius: BorderRadius.circular(20),
         ),
         child: Text(
           'Sipariş Oluşturuluyor',
           style: TextStyle(color: CustomerTheme.primary, fontWeight: FontWeight.bold),
         ),
       );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildStepDot(0, 'Hizmet'),
        _buildStepLine(0),
        _buildStepDot(1, 'Firma'),
        _buildStepLine(1),
        _buildStepDot(2, 'Detay'),
      ],
    );
  }

  Widget _buildStepDot(int step, String label) {
    final isActive = _currentStep >= step;
    final isCurrent = _currentStep == step;
    
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? CustomerTheme.primary : CustomerTheme.divider,
            border: isCurrent ? Border.all(color: CustomerTheme.primary, width: 2) : null,
          ),
          child: Center(
            child: isActive && !isCurrent
                ? const Icon(Icons.check, color: Colors.white, size: 18)
                : Text(
                    '${step + 1}',
                    style: TextStyle(
                      color: isActive ? Colors.white : CustomerTheme.textMedium,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isActive ? CustomerTheme.primary : CustomerTheme.textMedium,
            fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildStepLine(int afterStep) {
    final isActive = _currentStep > afterStep;
    return Container(
      width: 40,
      height: 2,
      margin: const EdgeInsets.only(bottom: 16),
      color: isActive ? CustomerTheme.primary : CustomerTheme.divider,
    );
  }

  Widget _buildStepContent(List<ServiceModel> services) {
    switch (_currentStep) {
      case 0:
        return _buildStep1ServiceSelection(services);
      case 1:
        return _buildStep2FirmSelection(services);
      case 2:
        return _buildStep3OrderDetails(services);
      default:
        return const SizedBox();
    }
  }

  // ==================== STEP 1: SERVICE & PAYMENT SELECTION ====================
  Widget _buildStep1ServiceSelection(List<ServiceModel> services) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: CustomerTheme.primaryGradient),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.cleaning_services, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              const Text('Hizmet Seçimi', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          const Text('Birden fazla hizmet seçebilirsiniz', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 16),
          
          // Services Grid
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.4,
              ),
              itemCount: services.length,
              itemBuilder: (context, index) {
                final service = services[index];
                final isSelected = _selectedServices.contains(service.id);
                // Dynamically select icon based on name/icon string or default
                IconData iconData = Icons.cleaning_services;
                if (service.icon == 'grid_view') {
                  iconData = Icons.grid_view;
                } else if (service.icon == 'bed') iconData = Icons.bed;
                else if (service.icon == 'weekend') iconData = Icons.weekend;
                else if (service.icon == 'curtains') iconData = Icons.curtains;
                else if (service.icon == 'king_bed') iconData = Icons.king_bed;
                
                // Assign color based on index or hash
                final colors = [
                  const Color(0xFFE91E63),
                  const Color(0xFF9C27B0),
                  const Color(0xFFFF9800),
                  const Color(0xFF4CAF50),
                  const Color(0xFF2196F3),
                ];
                final color = colors[index % colors.length];
                
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedServices.remove(service.id);
                      } else {
                        _selectedServices.add(service.id);
                      }
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? color.withAlpha(40)
                          : color.withAlpha(20),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected 
                            ? color
                            : color.withAlpha(50),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                iconData,
                                color: color,
                                size: 32,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                service.name,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: color,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.check, color: Colors.white, size: 16),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Payment Method Selection
          const Text('Ödeme Yöntemi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildPaymentChip(FirmModel.paymentCash, 'Nakit', Icons.money),
              const SizedBox(width: 8),
              _buildPaymentChip(FirmModel.paymentCard, 'Kredi Kartı', Icons.credit_card),
              const SizedBox(width: 8),
              _buildPaymentChip(FirmModel.paymentTransfer, 'Havale/EFT', Icons.account_balance),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Continue Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _selectedServices.isEmpty ? null : () {
                setState(() => _currentStep = 1);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: CustomerTheme.primary,
                disabledBackgroundColor: CustomerTheme.divider,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _selectedServices.isEmpty 
                        ? 'Hizmet Seçin' 
                        : 'Devam Et (${_selectedServices.length} hizmet)',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentChip(String method, String label, IconData icon) {
    final isSelected = _selectedPaymentMethod == method;
    
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedPaymentMethod = method),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected ? CustomerTheme.primary : CustomerTheme.softPink,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? CustomerTheme.primary : CustomerTheme.divider,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? Colors.white : CustomerTheme.primary, size: 20),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.white : CustomerTheme.textDark,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== STEP 2: FIRM SELECTION ====================
  Widget _buildStep2FirmSelection(List<ServiceModel> services) {
    // Fetch customer to get address
    final customerAsync = ref.watch(currentCustomerProvider);
    final firmsAsync = ref.watch(approvedFirmsProvider);
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back button & Title
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => setState(() => _currentStep = 0),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: CustomerTheme.primaryGradient),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.store, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text('Firma Seçimi', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          // Address Info
          customerAsync.when(
            data: (customer) {
              if (customer == null || customer.addresses.isEmpty) return const SizedBox();
              
              // Get selected address or first one
              final address = customer.addresses.isNotEmpty 
                  ? (customer.selectedAddressIndex < customer.addresses.length
                      ? customer.addresses[customer.selectedAddressIndex]
                      : customer.addresses.first)
                  : null;
                  
              if (address == null) return const SizedBox();
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  children: [
                    const Icon(Icons.location_on, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      'Konum: ${address.district}, ${address.city}',
                      style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              );
            },
            loading: () => const SizedBox(),
            error: (_, __) => const SizedBox(),
          ),

          Text(
            'Seçtiğiniz hizmetleri sunan ve ${FirmModel.getPaymentMethodLabel(_selectedPaymentMethod)} kabul eden firmalar:',
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
          const SizedBox(height: 16),
          
          // Firms List
          Expanded(
            child: firmsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Firma listesi alınamadı: $e')),
              data: (firms) {
                // Get Customer Address for Filtering
                final customer = customerAsync.value;
                if (customer == null || customer.addresses.isEmpty) {
                   return const Center(child: Text('Lütfen önce adres ekleyin.'));
                }
                
                final address = customer.selectedAddressIndex < customer.addresses.length
                      ? customer.addresses[customer.selectedAddressIndex]
                      : customer.addresses.first;

                // Filter firms based on selected services, payment method AND LOCATION
                bool isFallbackMode = false;

                // Helper to check basic requirements (Location & Payment)
                bool checkBasicRequirements(FirmModel firm) {
                  if (!firm.isApproved) return false;
                  if (firm.address.city.toLowerCase() != address.city.toLowerCase()) return false;
                  if (!firm.paymentMethods.contains(_selectedPaymentMethod)) return false;
                  return true;
                }

                // 1. Try Strict Filtering (Must have ALL selected services)
                List<FirmModel> filteredFirms = firms.where((firm) {
                   if (!checkBasicRequirements(firm)) return false;
                   
                   final firmServiceIds = firm.services
                      .where((s) => s.enabled)
                      .map((s) => s.serviceId)
                      .toSet();
                   
                   return _selectedServices.every((serviceId) => firmServiceIds.contains(serviceId));
                }).toList();

                // 2. If no firms found, try Relaxed Filtering (Must have AT LEAST ONE service)
                if (filteredFirms.isEmpty) {
                  isFallbackMode = true;
                  filteredFirms = firms.where((firm) {
                    if (!checkBasicRequirements(firm)) return false;

                    final firmServiceIds = firm.services
                        .where((s) => s.enabled)
                        .map((s) => s.serviceId)
                        .toSet();
                    
                    // Check if firm has ANY of the selected services
                    return _selectedServices.any((serviceId) => firmServiceIds.contains(serviceId));
                  }).toList();
                }

                // Sort: 
                // 1. Match Score (only relevant in fallback mode, but safe to always use)
                // 2. Location (Same district first)
                filteredFirms.sort((a, b) {
                  // A. Match Score Calculation
                  if (isFallbackMode) {
                    final aServiceIds = a.services.where((s) => s.enabled).map((s) => s.serviceId).toSet();
                    final bServiceIds = b.services.where((s) => s.enabled).map((s) => s.serviceId).toSet();
                    
                    final aMatchCount = _selectedServices.where((id) => aServiceIds.contains(id)).length;
                    final bMatchCount = _selectedServices.where((id) => bServiceIds.contains(id)).length;
                    
                    if (aMatchCount != bMatchCount) {
                      return bMatchCount.compareTo(aMatchCount); // Higher match first
                    }
                  }

                  // B. Location Preference
                  final aInDistrict = a.address.district.toLowerCase() == address.district.toLowerCase();
                  final bInDistrict = b.address.district.toLowerCase() == address.district.toLowerCase();
                  
                  if (aInDistrict && !bInDistrict) return -1;
                  if (!aInDistrict && bInDistrict) return 1;
                  return 0;
                });

                if (filteredFirms.isEmpty) {
                   return Center(
                     child: Column(
                       mainAxisAlignment: MainAxisAlignment.center,
                       children: [
                         const Icon(Icons.location_off, size: 48, color: Colors.grey),
                         const SizedBox(height: 16),
                         Text(
                           '${address.city} genelinde uygun firma bulunamadı.',
                           textAlign: TextAlign.center,
                           style: const TextStyle(color: CustomerTheme.textDark),
                         ),
                         const SizedBox(height: 8),
                         const Text(
                           'Farklı bir ödeme yöntemi seçmeyi deneyebilirsiniz.',
                           style: TextStyle(color: CustomerTheme.textMedium, fontSize: 12),
                         ),
                       ],
                     ),
                   );
                }

                return Column(
                  children: [
                    if (isFallbackMode)
                      Container(
                        margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orange.withAlpha(100)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline, color: Colors.orange),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Seçtiğiniz tüm hizmetleri sağlayan firma bulunamadı. En uygun eşleşmeler listeleniyor.',
                                style: TextStyle(color: Colors.orange[800], fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredFirms.length,
                        itemBuilder: (context, index) {
                          final firm = filteredFirms[index];
                          return _buildFirmCard(firm);
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFirmCard(FirmModel firm) {
    return GestureDetector(
      onTap: () {
        _selectedFirm = firm;
        setState(() => _currentStep = 2);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: CustomerTheme.softPink,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: CustomerTheme.primary.withAlpha(50)),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: CustomerTheme.primary,
                borderRadius: BorderRadius.circular(12),
                image: ImageUtils.getSafeImageProvider(firm.logo) != null 
                    ? DecorationImage(
                        image: ImageUtils.getSafeImageProvider(firm.logo)!, 
                        fit: BoxFit.cover)
                    : null,
              ),
              child: ImageUtils.getSafeImageProvider(firm.logo) == null
                  ? Center(child: Text(firm.name.isNotEmpty ? firm.name[0] : '?', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)))
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(firm.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.star, size: 16, color: Colors.amber[700]),
                      Text(' ${firm.rating.toStringAsFixed(1)}', style: const TextStyle(fontWeight: FontWeight.w500)),
                      const SizedBox(width: 12),
                      const Icon(Icons.location_on, size: 16, color: CustomerTheme.primary),
                      Expanded(child: Text(' ${firm.address.shortAddress}', overflow: TextOverflow.ellipsis)),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: CustomerTheme.primary.withAlpha(30),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.chevron_right, color: CustomerTheme.primary),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== STEP 3: ORDER DETAILS ====================
  Widget _buildStep3OrderDetails(List<ServiceModel> services) {
    if (_selectedFirm == null) {
      return const Center(child: Text('Firma seçilmedi'));
    }

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back button & Title
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => setState(() => _currentStep = 1),
                    ),
                    Expanded(
                      child: Text(
                        '${_selectedFirm!.name} Sipariş',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Service Selection Header
                const Text('Hizmet Seçimi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                
                // Service Items with Quantity
                ..._selectedServices.map((serviceId) {
                  final service = services.firstWhere((s) => s.id == serviceId, orElse: () => ServiceModel(id: serviceId, name: '??', icon: '', units: []));
                  final firmService = _selectedFirm!.services.firstWhere(
                    (s) => s.serviceId == serviceId,
                    orElse: () => ServicePriceModel(
                      serviceId: serviceId,
                      serviceName: service.name,
                      price: 0.0,
                      unit: service.units.isNotEmpty ? service.units.first : 'adet',
                      enabled: true,
                    ),
                  );
                  
                  return _buildServiceQuantityItem(
                    serviceId,
                    firmService.serviceName,
                    firmService.price,
                    firmService.unit,
                  );
                }),
                
                const SizedBox(height: 24),
                
                // Payment Method
                const Text('Ödeme Yöntemi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: [
                    _buildPaymentMethodDisplay(FirmModel.paymentCash, 'Nakit'),
                    _buildPaymentMethodDisplay(FirmModel.paymentCard, 'Kredi Kartı'),
                    _buildPaymentMethodDisplay(FirmModel.paymentTransfer, 'Havale/EFT'),
                  ],
                ),
              ],
            ),
          ),
        ),

        
        // Promo Code Section
        if (_selectedFirm != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_appliedPromoCode != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.withAlpha(30),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.withAlpha(100)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.green),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Kampanya Kodu Uygulandı!',
                                style: TextStyle(color: Colors.green[800], fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '${_appliedPromoCode!.code} - ${_appliedPromoCode!.discountLabel}',
                                style: TextStyle(color: Colors.green[800]),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () {
                             setState(() {
                               _appliedPromoCode = null;
                               _promoCodeController.clear();
                             });
                          },
                        ),
                      ],
                    ),
                  )
                else
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _promoCodeController,
                          textCapitalization: TextCapitalization.characters,
                          decoration: InputDecoration(
                            hintText: 'Kampanya Kodu',
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            errorText: _promoError,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: _isCheckingPromo ? null : _applyPromoCode,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: _isCheckingPromo 
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                            : const Text('Uygula'),
                      ),
                    ],
                  ),
              ],
            ),
          ),

        // Bottom Section - Estimated Price & Submit Button
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(20),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Info Note
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: CustomerTheme.secondary.withAlpha(30),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: CustomerTheme.secondary.withAlpha(100)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: CustomerTheme.secondary, size: 20),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Hizmet fiyatları firma ölçümü sonrası netleşecektir. Buradaki fiyatlar tahmini birim fiyatlardır.',
                        style: TextStyle(fontSize: 12, color: CustomerTheme.textMedium),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Estimated Price
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Tahmini Tutar:', style: TextStyle(fontSize: 16)),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Ölçüm Bekleniyor',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: CustomerTheme.primary,
                          ),
                        ),
                        if (_appliedPromoCode != null)
                          Text(
                            'İndirim uygulanacak',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green[700],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              const SizedBox(height: 16),
              
              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _hasAnyQuantity() ? () => _submitOrder(services) : null,
                  icon: const Icon(Icons.send),
                  label: const Text(
                    'Firmaya İlet',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CustomerTheme.primary,
                    disabledBackgroundColor: CustomerTheme.divider,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

    bool _hasAnyQuantity() {
      return _quantities.values.any((qty) => qty > 0);
    }

    Future<void> _submitOrder(List<ServiceModel> services) async {
      if (_selectedFirm == null) return;
      if (_selectedFirm!.id.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Firma seçimi geçersiz.')),
          );
        }
        return;
      }

      // Get current customer
      final customer = ref.read(currentCustomerProvider).value;
      final orderRepo = ref.read(orderRepositoryProvider);
      final firmRepo = ref.read(firmRepositoryProvider);

      // Build order items
      final List<OrderItemModel> orderItems = [];
      for (final serviceId in _selectedServices) {
        final quantity = _quantities[serviceId] ?? 0;
        if (quantity > 0) {
          final service = services.firstWhere((s) => s.id == serviceId);
          final firmService = _selectedFirm!.services.firstWhere(
            (s) => s.serviceId == serviceId,
            orElse: () => ServicePriceModel(
              serviceId: serviceId,
              serviceName: service.name,
              price: 0.0,
              unit: service.units.isNotEmpty ? service.units.first : 'adet',
              enabled: true,
            ),
          );
          
          orderItems.add(OrderItemModel(
            serviceId: serviceId,
            serviceName: firmService.serviceName,
            unit: firmService.unit,
            quantity: quantity,
            unitPrice: firmService.price,
          ));
        }
      }

      if (orderItems.isEmpty) return;

      // Create order model
      final order = OrderModel(
        id: '', // Will be assigned by Firebase
        firmId: _selectedFirm!.id,
        firmName: _selectedFirm!.name,
        firmPhone: _selectedFirm!.phone,
        customerId: customer?.id ?? 'demo_customer',
        customerName: customer?.fullName ?? 'Demo Müşteri',
        customerPhone: customer?.phone ?? '5551234567',
        customerAddress: customer?.address ?? AddressModel(
          city: 'İstanbul',
          district: 'Kadıköy',
          area: '',
          neighborhood: 'Caferağa',
          fullAddress: 'Demo Adres',
        ),
        paymentMethod: _selectedPaymentMethod,
        status: OrderModel.statusPending,
        items: orderItems,
        createdAt: DateTime.now(),
        // Promo fields
        promoCode: _appliedPromoCode?.code,
        promoCodeType: _appliedPromoCode?.type,
        promoCodeValue: _appliedPromoCode?.value,
        discountAmount: 0, // Ölçüm sonrası hesaplanacak
      );

      try {
        // Save order to Firebase
        await orderRepo.createOrder(order);

        // Mark code as used if applied
        if (_appliedPromoCode != null) {
          try {
            await ref.read(promoCodeRepositoryProvider).usePromoCode(_appliedPromoCode!.id);
          } catch (e) {
            debugPrint('Error marking promo code as used: $e');
            // Sipariş oluştu, bu hata kritik değil
          }
        }

        // Try to send SMS to firm and deduct balance
        bool smsSent = false;
        if (!_selectedFirm!.id.startsWith('mock_')) {
          // Check if firm has SMS balance
          final deducted = await firmRepo.deductSmsBalance(_selectedFirm!.id, 1);
          if (deducted) {
            // Send SMS notification to firm
            smsSent = await orderRepo.sendNewOrderSmsToFirm(
              firmPhone: _selectedFirm!.phone,
              customerName: order.customerName,
              customerAddress: order.customerAddress.shortAddress,
              items: orderItems,
            );
          }
        }

        // Complete and show success
        widget.onComplete(_selectedFirm!.id);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(smsSent 
                ? 'Siparişiniz firmaya iletildi! (SMS gönderildi)'
                : 'Siparişiniz sisteme kaydedildi!'),
              backgroundColor: CustomerTheme.success,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Hata: $e'),
              backgroundColor: CustomerTheme.error,
            ),
          );
        }
      }
    }

    Widget _buildServiceQuantityItem(String serviceId, String name, double price, String unit) {
      final quantity = _quantities[serviceId] ?? 0;

      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: CustomerTheme.divider),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(
                    '₺${price.toStringAsFixed(0)} / $unit',
                    style: TextStyle(color: CustomerTheme.primary, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                const Text('Adet:', style: TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(width: 12),
                // Decrease button
                GestureDetector(
                  onTap: () {
                    if (quantity > 0) {
                      setState(() => _quantities[serviceId] = quantity - 1);
                    }
                  },
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: quantity > 0 ? Colors.red[50] : Colors.grey[200],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.remove,
                      color: quantity > 0 ? Colors.red : Colors.grey,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Quantity
                Text(
                  '$quantity',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 12),
                // Increase button
                GestureDetector(
                  onTap: () {
                    setState(() => _quantities[serviceId] = quantity + 1);
                  },
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: CustomerTheme.success.withAlpha(50),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.add, color: CustomerTheme.success),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

  Widget _buildPaymentMethodDisplay(String method, String label) {
    final isSelected = _selectedPaymentMethod == method;
    
    return Chip(
      label: Text(label),
      backgroundColor: isSelected ? CustomerTheme.primary : Colors.grey[200],
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      avatar: isSelected ? const Icon(Icons.check, color: Colors.white, size: 18) : null,
    );
  }

  Future<void> _applyPromoCode() async {
    final code = _promoCodeController.text.trim();
    if (code.isEmpty) return;

    if (_selectedFirm == null) {
      setState(() => _promoError = 'Önce firma seçmelisiniz');
      return;
    }

    setState(() {
      _isCheckingPromo = true;
      _promoError = null;
    });

    try {
      final repo = ref.read(promoCodeRepositoryProvider);
      final promo = await repo.validatePromoCode(code, _selectedFirm!.id);

      if (mounted) {
        if (promo != null) {
          setState(() {
            _appliedPromoCode = promo;
            _promoCodeController.text = promo.code; // Normalize
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('İndirim uygulandı: ${promo.discountLabel}'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          setState(() => _promoError = 'Geçersiz veya süresi dolmuş kod');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _promoError = 'Hata: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isCheckingPromo = false);
      }
    }
  }
}
