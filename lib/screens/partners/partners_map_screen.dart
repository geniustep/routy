import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:routy/controllers/partner_controller.dart';
import 'package:routy/controllers/theme_controller.dart';
import 'package:routy/models/partners/partners_model.dart';
import 'package:routy/services/translation_service.dart';
import 'package:routy/app/app_router.dart';

/// 🗺️ Partners Map Screen
class PartnersMapScreen extends StatefulWidget {
  const PartnersMapScreen({super.key});

  @override
  State<PartnersMapScreen> createState() => _PartnersMapScreenState();
}

class _PartnersMapScreenState extends State<PartnersMapScreen> {
  final PartnerController _partnerController = Get.find<PartnerController>();
  final ThemeController _themeController = Get.find<ThemeController>();

  GoogleMapController? _mapController;
  Set<Marker> _markers = {};

  LatLng? _initialPosition;
  bool _isLoadingLocation = true;
  Position? _currentPosition;
  double _currentZoom = 12.0;
  bool _isInitialLoad = true;
  bool _shouldUpdateMarkers = false;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();

    // الاستماع لتغييرات الشركاء
    ever(_partnerController.partners, (_) {
      // إعادة تعيين initial load عند تغيير الشركاء
      _isInitialLoad = true;
      _loadPartners();
    });

