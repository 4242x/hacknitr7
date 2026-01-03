import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../services/location_service.dart';

class LocationProvider with ChangeNotifier {
  Position? _currentPosition;
  bool _isLoading = false;
  String? _error;
  bool _isTracking = false;

  Position? get currentPosition => _currentPosition;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isTracking => _isTracking;

  Future<void> getCurrentLocation() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentPosition = await LocationService.getCurrentPosition();
      if (_currentPosition == null) {
        _error = 'Unable to get location. Please enable location services.';
      } else {
        _error = null;
      }
    } catch (e) {
      _error = 'Error getting location: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> startTracking() async {
    if (_isTracking) return;
    
    bool hasPermission = await LocationService.checkLocationPermission();
    if (!hasPermission) {
      _error = 'Location permission not granted';
      notifyListeners();
      return;
    }

    _isTracking = true;
    notifyListeners();

    // Update location periodically
    while (_isTracking) {
      await getCurrentLocation();
      await Future.delayed(const Duration(seconds: 5));
    }
  }

  void stopTracking() {
    _isTracking = false;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}





