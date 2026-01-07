import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/models.dart';
import '../../data/services/turkiye_api_service.dart';
import '../../data/providers/providers.dart';
import '../widgets/address_selector.dart';
import '../widgets/legal_agreements_widget.dart';
import '../../l10n/generated/app_localizations.dart';

class FirmRegisterScreen extends ConsumerStatefulWidget {
  const FirmRegisterScreen({super.key});

  @override
  ConsumerState<FirmRegisterScreen> createState() => _FirmRegisterScreenState();
}

class _FirmRegisterScreenState extends ConsumerState<FirmRegisterScreen> {
  int _currentStep = 0;
  
  // Step 1 Controllers
  final _firmNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _whatsappController = TextEditingController();
  final _taxNumberController = TextEditingController();
  bool _obscurePassword = true;
  
  // Step 2 Address - Using TurkiyeAPI models
  Province? _selectedProvince;
  District? _selectedDistrict;
  Neighborhood? _selectedNeighborhood;
  final _addressController = TextEditingController();
  bool _isSaving = false;

  // Step 3 Legal Agreements
  bool _agreementsAccepted = false;

  @override
  void dispose() {
    _firmNameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _whatsappController.dispose();
    _taxNumberController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.createFirmRegistration),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/login');
            }
          },
        ),
      ),
      body: Stepper(
        currentStep: _currentStep,
        onStepContinue: _onStepContinue,
        onStepCancel: _onStepCancel,
        controlsBuilder: (context, details) {
          return Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Row(
              children: [
                ElevatedButton(
                  onPressed: _isSaving ? null : details.onStepContinue,
                  child: _isSaving
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : Text(_currentStep == 2 ? l10n.complete : l10n.next),
                ),
                const SizedBox(width: 12),
                if (_currentStep > 0)
                  OutlinedButton(
                    onPressed: _isSaving ? null : details.onStepCancel,
                    child: Text(l10n.previous),
                  ),
              ],
            ),
          );
        },
        steps: [
          // Step 1: Firma Bilgileri
          Step(
            title: Text(l10n.businessInfo),
            subtitle: Text(l10n.businessInfo),
            isActive: _currentStep >= 0,
            state: _currentStep > 0 ? StepState.complete : StepState.indexed,
            content: Column(
              children: [
                const SizedBox(height: 8),
                TextField(
                  controller: _firmNameController,
                  decoration: InputDecoration(
                    labelText: l10n.firmName,
                    prefixIcon: const Icon(Icons.business),
                  ),
                ),

                const SizedBox(height: 16),
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: l10n.phoneNumber,
                    prefixText: '+90 ',
                    prefixIcon: const Icon(Icons.phone),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: l10n.password,
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _confirmPasswordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: l10n.confirmPassword,
                    prefixIcon: const Icon(Icons.lock_outline),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _whatsappController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: l10n.whatsappNumberOptional,
                    prefixText: '+90 ',
                    prefixIcon: const Icon(Icons.chat),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _taxNumberController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: l10n.taxNumber,
                    prefixIcon: const Icon(Icons.receipt_long),
                    hintText: l10n.tenDigitTaxNumber,
                  ),
                ),
              ],
            ),
          ),
          
          // Step 2: Adres Bilgileri
          Step(
            title: Text(l10n.addressInfo),
            subtitle: Text(l10n.enterFirmAddress),
            isActive: _currentStep >= 1,
            state: _currentStep > 1 ? StepState.complete : StepState.indexed,
            content: Column(
              children: [
                const SizedBox(height: 8),
                
                // TurkiyeAPI Address Selector
                AddressSelector(
                  initialTitle: l10n.businessAddress,
                  addressController: _addressController,
                  showButton: false,
                  onChanged: (province, district, neighborhood) {
                    setState(() {
                      _selectedProvince = province;
                      _selectedDistrict = district;
                      _selectedNeighborhood = neighborhood;
                    });
                  },
                ),
              ],
            ),
          ),

          // Step 3: Yasal Sözleşmeler
          Step(
            title: Text(l10n.contracts),
            subtitle: Text(l10n.contractsSubtitle),
            isActive: _currentStep >= 2,
            state: _currentStep > 2 ? StepState.complete : StepState.indexed,
            content: Column(
              children: [
                const SizedBox(height: 8),
                LegalAgreementsWidget(
                  onAgreementChanged: (allAccepted) {
                    setState(() => _agreementsAccepted = allAccepted);
                  },
                ),
                if (!_agreementsAccepted)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.withAlpha(30),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline, color: Colors.orange),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              l10n.contractsWarning,
                              style: const TextStyle(color: Colors.orange),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _onStepContinue() {
    final l10n = AppLocalizations.of(context)!;
    if (_currentStep == 0) {
      // Validate step 1
      if (_firmNameController.text.isEmpty || _phoneController.text.isEmpty || _taxNumberController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.fillMandatoryFields)),
        );
        return;
      }
      if (_passwordController.text.length < 6) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.passwordMinLength)),
        );
        return;
      }
      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.passwordsDoNotMatch)),
        );
        return;
      }
      setState(() => _currentStep++);
    } else if (_currentStep == 1) {
      // Validate step 2
      if (_selectedProvince == null || _selectedDistrict == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.selectCityDistrict)),
        );
        return;
      }
      setState(() => _currentStep++);
    } else if (_currentStep == 2) {
      // Validate step 3 - Agreements
      if (!_agreementsAccepted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.pleaseApproveContracts)),
        );
        return;
      }
      // Complete registration
      _completeRegistration();
    }
  }

  void _onStepCancel() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  Future<void> _completeRegistration() async {
    setState(() => _isSaving = true);
    final l10n = AppLocalizations.of(context)!;

    try {

      final cleanPhone = _phoneController.text.replaceAll(RegExp(r'\D'), '');
      
      final authRepo = ref.read(authRepositoryProvider);
      final firmRepo = ref.read(firmRepositoryProvider);

      // 1. Check if phone already registered (Prevent override)
      final existingUser = await authRepo.getUserByPhone(cleanPhone);
      if (existingUser != null) {
         throw Exception(l10n.phoneAlreadyRegistered);
      }

      // 2. Create Auth User with Password
      final userCred = await authRepo.registerWithPassword(
        cleanPhone, 
        _passwordController.text.trim()
      );
      
      final uid = userCred.user!.uid;

      // 3. Prepare Data
      final address = AddressModel(
        title: l10n.businessAddress,
        city: _selectedProvince?.name ?? '',
        district: _selectedDistrict?.name ?? '',
        area: '',
        neighborhood: _selectedNeighborhood?.name ?? '',
        fullAddress: _addressController.text,
      );

      final firm = FirmModel(
        id: uid, // Use Auth ID
        uid: uid,
        name: _firmNameController.text,
        phone: cleanPhone,
        whatsapp: _whatsappController.text.replaceAll(RegExp(r'\D'), ''),
        taxNumber: _taxNumberController.text.trim(),
        address: address,
        createdAt: DateTime.now(),
        isApproved: false,  // Admin onayı bekleyecek
      );

      final userModel = UserModel(
        uid: uid,
        phone: cleanPhone,
        userType: 'firm', // Important for role-based login
        createdAt: DateTime.now(),
      );

      // 4. Save to Firestore
      await authRepo.createUser(userModel);
      await firmRepo.createFirm(firm);

      if (mounted) {
        // Show success popup
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            icon: const Icon(Icons.check_circle, color: Colors.green, size: 64),
            title: Text(l10n.registrationReceived),
            content: Text(
              l10n.firmRegistrationSuccessMessage,
              textAlign: TextAlign.center,
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  context.go('/login');
                },
                child: Text(l10n.ok),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.error}: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}