    // تحميل الشركاء عند البداية
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPartners();
    });
  }

  /// Get current user location
  Future<void> _getCurrentLocation() async {
    try {
      // Check permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        // Use default location (Rabat, Morocco)
        setState(() {
          _initialPosition = const LatLng(33.9716, -6.8498);
          _isLoadingLocation = false;
        });
        return;
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      setState(() {
        _currentPosition = position;
        _initialPosition = LatLng(position.latitude, position.longitude);
        _isLoadingLocation = false;
      });

      // Move camera to current location if map is already loaded
      if (_mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(_initialPosition!, 12),
        );
      }
    } catch (e) {
      // Use default location on error
      setState(() {
        _initialPosition = const LatLng(33.9716, -6.8498);
        _isLoadingLocation = false;
      });
    }
  }

  /// Load partners and create markers
  void _loadPartners() {
    // استخدام الشركاء مع الموقع
    final partnersWithLocation = _partnerController.partners
        .where((p) => p.hasLocation)
        .toList();

    setState(() {
      _markers = _createMarkers(partnersWithLocation);
    });

    // Zoom لعرض جميع الشركاء فقط في التحميل الأول
    if (_isInitialLoad &&
        partnersWithLocation.isNotEmpty &&
        _mapController != null) {
      _fitMapToShowAllPartners(partnersWithLocation);
      _isInitialLoad = false;
    }
  }

  /// Update markers only without zoom change
  void _updateMarkersOnly() {
    final partnersWithLocation = _partnerController.partners
        .where((p) => p.hasLocation)
        .toList();

    setState(() {
      _markers = _createMarkers(partnersWithLocation);
    });
  }

  /// Adjust map zoom to show all partners with user location as center
  void _fitMapToShowAllPartners(List<PartnerModel> partners) {
    if (partners.isEmpty || _mapController == null) return;

    // حساب حدود جميع الشركاء
    double minLat = double.infinity;
    double maxLat = -double.infinity;
    double minLng = double.infinity;
    double maxLng = -double.infinity;

    for (var partner in partners) {
      final lat = (partner.partnerLatitude is num)
          ? (partner.partnerLatitude as num).toDouble()
          : 0.0;
      final lng = (partner.partnerLongitude is num)
          ? (partner.partnerLongitude as num).toDouble()
          : 0.0;

      if (lat != 0.0 || lng != 0.0) {
        minLat = math.min(minLat, lat);
        maxLat = math.max(maxLat, lat);
        minLng = math.min(minLng, lng);
        maxLng = math.max(maxLng, lng);
      }
    }

    // إضافة موقع المستخدم إلى الحدود إذا كان متاحاً
    if (_currentPosition != null) {
      minLat = math.min(minLat, _currentPosition!.latitude);
      maxLat = math.max(maxLat, _currentPosition!.latitude);
      minLng = math.min(minLng, _currentPosition!.longitude);
      maxLng = math.max(maxLng, _currentPosition!.longitude);
    }

    // إنشاء LatLngBounds
    final bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );

    // تحريك الكاميرا لعرض جميع النقاط مع padding
    _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 50), // 50 padding
    );
  }

  /// Create markers with simple clustering based on zoom level
  Set<Marker> _createMarkers(List<PartnerModel> partners) {
    final markers = <Marker>{};

    if (_currentZoom > 14) {
      // High zoom - show individual markers
      for (var partner in partners) {
        final lat = (partner.partnerLatitude is num)
            ? (partner.partnerLatitude as num).toDouble()
            : 0.0;
        final lng = (partner.partnerLongitude is num)
            ? (partner.partnerLongitude as num).toDouble()
            : 0.0;

        markers.add(
          Marker(
            markerId: MarkerId('partner_${partner.id}'),
            position: LatLng(lat, lng),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              partner.isCustomer
                  ? BitmapDescriptor.hueGreen
                  : BitmapDescriptor.hueOrange,
            ),
            onTap: () => _showPartnerBottomSheet(partner),
            infoWindow: InfoWindow(
              title: (partner.name is String)
                  ? partner.name as String
                  : partner.name?.toString() ?? '',
            ),
          ),
        );
      }
    } else {
      // Lower zoom - create simple clusters
      final clusters = _createSimpleClusters(partners, _currentZoom);

      for (var cluster in clusters) {
        if (cluster['partners'].length == 1) {
          // Single partner
          final partner = cluster['partners'][0] as PartnerModel;
          final lat = (partner.partnerLatitude is num)
              ? (partner.partnerLatitude as num).toDouble()
              : 0.0;
          final lng = (partner.partnerLongitude is num)
              ? (partner.partnerLongitude as num).toDouble()
              : 0.0;

          markers.add(
            Marker(
              markerId: MarkerId('partner_${partner.id}'),
              position: LatLng(lat, lng),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                partner.isCustomer
                    ? BitmapDescriptor.hueGreen
                    : BitmapDescriptor.hueOrange,
              ),
              onTap: () => _showPartnerBottomSheet(partner),
            ),
          );
        } else {
          // Cluster - مع عرض الرقم
          final count = cluster['partners'].length;
          markers.add(
            Marker(
              markerId: MarkerId('cluster_${cluster['id']}'),
              position: cluster['position'] as LatLng,
              // استخدام أيقونة مختلفة بناءً على العدد
              icon: BitmapDescriptor.defaultMarkerWithHue(
                count < 5
                    ? BitmapDescriptor.hueBlue
                    : count < 10
                    ? BitmapDescriptor.hueAzure
                    : count < 20
                    ? BitmapDescriptor.hueViolet
                    : BitmapDescriptor.hueRose,
              ),
              onTap: () => _showClusterBottomSheet(cluster['partners'] as List),
              infoWindow: InfoWindow(
                title: '📍 $count',
                snippet: TranslationService.instance.translate('partners'),
              ),
              // جعل الماركر أكبر قليلاً للـ clusters
              anchor: const Offset(0.5, 0.5),
            ),
          );
        }
      }
    }

    return markers;
  }

  /// Create simple clusters based on proximity
  List<Map<String, dynamic>> _createSimpleClusters(
    List<PartnerModel> partners,
    double zoom,
  ) {
    final clusters = <Map<String, dynamic>>[];
    final processed = <int>{};
    final clusterDistance = _getClusterDistance(zoom);

    for (var i = 0; i < partners.length; i++) {
      if (processed.contains(i)) continue;

      final partner = partners[i];
      final lat1 = (partner.partnerLatitude is num)
          ? (partner.partnerLatitude as num).toDouble()
          : 0.0;
      final lng1 = (partner.partnerLongitude is num)
          ? (partner.partnerLongitude as num).toDouble()
          : 0.0;

      final clusterPartners = [partner];
      processed.add(i);

      // Find nearby partners
      for (var j = i + 1; j < partners.length; j++) {
        if (processed.contains(j)) continue;

        final otherPartner = partners[j];
        final lat2 = (otherPartner.partnerLatitude is num)
            ? (otherPartner.partnerLatitude as num).toDouble()
            : 0.0;
        final lng2 = (otherPartner.partnerLongitude is num)
            ? (otherPartner.partnerLongitude as num).toDouble()
            : 0.0;

        final distance = _calculateDistance(lat1, lng1, lat2, lng2);

        if (distance < clusterDistance) {
          clusterPartners.add(otherPartner);
          processed.add(j);
        }
      }

      // Calculate cluster center
      double avgLat = 0, avgLng = 0;
      for (var p in clusterPartners) {
        avgLat += (p.partnerLatitude is num)
            ? (p.partnerLatitude as num).toDouble()
            : 0.0;
        avgLng += (p.partnerLongitude is num)
            ? (p.partnerLongitude as num).toDouble()
            : 0.0;
      }
      avgLat /= clusterPartners.length;
      avgLng /= clusterPartners.length;

      clusters.add({
        'id': i,
        'position': LatLng(avgLat, avgLng),
        'partners': clusterPartners,
      });
    }

    return clusters;
  }

  /// Calculate distance between two coordinates (in km)
  double _calculateDistance(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) {
    const p = 0.017453292519943295; // Math.PI / 180
    final a =
        0.5 -
        math.cos((lat2 - lat1) * p) / 2 +
        math.cos(lat1 * p) *
            math.cos(lat2 * p) *
            (1 - math.cos((lng2 - lng1) * p)) /
            2;
    return 12742 * math.asin(math.sqrt(a)); // 2 * R; R = 6371 km
  }

  /// Get cluster distance based on zoom level
  double _getClusterDistance(double zoom) {
    if (zoom < 8) return 100.0; // 100 km
    if (zoom < 10) return 50.0; // 50 km
    if (zoom < 12) return 20.0; // 20 km
    if (zoom < 14) return 5.0; // 5 km
    return 1.0; // 1 km
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        backgroundColor: _themeController.isDarkMode
            ? Colors.grey[900]
            : _themeController.isProfessional
            ? const Color(0xFF0F172A)
            : Colors.grey[50],
        appBar: AppBar(
          title: Text(
            '${TranslationService.instance.translate('partners')} - ${TranslationService.instance.translate('map')}',
          ),
          backgroundColor: _themeController.isProfessional
              ? _themeController.primaryColor
              : _themeController.isDarkMode
              ? Colors.grey[800]
              : Colors.blue,
          foregroundColor: Colors.white,
          elevation: 0,
          actions: [
            // My Location button
            if (_currentPosition != null)
              IconButton(
                icon: const Icon(Icons.my_location),
                onPressed: _goToMyLocation,
                tooltip: TranslationService.instance.translate('my_location'),
              ),

            // Refresh partners
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                _isInitialLoad = true;
                _loadPartners();
                Get.snackbar(
                  TranslationService.instance.translate('refresh'),
                  TranslationService.instance.translate('partners_refreshed'),
                );
              },
              tooltip: TranslationService.instance.translate('refresh'),
            ),
          ],
        ),
        body: Stack(
          children: [
            // Google Map (only show when position is ready)
            if (_initialPosition != null)
              GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: _initialPosition!,
                  zoom: _currentZoom,
                ),
                markers: _markers,
                onMapCreated: _onMapCreated,
                onCameraMove: (position) {
                  // تحديث الـ zoom وتحديد ما إذا كنا نحتاج لتحديث الماركرز
                  final oldZoom = _currentZoom;
                  _currentZoom = position.zoom;

                  // تحديث الماركرز فقط إذا تغير مستوى التكبير بشكل كبير
                  if ((oldZoom > 14 && position.zoom <= 14) ||
                      (oldZoom <= 14 && position.zoom > 14)) {
                    _shouldUpdateMarkers = true;
                  }
                },
                onCameraIdle: () {
                  // تحديث الماركرز فقط إذا كان هناك تغيير في مستوى zoom
                  if (_shouldUpdateMarkers) {
                    _updateMarkersOnly();
                    _shouldUpdateMarkers = false;
                  }
                },
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                mapToolbarEnabled: false,
                zoomControlsEnabled: false,
                compassEnabled: true,
                mapType: MapType.normal,
              ),

            // Loading indicator
            if (_isLoadingLocation)
              Container(
                color:
                    _themeController.isDarkMode ||
                        _themeController.isProfessional
                    ? Colors.grey[900]
                    : Colors.black26,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        color: _themeController.isProfessional
                            ? _themeController.primaryColor
                            : Colors.white,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        TranslationService.instance.translate('loading'),
                        style: TextStyle(
                          color:
                              _themeController.isDarkMode ||
                                  _themeController.isProfessional
                              ? Colors.white
                              : Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Partners count badge
            Positioned(top: 16, right: 16, child: _buildPartnersCountBadge()),
          ],
        ),
        floatingActionButton: _buildFAB(),
      ),
    );
  }

  /// On Map Created
  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _loadPartners();
  }

  /// Go to my location
  void _goToMyLocation() {
    if (_currentPosition != null && _initialPosition != null) {
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          15,
        ),
      );
    }
  }

  /// Build partners count badge
  Widget _buildPartnersCountBadge() {
    return Obx(() {
      // استخدام الشركاء مع الموقع
      final count = _partnerController.partners
          .where((p) => p.hasLocation)
          .length;

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: _themeController.isProfessional
              ? _themeController.primaryColor
              : Colors.blue,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.location_on, color: Colors.white, size: 20),
            const SizedBox(width: 4),
            Text(
              '$count',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    });
  }

  /// Build FAB
  Widget _buildFAB() {
    return FloatingActionButton.extended(
      onPressed: () {
        Get.back();
      },
      icon: const Icon(Icons.list),
      label: Text(TranslationService.instance.translate('partners_list')),
      backgroundColor: _themeController.isProfessional
          ? _themeController.primaryColor
          : Colors.blue,
      foregroundColor: Colors.white,
    );
  }

  /// Show cluster bottom sheet
  void _showClusterBottomSheet(List partners) {
    showModalBottomSheet(
      context: context,
      backgroundColor:
          _themeController.isDarkMode || _themeController.isProfessional
          ? Colors.grey[900]
          : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),

            // Title
            Text(
              '${partners.length} ${TranslationService.instance.translate('partners')}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color:
                    _themeController.isDarkMode ||
                        _themeController.isProfessional
                    ? Colors.white
                    : Colors.black87,
              ),
            ),
            const SizedBox(height: 16),

            // Partners list
            SizedBox(
              height: 300,
              child: ListView.builder(
                itemCount: partners.length,
                itemBuilder: (context, index) {
                  final partner = partners[index] as PartnerModel;
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: partner.isCustomer
                          ? Colors.green
                          : Colors.orange,
                      child: Text(
                        partner.initials,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(
                      (partner.name is String)
                          ? partner.name as String
                          : partner.name?.toString() ?? '',
                      style: TextStyle(
                        color:
                            _themeController.isDarkMode ||
                                _themeController.isProfessional
                            ? Colors.white
                            : Colors.black87,
                      ),
                    ),
                    subtitle: Text(
                      partner.fullAddress ?? '',
                      style: TextStyle(
                        color:
                            _themeController.isDarkMode ||
                                _themeController.isProfessional
                            ? Colors.grey[400]
                            : Colors.grey[600],
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _showPartnerBottomSheet(partner);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Show partner bottom sheet
  void _showPartnerBottomSheet(PartnerModel partner) {
    showModalBottomSheet(
      context: context,
      backgroundColor:
          _themeController.isDarkMode || _themeController.isProfessional
          ? Colors.grey[900]
          : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Partner info
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: partner.isCustomer
                      ? Colors.green
                      : Colors.orange,
                  child: Text(
                    partner.initials,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        (partner.name is String)
                            ? partner.name as String
                            : partner.name?.toString() ?? '',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color:
                              _themeController.isDarkMode ||
                                  _themeController.isProfessional
                              ? Colors.white
                              : Colors.black87,
                        ),
                      ),
                      Text(
                        partner.isCustomer
                            ? TranslationService.instance.translate('customer')
                            : TranslationService.instance.translate('supplier'),
                        style: TextStyle(
                          color:
                              _themeController.isDarkMode ||
                                  _themeController.isProfessional
                              ? Colors.grey[400]
                              : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Contact info
            if (partner.primaryPhone != null)
              _buildInfoRow(Icons.phone, partner.primaryPhone!),
            if (partner.fullAddress != null)
              _buildInfoRow(Icons.location_on, partner.fullAddress!),

            const SizedBox(height: 20),

            // Actions
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      Get.toNamed(AppRouter.partnerDetails, arguments: partner);
                    },
                    icon: const Icon(Icons.info_outline),
                    label: Text(
                      TranslationService.instance.translate('partner_details'),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _themeController.isProfessional
                          ? _themeController.primaryColor
                          : Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.close),
                    label: Text(
                      TranslationService.instance.translate('cancel'),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _themeController.isProfessional
                          ? _themeController.primaryColor
                          : Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Build info row
  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color:
                _themeController.isDarkMode || _themeController.isProfessional
                ? Colors.grey[400]
                : Colors.grey[600],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color:
                    _themeController.isDarkMode ||
                        _themeController.isProfessional
                    ? Colors.grey[300]
                    : Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
