import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// TurkiyeAPI Service for dynamic location data
/// API: https://api.turkiyeapi.dev
class TurkiyeApiService {
  static const String _baseUrl = 'https://api.turkiyeapi.dev/api/v1';
  
  /// Get all provinces (İller)
  static Future<List<Province>> getProvinces() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/provinces'));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> provincesJson = data['data'];
        return provincesJson.map((p) => Province.fromJson(p)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching provinces: $e');
      return [];
    }
  }
  
  /// Get province by ID with districts
  static Future<Province?> getProvinceById(int id) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/provinces/$id'));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Province.fromJson(data['data']);
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching province: $e');
      return null;
    }
  }
  
  /// Get all districts (İlçeler)
  static Future<List<District>> getDistricts() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/districts'));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> districtsJson = data['data'];
        return districtsJson.map((d) => District.fromJson(d)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching districts: $e');
      return [];
    }
  }
  
  /// Get district by ID with neighborhoods
  static Future<District?> getDistrictById(int id) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/districts/$id'));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return District.fromJson(data['data']);
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching district: $e');
      return null;
    }
  }
  
  /// Get districts by province ID
  static Future<List<District>> getDistrictsByProvinceId(int provinceId) async {
    try {
      final province = await getProvinceById(provinceId);
      return province?.districts ?? [];
    } catch (e) {
      debugPrint('Error fetching districts by province: $e');
      return [];
    }
  }
  
  /// Get neighborhoods by district ID
  static Future<List<Neighborhood>> getNeighborhoodsByDistrictId(int districtId) async {
    try {
      final district = await getDistrictById(districtId);
      return district?.neighborhoods ?? [];
    } catch (e) {
      debugPrint('Error fetching neighborhoods: $e');
      return [];
    }
  }
}

/// Province (İl) Model
class Province {
  final int id;
  final String name;
  final int population;
  final int area;
  final List<int> areaCode;
  final bool isMetropolitan;
  final String region;
  final double? latitude;
  final double? longitude;
  final List<District> districts;
  
  Province({
    required this.id,
    required this.name,
    required this.population,
    required this.area,
    required this.areaCode,
    required this.isMetropolitan,
    required this.region,
    this.latitude,
    this.longitude,
    this.districts = const [],
  });
  
  factory Province.fromJson(Map<String, dynamic> json) {
    final coordinates = json['coordinates'] as Map<String, dynamic>?;
    final regionData = json['region'] as Map<String, dynamic>?;
    
    List<District> districtsList = [];
    if (json['districts'] != null) {
      districtsList = (json['districts'] as List)
          .map((d) => District.fromJson(d))
          .toList();
    }
    
    return Province(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      population: json['population'] ?? 0,
      area: json['area'] ?? 0,
      areaCode: json['areaCode'] != null 
          ? List<int>.from(json['areaCode']) 
          : [],
      isMetropolitan: json['isMetropolitan'] ?? false,
      region: regionData?['tr'] ?? '',
      latitude: coordinates?['latitude']?.toDouble(),
      longitude: coordinates?['longitude']?.toDouble(),
      districts: districtsList,
    );
  }
}

/// District (İlçe) Model
class District {
  final int id;
  final String name;
  final int population;
  final int area;
  final int? provinceId;
  final String? provinceName;
  final List<Neighborhood> neighborhoods;
  
  District({
    required this.id,
    required this.name,
    required this.population,
    required this.area,
    this.provinceId,
    this.provinceName,
    this.neighborhoods = const [],
  });
  
  factory District.fromJson(Map<String, dynamic> json) {
    List<Neighborhood> neighborhoodsList = [];
    if (json['neighborhoods'] != null) {
      neighborhoodsList = (json['neighborhoods'] as List)
          .map((n) => Neighborhood.fromJson(n))
          .toList();
    }
    
    return District(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      population: json['population'] ?? 0,
      area: json['area'] ?? 0,
      provinceId: json['provinceId'],
      provinceName: json['province'],
      neighborhoods: neighborhoodsList,
    );
  }
}

/// Neighborhood (Mahalle) Model
class Neighborhood {
  final int id;
  final String name;
  final int population;
  
  Neighborhood({
    required this.id,
    required this.name,
    required this.population,
  });
  
  factory Neighborhood.fromJson(Map<String, dynamic> json) {
    return Neighborhood(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      population: json['population'] ?? 0,
    );
  }
}
