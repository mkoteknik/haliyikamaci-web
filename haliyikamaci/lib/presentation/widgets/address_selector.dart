import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

import '../../core/theme/app_theme.dart';
import '../../data/services/turkiye_api_service.dart';
import '../../data/models/models.dart';

/// Reusable Address Selector Widget using TurkiyeAPI
/// Provides İl → İlçe → Mahalle cascade dropdowns
class AddressSelector extends StatefulWidget {
  final Function(AddressModel)? onAddressSelected; // Triggered by internal Save button
  final Function(Province?, District?, Neighborhood?)? onChanged; // Triggered on dropdown change
  final Province? initialProvince;
  final District? initialDistrict;
  final Neighborhood? initialNeighborhood;
  final String? initialFullAddress;
  final String? initialTitle; // New param
  final String? initialProvinceName; // New param for Edit
  final String? initialDistrictName; // New param for Edit
  final String? initialNeighborhoodName; // New param for Edit
  final TextEditingController? addressController; // External controller support
  final TextEditingController? titleController; // External title controller support
  final bool showButton; // Toggle internal save button
  
  const AddressSelector({
    super.key,
    this.onAddressSelected,
    this.onChanged,
    this.initialProvince,
    this.initialDistrict,
    this.initialNeighborhood,
    this.initialFullAddress,
    this.initialTitle, // New param
    this.initialProvinceName, // New param
    this.initialDistrictName, // New param
    this.initialNeighborhoodName, // New param
    this.addressController,
    this.titleController,
    this.showButton = true,
  });

  @override
  State<AddressSelector> createState() => _AddressSelectorState();
}

class _AddressSelectorState extends State<AddressSelector> {
  // Data
  List<Province> _provinces = [];
  List<District> _districts = [];
  List<Neighborhood> _neighborhoods = [];
  
  // Selected values
  Province? _selectedProvince;
  District? _selectedDistrict;
  Neighborhood? _selectedNeighborhood;
  Position? _detectedPosition; // Store detected position
  
  // Controllers
  late TextEditingController _addressController;
  late TextEditingController _titleController; // New controller
  
  // Loading states
  bool _isLoadingProvinces = true;
  bool _isLoadingDistricts = false;
  bool _isLoadingNeighborhoods = false;
  bool _isLoadingLocation = false;

  @override
  void initState() {
    super.initState();
    _selectedProvince = widget.initialProvince;
    _selectedDistrict = widget.initialDistrict;
    _selectedNeighborhood = widget.initialNeighborhood;
    
    // Use external controller if provided, otherwise create local
    _addressController = widget.addressController ?? TextEditingController();
    _titleController = widget.titleController ?? TextEditingController(text: widget.initialTitle ?? ''); // Use external or create local
    
    if (widget.initialFullAddress != null && widget.addressController == null) {
      _addressController.text = widget.initialFullAddress!;
    }
    
    _initializeSelection();
  }
  
  Future<void> _initializeSelection() async {
    // 1. Load Provinces
    await _loadProvinces();
    
    // 2. Initial Selection Logic (Name-based for Edit)
    if (widget.initialProvinceName != null && _selectedProvince == null) {
      final p = _provinces.cast<Province?>().firstWhere(
        (e) => e?.name == widget.initialProvinceName, 
        orElse: () => null
      );
      
      if (p != null) {
        if (mounted) setState(() => _selectedProvince = p);
        
        // Load Districts
        await _loadDistricts(p);
        
        if (widget.initialDistrictName != null) {
            final d = _districts.cast<District?>().firstWhere(
                (e) => e?.name == widget.initialDistrictName, 
                orElse: () => null
            );
            
            if (d != null) {
                if (mounted) setState(() => _selectedDistrict = d);
                
                // Load Neighborhoods
                await _loadNeighborhoods(d);
                
                if (widget.initialNeighborhoodName != null) {
                     final n = _neighborhoods.cast<Neighborhood?>().firstWhere(
                         (e) => e?.name == widget.initialNeighborhoodName, 
                         orElse: () => null
                     );
                     
                     if (n != null) {
                         if (mounted) setState(() => _selectedNeighborhood = n);
                     }
                }
            }
        }
      }
    }
    
    // Notify changes after initialization
    _notifyChanged();
  }
  
  @override
  void dispose() {
    // Only dispose if we created it
    if (widget.addressController == null) {
      _addressController.dispose();
    }
    if (widget.titleController == null) {
      _titleController.dispose();
    }
    super.dispose();
  }

  // ... (Methods _notifyChanged, _loadProvinces, _loadDistricts, _loadNeighborhoods remain same)
  void _notifyChanged() {
    if (widget.onChanged != null) {
      widget.onChanged!(_selectedProvince, _selectedDistrict, _selectedNeighborhood);
    }
  }

