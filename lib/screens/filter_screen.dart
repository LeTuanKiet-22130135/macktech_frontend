import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:app_frontend/theme/app_colors.dart';

/// Result returned when the user applies a filter.
class FilterResult {
  final Set<String> selectedBrands;
  final int? selectedCategoryId;
  final double? minPrice;
  final double? maxPrice;

  FilterResult({
    required this.selectedBrands,
    this.selectedCategoryId,
    this.minPrice,
    this.maxPrice,
  });
}

/// Filter screen that shows brands and price range from the backend.
/// Accepts [availableBrands], [minPrice], [maxPrice] from the search API
/// and optional initial values to restore previous filter state.
class FilterScreen extends StatefulWidget {
  final List<String> availableBrands;
  final List<dynamic> availableCategories;
  final double minPrice;
  final double maxPrice;
  final Set<String>? initialBrands;
  final int? initialCategoryId;
  final double? initialMinPrice;
  final double? initialMaxPrice;

  const FilterScreen({
    super.key,
    required this.availableBrands,
    required this.availableCategories,
    required this.minPrice,
    required this.maxPrice,
    this.initialBrands,
    this.initialCategoryId,
    this.initialMinPrice,
    this.initialMaxPrice,
  });

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  late RangeValues _priceRange;
  late double _sliderMin;
  late double _sliderMax;
  final Set<String> _selectedBrands = {};
  int? _selectedCategoryId;
  bool _isBrandExpanded = false;
  bool _isCategoryExpanded = false;
  late TextEditingController _minPriceController;
  late TextEditingController _maxPriceController;

