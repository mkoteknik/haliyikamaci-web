import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/models.dart';
import '../../data/services/turkiye_api_service.dart';
import '../../data/providers/providers.dart';
import '../widgets/address_selector.dart';
import '../widgets/legal_agreements_widget.dart';
import '../../l10n/generated/app_localizations.dart';

class CustomerRegisterScreen extends ConsumerStatefulWidget {
  const CustomerRegisterScreen({super.key});

  @override
  ConsumerState<CustomerRegisterScreen> createState() => _CustomerRegisterScreenState();
}

class _CustomerRegisterScreenState extends ConsumerState<CustomerRegisterScreen> {
  int _currentStep = 0;
  
  // Step 1 Controllers
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  // Step 2 Address - Using TurkiyeAPI models
  Province? _selectedProvince;
  District? _selectedDistrict;
  Neighborhood? _selectedNeighborhood;
  final _addressController = TextEditingController();
  bool _isSaving = false;
  bool _obscurePassword = true;

  // Step 3 Legal Agreements
  bool _agreementsAccepted = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.createCustomerRegistration),
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

          // Step 1: Kişisel Bilgiler & Şifre
          Step(
            title: Text(l10n.personalInfo),
            subtitle: Text(l10n.personalInfo),
            isActive: _currentStep >= 0,
            state: _currentStep > 0 ? StepState.complete : StepState.indexed,
            content: Column(
              children: [
                const SizedBox(height: 8),
                TextField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    labelText: l10n.fullName,
                    prefixIcon: const Icon(Icons.person),
                    hintText: l10n.fullName,
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
              ],
            ),
          ),
          
          // Step 2: Adres Bilgileri
          Step(
            title: Text(l10n.addressInfo),
            subtitle: Text(l10n.addressDetails),
            isActive: _currentStep >= 1,
            state: _currentStep > 1 ? StepState.complete : StepState.indexed,
            content: Column(
              children: [
                const SizedBox(height: 8),
                
                // TurkiyeAPI Address Selector
                AddressSelector(
                  initialTitle: l10n.address, // Ev Adresi yerine l10n.address veya l10n.homeAddress
                  addressController: _addressController,
                  showButton: false, // Save button handled by stepper
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
      if (_nameController.text.isEmpty || _phoneController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.fillAllFields)),
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
      final authRepo = ref.read(authRepositoryProvider);
      
      // 1. Check if phone already registered (Prevent override)
      final existingUser = await authRepo.getUserByPhone(_phoneController.text.trim());
      if (existingUser != null) {
         throw Exception(l10n.phoneAlreadyRegistered);
      }

      // 2. Create Auth User with Password
      final userCred = await authRepo.registerWithPassword(
        _phoneController.text.trim(), 
        _passwordController.text.trim()
      );
      
      final uid = userCred.user!.uid;

      // 3. Build Models
      final address = AddressModel(
        title: l10n.home, // Use localized Home title
        city: _selectedProvince?.name ?? '',
        district: _selectedDistrict?.name ?? '',
        area: '',
        neighborhood: _selectedNeighborhood?.name ?? '',
        fullAddress: _addressController.text,
      );

      final customer = CustomerModel(
        id: uid, 
        uid: uid,
        name: _nameController.text,
        surname: '',
        phone: _phoneController.text.trim(),
        address: address,
        createdAt: DateTime.now(),
      );

      final userModel = UserModel(
        uid: uid,
        phone: _phoneController.text.trim(),
        userType: 'customer',
        createdAt: DateTime.now(),
      );

      // 4. Save to Firestore
      final customerRepo = ref.read(customerRepositoryProvider);

      await authRepo.createUser(userModel);
      await customerRepo.createCustomer(customer);
      
      // Refresh provider
      ref.invalidate(currentCustomerProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.registrationCompleted)),
        );
        context.go('/customer');
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
