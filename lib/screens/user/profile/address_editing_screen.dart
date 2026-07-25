import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../../theme/app_colors.dart';
import '../../../models/shipping_address.dart';
import '../../../providers/address_provider.dart';
import '../../../providers/user_profile_provider.dart';
import '../../../services/location_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:app_frontend/l10n/app_localizations.dart';

class AddressEditingScreen extends ConsumerStatefulWidget {
  final ShippingAddress? address;

  const AddressEditingScreen({super.key, this.address});

  @override
  ConsumerState<AddressEditingScreen> createState() => _AddressEditingScreenState();
}

class _AddressEditingScreenState extends ConsumerState<AddressEditingScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _labelController;
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _streetController;
  late TextEditingController _wardController;
  late TextEditingController _districtController;
  late TextEditingController _cityController;
  bool _isDefault = false;

  GoogleMapController? _mapController;
  LatLng? _selectedLocation;
  bool _isLoading = false;
  bool _isGeocoding = false;

  static const CameraPosition _defaultPosition = CameraPosition(
    target: LatLng(10.762622, 106.660172),
    zoom: 14.0,
  );

  @override
  void initState() {
    super.initState();
    final profile = ref.read(userProfileProvider).value;
    
    _labelController = TextEditingController(text: widget.address?.addressLabel ?? "");
    _nameController = TextEditingController(text: widget.address?.recipientName ?? profile?.name ?? "");
    _phoneController = TextEditingController(text: widget.address?.phoneNumber ?? profile?.phone ?? "");
    _streetController = TextEditingController(text: widget.address?.streetAddress ?? "");
    _wardController = TextEditingController(text: widget.address?.ward ?? "");
    _districtController = TextEditingController(text: widget.address?.district ?? "");
    _cityController = TextEditingController(text: widget.address?.cityProvince ?? "");
    _isDefault = widget.address?.isDefault ?? false;

    if (widget.address?.latitude != null && widget.address?.longitude != null) {
      _selectedLocation = LatLng(widget.address!.latitude!, widget.address!.longitude!);
    } else if (widget.address == null) {
      _getCurrentLocation();
    }
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    if (permission == LocationPermission.deniedForever) return;

    try {
      final position = await Geolocator.getCurrentPosition();
      if (mounted) {
        setState(() {
          _selectedLocation = LatLng(position.latitude, position.longitude);
        });
        _mapController?.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: _selectedLocation!, zoom: 15),
          ),
        );
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _labelController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _streetController.dispose();
    _wardController.dispose();
    _districtController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _saveAddress() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);

    final newAddress = ShippingAddress(
      id: widget.address?.id,
      addressLabel: _labelController.text.trim(),
      isDefault: _isDefault,
      recipientName: _nameController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      streetAddress: _streetController.text.trim(),
      ward: _wardController.text.trim(),
      district: _districtController.text.trim(),
      cityProvince: _cityController.text.trim(),
      latitude: _selectedLocation?.latitude,
      longitude: _selectedLocation?.longitude,
    );

    try {
      if (widget.address == null) {
        await ref.read(addressProvider.notifier).addAddress(newAddress);
      } else {
        await ref.read(addressProvider.notifier).updateAddress(widget.address!.id!, newAddress);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to save: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleCameraIdle() async {
    if (_selectedLocation == null) return;
    setState(() => _isGeocoding = true);
    
    final result = await LocationService.reverseGeocode(_selectedLocation!.latitude, _selectedLocation!.longitude);
    if (mounted) {
      setState(() {
        _isGeocoding = false;
        if (result != null) {
          if (result['street']!.isNotEmpty) _streetController.text = result['street']!;
          if (result['ward']!.isNotEmpty) _wardController.text = result['ward']!;
          if (result['district']!.isNotEmpty) _districtController.text = result['district']!;
          if (result['city']!.isNotEmpty) _cityController.text = result['city']!;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.address == null ? "Add Address" : "Edit Address",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20.sp),
        ),
        actions: [
          _isLoading 
            ? Padding(padding: EdgeInsets.only(right: 16.w), child: Center(child: SizedBox(width: 20.w, height: 20.h, child: CircularProgressIndicator(strokeWidth: 2))))
            : TextButton(
                onPressed: _saveAddress,
                child: Text(AppLocalizations.of(context)!.save, style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 16.sp)),
              )
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInput("Address Label (e.g. Home, Office)", _labelController, true),
              _buildInput("Recipient Name", _nameController, true),
              _buildInput("Phone Number", _phoneController, true, isPhone: true),
              _buildInput("Street Address", _streetController, true),
              Row(
                children: [
                  Expanded(child: _buildInput("Ward", _wardController, true)),
                  SizedBox(width: 16.w),
                  Expanded(child: _buildInput("District", _districtController, true)),
                ],
              ),
              _buildInput("City/Province", _cityController, true),
              
              SizedBox(height: 12.h),
              SwitchListTile(
                title: Text(AppLocalizations.of(context)!.setAsDefaultAddress, style: TextStyle(fontWeight: FontWeight.w600)),
                value: _isDefault,
                activeThumbColor: AppColors.primary,
                contentPadding: EdgeInsets.zero,
                onChanged: (val) => setState(() => _isDefault = val),
              ),
              
              SizedBox(height: 24.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(AppLocalizations.of(context)!.pinpointLocation, 
                      style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  _isGeocoding 
                    ? SizedBox(
                        width: 16.w, height: 16.h,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                      )
                    : TextButton.icon(
                        onPressed: _selectedLocation == null ? null : _handleCameraIdle,
                        icon: Icon(Icons.location_searching, size: 18.sp),
                        label: Text(AppLocalizations.of(context)!.usePinLocation),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      )
                ],
              ),
              SizedBox(height: 12.h),
              Container(
                height: 250.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: AppColors.borderGrey),
                ),
                clipBehavior: Clip.hardEdge,
                child: Stack(
                  children: [
                    GoogleMap(
                      initialCameraPosition: _selectedLocation != null 
                          ? CameraPosition(target: _selectedLocation!, zoom: 15)
                          : _defaultPosition,
                      myLocationEnabled: true,
                      myLocationButtonEnabled: true,
                      zoomControlsEnabled: true,
                      zoomGesturesEnabled: true,
                      gestureRecognizers: {
                        Factory<OneSequenceGestureRecognizer>(() => EagerGestureRecognizer()),
                      },
                      onMapCreated: (GoogleMapController controller) {
                        _mapController = controller;
                      },
                      onCameraMove: (CameraPosition position) {
                        _selectedLocation = position.target;
                      },
                      markers: const {}, // No markers, using center pin instead
                    ),
                    // Center Pin
                    Center(
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 40.h), // Align pin tip to center
                        child: Icon(
                          Icons.location_on,
                          size: 40.sp,
                          color: AppColors.primary,
                          shadows: [
                            Shadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 8, offset: Offset(0, 4)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 40.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput(String label, TextEditingController controller, bool isRequired, {bool isPhone = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: TextFormField(
        controller: controller,
        keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(color: AppColors.borderGrey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(color: AppColors.primary, width: 2.w),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        ),
        validator: (value) {
          if (isRequired && (value == null || value.trim().isEmpty)) {
            return "This field is required";
          }
          return null;
        },
      ),
    );
  }
}