  String _formatVnd(double value) {
    final intVal = value.round();
    // Add dot separators for thousands
    final str = intVal.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buffer.write('.');
      buffer.write(str[i]);
    }
    return buffer.toString();
  }

  @override
  void initState() {
    super.initState();
    _sliderMin = widget.minPrice;
    _sliderMax = widget.maxPrice;

    // Ensure we have a valid range for the slider
    if (_sliderMax <= _sliderMin) {
      _sliderMax = _sliderMin + 1;
    }

    // Restore previous selection or default to full range
    final startVal = (widget.initialMinPrice ?? _sliderMin).clamp(_sliderMin, _sliderMax);
    final endVal = (widget.initialMaxPrice ?? _sliderMax).clamp(_sliderMin, _sliderMax);
    _priceRange = RangeValues(startVal, endVal);

    _minPriceController = TextEditingController(text: _formatVnd(startVal));
    _maxPriceController = TextEditingController(text: _formatVnd(endVal));

    if (widget.initialBrands != null) {
      _selectedBrands.addAll(widget.initialBrands!);
    }
    _selectedCategoryId = widget.initialCategoryId;
  }

  @override
  void dispose() {
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.tertiaryDarker,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Filter",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 20.sp,
              ),
            ),
            SizedBox(width: 8.w),
            Icon(Icons.filter_alt_outlined, color: Colors.white, size: 22.sp),
          ],
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Price range section
                  _buildSectionTitle("Price range"),
                  SizedBox(height: 24.h),
                  _buildPriceRange(),
                  SizedBox(height: 36.h),

                  // Category section
                  _buildSectionTitle("Category"),
                  SizedBox(height: 16.h),
                  widget.availableCategories.isEmpty
                      ? Text(
                          "No categories available",
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey.shade500,
                          ),
                        )
                      : _buildCategoryGrid(widget.availableCategories),
                  SizedBox(height: 36.h),

                  // Brand section
                  _buildSectionTitle("Brand"),
                  SizedBox(height: 16.h),
                  widget.availableBrands.isEmpty
                      ? Text(
                          "No brands available",
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey.shade500,
                          ),
                        )
                      : _buildChipGrid(widget.availableBrands, _selectedBrands),
                ],
              ),
            ),
          ),

          // Bottom buttons
          _buildBottomButtons(),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.tertiaryDarker,
          ),
        ),
        const SizedBox(height: 4),
        const Divider(height: 1),
      ],
    );
  }

  Widget _buildPriceRange() {
    return Column(
      children: [
        // Text input fields
        Row(
          children: [
            Expanded(
              child: _buildPriceField(
                label: "Min",
                controller: _minPriceController,
                onSubmitted: (val) {
                  final parsed = double.tryParse(val.replaceAll('.', ''));
                  if (parsed != null) {
                    final clamped = parsed.clamp(_sliderMin, _priceRange.end);
                    setState(() {
                      _priceRange = RangeValues(clamped, _priceRange.end);
                      _minPriceController.text = _formatVnd(clamped);
                    });
                  }
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              child: Text("–", style: TextStyle(fontSize: 20.sp, color: Colors.grey.shade400)),
            ),
            Expanded(
              child: _buildPriceField(
                label: "Max",
                controller: _maxPriceController,
                onSubmitted: (val) {
                  final parsed = double.tryParse(val.replaceAll('.', ''));
                  if (parsed != null) {
                    final clamped = parsed.clamp(_priceRange.start, _sliderMax);
                    setState(() {
                      _priceRange = RangeValues(_priceRange.start, clamped);
                      _maxPriceController.text = _formatVnd(clamped);
                    });
                  }
                },
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        // Slider
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.tertiaryDarker,
            inactiveTrackColor: Colors.grey.shade300,
            thumbColor: AppColors.tertiaryDarker,
            overlayColor: AppColors.tertiaryDarker.withValues(alpha: 0.1),
            trackHeight: 3,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
          ),
          child: RangeSlider(
            values: _priceRange,
            min: _sliderMin,
            max: _sliderMax,
            divisions: 100,
            onChanged: (values) {
              setState(() {
                _priceRange = values;
                _minPriceController.text = _formatVnd(values.start);
                _maxPriceController.text = _formatVnd(values.end);
              });
            },
          ),
        ),
        // Range labels
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "${_formatVnd(_sliderMin)}₫",
              style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade500),
            ),
            Text(
              "${_formatVnd(_sliderMax)}₫",
              style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade500),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPriceField({
    required String label,
    required TextEditingController controller,
    required ValueChanged<String> onSubmitted,
  }) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontSize: 13.sp, color: Colors.grey.shade500),
        suffixText: '₫',
        suffixStyle: TextStyle(fontSize: 14.sp, color: Colors.grey.shade600),
        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: AppColors.tertiaryDarker, width: 1.5.w),
        ),
      ),
      onSubmitted: onSubmitted,
      onTap: () => controller.selection = TextSelection(
        baseOffset: 0,
        extentOffset: controller.text.length,
      ),
    );
  }

  Widget _buildCategoryGrid(List<dynamic> categories) {
    final showAll = _isCategoryExpanded || categories.length <= 6;
    final displayItems = showAll ? categories : categories.take(6).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: displayItems.map((cat) {
            final isSelected = _selectedCategoryId == cat.id;
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedCategoryId = null;
                  } else {
                    _selectedCategoryId = cat.id;
                  }
                });
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.tertiaryDarker : Colors.white,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.tertiaryDarker
                        : Colors.grey.shade300,
                  ),
                ),
                child: Text(
                  cat.name,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: isSelected ? Colors.white : Colors.grey.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        if (categories.length > 6) ...[
          SizedBox(height: 12.h),
          GestureDetector(
            onTap: () {
              setState(() {
                _isCategoryExpanded = !_isCategoryExpanded;
              });
            },
            child: Text(
              _isCategoryExpanded ? "Show less" : "Show all (${categories.length})",
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.tertiaryNormal,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildChipGrid(List<String> items, Set<String> selectedSet) {
    final showAll = _isBrandExpanded || items.length <= 6;
    final displayItems = showAll ? items : items.take(6).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: displayItems.map((item) {
            final isSelected = selectedSet.contains(item);
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    selectedSet.remove(item);
                  } else {
                    selectedSet.add(item);
                  }
                });
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.tertiaryDarker : Colors.white,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.tertiaryDarker
                        : Colors.grey.shade300,
                  ),
                ),
                child: Text(
                  item,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: isSelected ? Colors.white : Colors.grey.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        if (items.length > 6) ...[
          SizedBox(height: 12.h),
          GestureDetector(
            onTap: () {
              setState(() {
                _isBrandExpanded = !_isBrandExpanded;
              });
            },
            child: Text(
              _isBrandExpanded ? "Show less" : "Show all (${items.length})",
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.tertiaryNormal,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildBottomButtons() {
    final hasActiveFilter = _selectedBrands.isNotEmpty ||
        _priceRange.start > _sliderMin ||
        _priceRange.end < _sliderMax;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Row(
        children: [
          // Cancel / Reset
          Expanded(
            child: TextButton(
              onPressed: () {
                if (hasActiveFilter) {
                  // Reset filters
                  setState(() {
                    _selectedBrands.clear();
                    _selectedCategoryId = null;
                    _priceRange = RangeValues(_sliderMin, _sliderMax);
                  });
                  // Return null result to clear filters
                  Navigator.pop(context, null);
                } else {
                  Navigator.pop(context);
                }
              },
              child: Text(
                hasActiveFilter ? "Reset" : "Cancel",
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.grey.shade500,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
          SizedBox(width: 16.w),
          // Filter button
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: () {
                // Only set price filter if user changed from defaults
                double? minP;
                double? maxP;
                if (_priceRange.start > _sliderMin) {
                  minP = _priceRange.start;
                }
                if (_priceRange.end < _sliderMax) {
                  maxP = _priceRange.end;
                }

                Navigator.pop(
                  context,
                  FilterResult(
                    selectedBrands: Set<String>.from(_selectedBrands),
                    selectedCategoryId: _selectedCategoryId,
                    minPrice: minP,
                    maxPrice: maxP,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.tertiaryDarker,
                foregroundColor: Colors.white,
                minimumSize: const Size(0, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
                elevation: 0,
              ),
              child: Text(
                "Filter",
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