  Future<void> _loadProvinces() async {
    setState(() => _isLoadingProvinces = true);
    try {
      final provinces = await TurkiyeApiService.getProvinces();
      provinces.sort((a, b) => a.name.compareTo(b.name));
      if (mounted) {
        setState(() {
          _provinces = provinces;
          _isLoadingProvinces = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading provinces: $e');
      if (mounted) setState(() => _isLoadingProvinces = false);
    }
  }

  Future<void> _loadDistricts(Province province) async {
    setState(() {
      _isLoadingDistricts = true;
      _districts = [];
      _neighborhoods = [];
      _selectedDistrict = null;
      _selectedNeighborhood = null;
    });
    
    try {
      final districts = await TurkiyeApiService.getDistrictsByProvinceId(province.id);
      districts.sort((a, b) => a.name.compareTo(b.name));
      if (mounted) {
        setState(() {
          _districts = districts;
          _isLoadingDistricts = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading districts: $e');
      if (mounted) setState(() => _isLoadingDistricts = false);
    }
    _notifyChanged();
  }

  Future<void> _loadNeighborhoods(District district) async {
    setState(() {
      _isLoadingNeighborhoods = true;
      _neighborhoods = [];
      _selectedNeighborhood = null;
    });
    
    try {
      final neighborhoods = await TurkiyeApiService.getNeighborhoodsByDistrictId(district.id);
      neighborhoods.sort((a, b) => a.name.compareTo(b.name));
      if (mounted) {
        setState(() {
          _neighborhoods = neighborhoods;
          _isLoadingNeighborhoods = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading neighborhoods: $e');
      if (mounted) setState(() => _isLoadingNeighborhoods = false);
    }
    _notifyChanged();
  }


  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Title Field
        TextField(
          controller: _titleController,
          decoration: const InputDecoration(
            labelText: 'Adres Başlığı',
            hintText: 'Örn: Ev, İş, Annem...',
            prefixIcon: Icon(Icons.label),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),

        // Province (İl) Dropdown
        _buildDropdown<Province>(
          label: 'İl',
          icon: Icons.location_city,
          hint: _isLoadingProvinces ? 'Yükleniyor...' : 'İl Seçin',
          value: _selectedProvince,
          items: _provinces,
          isLoading: _isLoadingProvinces,
          itemLabel: (p) => p.name,
          onChanged: (province) {
            if (province != null && province != _selectedProvince) {
              setState(() => _selectedProvince = province);
              _loadDistricts(province);
            }
          },
        ),
        
        const SizedBox(height: 16),
        
        // District (İlçe) Dropdown
        _buildDropdown<District>(
          label: 'İlçe',
          icon: Icons.map,
          hint: _isLoadingDistricts 
              ? 'Yükleniyor...' 
              : (_selectedProvince == null ? 'Önce il seçin' : 'İlçe Seçin'),
          value: _selectedDistrict,
          items: _districts,
          isLoading: _isLoadingDistricts,
          isEnabled: _selectedProvince != null,
          itemLabel: (d) => d.name,
          onChanged: (district) {
            if (district != null && district != _selectedDistrict) {
              setState(() => _selectedDistrict = district);
              _loadNeighborhoods(district);
            }
          },
        ),
        
        const SizedBox(height: 16),
        
        // Neighborhood (Mahalle) Dropdown
        _buildDropdown<Neighborhood>(
          label: 'Mahalle',
          icon: Icons.home,
          hint: _isLoadingNeighborhoods 
              ? 'Yükleniyor...' 
              : (_selectedDistrict == null ? 'Önce ilçe seçin' : 'Mahalle Seçin'),
          value: _selectedNeighborhood,
          items: _neighborhoods,
          isLoading: _isLoadingNeighborhoods,
          isEnabled: _selectedDistrict != null,
          itemLabel: (n) => n.name,
          onChanged: (neighborhood) {
            if (neighborhood != null) {
              setState(() => _selectedNeighborhood = neighborhood);
              _notifyChanged();
            }
          },
        ),
        
        const SizedBox(height: 16),

        // Open Address Field
        TextField(
          controller: _addressController,
          maxLines: 2,
          decoration: const InputDecoration(
            labelText: 'Açık Adres',
            hintText: 'Sokak, Bina No, Daire...',
            prefixIcon: Icon(Icons.edit_location),
            border: OutlineInputBorder(),
          ),
        ),
        
        const SizedBox(height: 16),

        // Find Location Button
        Center(
          child: TextButton.icon(
            onPressed: _isLoadingLocation ? null : _detectLocation,
            icon: _isLoadingLocation 
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.my_location),
            label: Text(_isLoadingLocation ? 'Konum Alınıyor...' : 'Konumu Otomatik Bul'),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ),

        if (widget.showButton) ...[
          const SizedBox(height: 24),
          // Save Button
          ElevatedButton(
            onPressed: _isValid() ? _saveAddress : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue, // Corrected from primaryColor
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Adresi Kaydet', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ],
      ],
    );
  }
  
  bool _isValid() {
    return _selectedProvince != null && 
           _selectedDistrict != null && 
           _selectedNeighborhood != null && 
           _addressController.text.trim().isNotEmpty &&
           _titleController.text.trim().isNotEmpty;
  }
  
  void _saveAddress() {
    if (!_isValid() || widget.onAddressSelected == null) return;
    
    final newAddress = AddressModel(
      title: _titleController.text.trim(),
      city: _selectedProvince!.name,
      district: _selectedDistrict!.name,
      neighborhood: _selectedNeighborhood!.name,
      area: '',
      fullAddress: _addressController.text.trim(),
      latitude: _detectedPosition?.latitude,
      longitude: _detectedPosition?.longitude,
    );
    
    widget.onAddressSelected!(newAddress);
  }

  Future<void> _detectLocation() async {
    setState(() => _isLoadingLocation = true);
    try {
      // 1. Permission Check
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw 'Konum izni reddedildi.';
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        throw 'Konum izni kalıcı olarak reddedildi, ayarlardan açmanız gerekiyor.';
      }

      // 2. Get Location
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(timeLimit: Duration(seconds: 5)),
      );
      
      setState(() => _detectedPosition = position); // Store position
      
      // 3. Reverse Geocoding
      final placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      if (placemarks.isEmpty) throw 'Adres bulunamadı.';
      
      final place = placemarks.first;
      final cityName = place.administrativeArea ?? '';
      final districtName = place.subAdministrativeArea ?? '';
      final neighborhoodName = place.subLocality ?? '';
      
      // Construct Full Address
      final thoroughfare = place.thoroughfare ?? '';
      final subThoroughfare = place.subThoroughfare ?? '';
      
      String fullAddress = '';
      if (thoroughfare.isNotEmpty) fullAddress += '$thoroughfare ';
      if (subThoroughfare.isNotEmpty) fullAddress += 'No: $subThoroughfare';
      if (fullAddress.trim().isNotEmpty) {
        _addressController.text = fullAddress;
      }

      // 4. Match Province
      final matchedProvince = _provinces.cast<Province?>().firstWhere(
        (p) => p?.name.toLowerCase() == cityName.toLowerCase(),
        orElse: () => null
      );
      
      if (matchedProvince != null) {
        setState(() => _selectedProvince = matchedProvince);
        
        setState(() {
            _isLoadingDistricts = true;
            _districts = [];
            _neighborhoods = [];
            _selectedDistrict = null;
            _selectedNeighborhood = null;
        });

        final districts = await TurkiyeApiService.getDistrictsByProvinceId(matchedProvince.id);
        districts.sort((a, b) => a.name.compareTo(b.name));
        
        setState(() {
            _districts = districts;
            _isLoadingDistricts = false;
        });

        // 5. Match District
        final matchedDistrict = _districts.cast<District?>().firstWhere(
            (d) => d?.name.toLowerCase() == districtName.toLowerCase(),
             orElse: () => null
        );

        if (matchedDistrict != null) {
            setState(() => _selectedDistrict = matchedDistrict);

            // Load Neighborhoods
            setState(() {
                _isLoadingNeighborhoods = true;
                _neighborhoods = [];
                _selectedNeighborhood = null;
            });
            
            final neighborhoods = await TurkiyeApiService.getNeighborhoodsByDistrictId(matchedDistrict.id);
            neighborhoods.sort((a, b) => a.name.compareTo(b.name));
            
            setState(() {
                _neighborhoods = neighborhoods;
                _isLoadingNeighborhoods = false;
            });

             // 6. Match Neighborhood
             final cleanNeighborhoodName = neighborhoodName.replaceAll('Mahallesi', '').replaceAll('Mah.', '').trim();

             final matchedNeighborhood = _neighborhoods.cast<Neighborhood?>().firstWhere(
                 (n) => n?.name.toLowerCase().contains(cleanNeighborhoodName.toLowerCase()) ?? false,
                 orElse: () => null
             );

             if (matchedNeighborhood != null) {
                 setState(() => _selectedNeighborhood = matchedNeighborhood);
             }
        }
        
        _notifyChanged();
        
        if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Adres konumdan otomatik dolduruldu.')),
            );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Bulunduğunuz il ($cityName) listede bulunamadı.')),
          );
        }
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Konum hatası: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingLocation = false);
      }
    }
  }

  Widget _buildDropdown<T>({
    required String label,
    required IconData icon,
    required String hint,
    required T? value,
    required List<T> items,
    required bool isLoading,
    required String Function(T) itemLabel,
    required void Function(T?) onChanged,
    bool isEnabled = true,
  }) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        suffixIcon: isLoading 
            ? const SizedBox(
                width: 20,
                height: 20,
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            : null,
      ),
      hint: Text(hint),
      items: items.map((item) => DropdownMenuItem<T>(
        value: item,
        child: Text(itemLabel(item)),
      )).toList(),
      onChanged: isEnabled && !isLoading ? onChanged : null,
      isExpanded: true,
    );
  }
}
