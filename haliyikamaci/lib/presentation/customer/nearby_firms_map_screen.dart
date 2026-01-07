import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

import '../../core/theme/customer_theme.dart';
import '../../data/providers/providers.dart';
import '../../data/models/models.dart';

/// NearbyFirmsMapScreen - Shows firms on OpenStreetMap
class NearbyFirmsMapScreen extends ConsumerStatefulWidget {
  const NearbyFirmsMapScreen({super.key});

  @override
  ConsumerState<NearbyFirmsMapScreen> createState() => _NearbyFirmsMapScreenState();
}

class _NearbyFirmsMapScreenState extends ConsumerState<NearbyFirmsMapScreen> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  
  // Default center: Istanbul, Kadıköy
  final LatLng _defaultCenter = const LatLng(40.9906, 29.0297);
  
  FirmModel? _selectedFirm;
  
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final firmsAsync = ref.watch(approvedFirmsProvider);

    return Theme(
      data: CustomerTheme.theme,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Yakındaki Firmalar'),
          backgroundColor: CustomerTheme.surface,
          foregroundColor: CustomerTheme.textDark,
        ),
        body: Stack(
          children: [
            // Map
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _defaultCenter,
                initialZoom: 14,
                onTap: (_, p) => setState(() => _selectedFirm = null),
              ),
              children: [
                // OpenStreetMap Tiles
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.haliyikamaci.app',
                ),
                // Firm Markers
                firmsAsync.when(
                  data: (firms) => MarkerLayer(
                    markers: _buildMarkers(firms),
                  ),
                  loading: () => const MarkerLayer(markers: []),
                  error: (_, __) => const MarkerLayer(markers: []),
                ),
              ],
            ),
            
            // Search Bar
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(25),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Firma veya konum ara...',
                    prefixIcon: const Icon(Icons.search, color: CustomerTheme.primary),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.my_location, color: CustomerTheme.primary),
                      onPressed: _goToCurrentLocation,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  ),
                  onSubmitted: _searchLocation,
                ),
              ),
            ),
            
            // Zoom Controls
            Positioned(
              left: 16,
              bottom: 80,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FloatingActionButton.small(
                    heroTag: 'zoom_in',
                    onPressed: () {
                      final currentZoom = _mapController.camera.zoom;
                      _mapController.move(_mapController.camera.center, currentZoom + 1);
                    },
                    backgroundColor: Colors.white,
                    foregroundColor: CustomerTheme.textDark,
                    child: const Icon(Icons.add),
                  ),
                  const SizedBox(height: 8),
                  FloatingActionButton.small(
                    heroTag: 'zoom_out',
                    onPressed: () {
                      final currentZoom = _mapController.camera.zoom;
                      _mapController.move(_mapController.camera.center, currentZoom - 1);
                    },
                    backgroundColor: Colors.white,
                    foregroundColor: CustomerTheme.textDark,
                    child: const Icon(Icons.remove),
                  ),
                ],
              ),
            ),
            
            // Selected Firm Card
            if (_selectedFirm != null)
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: _buildFirmCard(_selectedFirm!),
              ),
          ],
        ),
        // Center on current location button
        floatingActionButton: FloatingActionButton(
          heroTag: 'my_location', // Added heroTag to prevent conflict
          onPressed: _goToCurrentLocation,
          backgroundColor: CustomerTheme.primary,
          child: const Icon(Icons.my_location, color: Colors.white),
        ),
      ),
    );
  }

  List<Marker> _buildMarkers(List<FirmModel> firms) {
    final markers = <Marker>[];
    
    // Use real firms with valid coordinates
    for (final firm in firms) {
      if (firm.address.latitude != null && firm.address.longitude != null) {
        markers.add(
          Marker(
            point: LatLng(firm.address.latitude!, firm.address.longitude!),
            width: 50,
            height: 50,
            child: GestureDetector(
              onTap: () => setState(() => _selectedFirm = firm),
              child: Container(
                decoration: BoxDecoration(
                  color: _selectedFirm?.id == firm.id 
                      ? CustomerTheme.primary 
                      : Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: CustomerTheme.primary, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(50),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    Icons.store,
                    color: _selectedFirm?.id == firm.id 
                        ? Colors.white 
                        : CustomerTheme.primary,
                    size: 24,
                  ),
                ),
              ),
            ),
          ),
        );
      }
    }
    
    return markers;
  }



  Widget _buildFirmCard(FirmModel firm) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: CustomerTheme.primary,
                child: Text(
                  firm.name.substring(0, 1),
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      firm.name,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        Text(' ${firm.rating.toStringAsFixed(1)} (${firm.reviewCount} yorum)'),
                      ],
                    ),
                  ],
                ),
              ),
              Consumer(
                builder: (context, ref, _) {
                  final favorites = ref.watch(localFavoritesProvider);
                  final isFavorite = favorites.contains(firm.id);
                  return IconButton(
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.red : CustomerTheme.primary,
                    ),
                    onPressed: () => ref.read(localFavoritesProvider.notifier).toggleFavorite(firm.id),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => setState(() => _selectedFirm = null),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.location_on, color: CustomerTheme.textMedium, size: 16),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  firm.address.fullAddressDisplay,
                  style: const TextStyle(color: CustomerTheme.textMedium),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _callFirm(firm.phone),
                  icon: const Icon(Icons.phone, size: 18),
                  label: const Text('Ara'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: CustomerTheme.primary,
                    side: const BorderSide(color: CustomerTheme.primary),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _getDirections(firm),
                  icon: const Icon(Icons.directions, size: 18),
                  label: const Text('Yol Tarifi'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CustomerTheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _goToCurrentLocation() async {
    try {
      // 1. Check if location services are enabled.
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Konum servisleri kapalı. Lütfen açın.')),
          );
        }
        return;
      }

      // 2. Check permissions.
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Konum izni reddedildi.')),
            );
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Konum izni kalıcı olarak reddedildi. Ayarlardan açın.')),
          );
        }
        return;
      }

      // 3. Get Position
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Konum bulunuyor...'), duration: Duration(seconds: 1)),
      );

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );

      // 4. Move Map
      _mapController.move(LatLng(position.latitude, position.longitude), 15);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Konumunuza gidildi'),
            backgroundColor: CustomerTheme.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    }
  }

  Future<void> _searchLocation(String query) async {
    if (query.isEmpty) return;
    
    // Close keyboard
    FocusScope.of(context).unfocus();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('"$query" aranıyor...'),
        duration: const Duration(seconds: 1),
      ),
    );

    try {
      List<Location> locations = await locationFromAddress(query);
      
      if (locations.isNotEmpty && mounted) {
        final loc = locations.first;
        _mapController.move(LatLng(loc.latitude, loc.longitude), 15);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Konum bulundu'),
            backgroundColor: CustomerTheme.success,
          ),
        );
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Konum bulunamadı'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Arama hatası: $e'), 
            backgroundColor: Colors.red
          ),
        );
      }
    }
  }

  void _callFirm(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Aranıyor: $phone'), backgroundColor: CustomerTheme.success),
        );
      }
    }
  }

  void _getDirections(FirmModel firm) async {
    final address = Uri.encodeComponent(firm.address.fullAddress);
    final uri = Uri.parse('https://www.openstreetmap.org/search?query=$address');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${firm.name} için yol tarifi açılıyor...'),
            backgroundColor: CustomerTheme.primary,
          ),
        );
      }
    }
  }
}
