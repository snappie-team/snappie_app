import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:snappie_app/app/modules/shared/layout/views/scaffold_frame.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/place_model.dart';

/// Model untuk item fasilitas dengan kategori
class _FacilityItem {
  final String name;
  final String? description;
  final String category;

  _FacilityItem({
    required this.name,
    this.description,
    required this.category,
  });
}

class FacilitiesView extends StatefulWidget {
  const FacilitiesView({super.key});

  @override
  State<FacilitiesView> createState() => _FacilitiesViewState();
}

class _FacilitiesViewState extends State<FacilitiesView> {
  String? _selectedCategory;
  late List<_FacilityItem> _allFacilities;
  late List<String> _categories;

  @override
  void initState() {
    super.initState();
    _initializeFacilities();
  }

  void _initializeFacilities() {
    final Map<String, dynamic> args = Get.arguments ?? {};
    final PlaceAttributes? attributes = args['placeAttributes'];

    _allFacilities = [];
    
    if (attributes != null) {
      // Facility
      if (attributes.facility != null) {
        for (final item in attributes.facility!) {
          if (item.name != null) {
            _allFacilities.add(_FacilityItem(
              name: item.name!,
              description: item.description,
              category: 'Fasilitas Umum',
            ));
          }
        }
      }
      
      // Parking
      if (attributes.parking != null) {
        for (final item in attributes.parking!) {
          if (item.name != null) {
            _allFacilities.add(_FacilityItem(
              name: item.name!,
              description: item.description,
              category: 'Area Parkir',
            ));
          }
        }
      }
      
      // Capacity
      if (attributes.capacity != null) {
        for (final item in attributes.capacity!) {
          if (item.name != null) {
            _allFacilities.add(_FacilityItem(
              name: item.name!,
              description: item.description,
              category: 'Kapasitas & Area Duduk',
            ));
          }
        }
      }
      
      // Accessibility
      if (attributes.accessibility != null) {
        for (final item in attributes.accessibility!) {
          if (item.name != null) {
            _allFacilities.add(_FacilityItem(
              name: item.name!,
              description: item.description,
              category: 'Aksesibilitas',
            ));
          }
        }
      }
      
      // Payment
      if (attributes.payment != null) {
        for (final item in attributes.payment!) {
          if (item.name != null) {
            _allFacilities.add(_FacilityItem(
              name: item.name!,
              description: item.description,
              category: 'Pembayaran',
            ));
          }
        }
      }
      
      // Service
      if (attributes.service != null) {
        for (final item in attributes.service!) {
          if (item.name != null) {
            _allFacilities.add(_FacilityItem(
              name: item.name!,
              description: item.description,
              category: 'Pelayanan',
            ));
          }
        }
      }
    }

    // Get unique categories
    _categories = _allFacilities.map((e) => e.category).toSet().toList();
    
    // Set default selected category to first one
    if (_categories.isNotEmpty) {
      _selectedCategory = _categories.first;
    }
  }

  List<_FacilityItem> get _filteredFacilities {
    if (_selectedCategory == null) {
      return _allFacilities;
    }
    return _allFacilities.where((f) => f.category == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldFrame.detail(
      title: 'Fasilitas',
      slivers: [
        _allFacilities.isEmpty
            ? SliverFillRemaining(
                child: _buildEmptyState(),
              )
            : SliverToBoxAdapter(
                child: Column(
                  children: [
                    // Filter chips
                    _buildFilterChips(),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
        if (_allFacilities.isNotEmpty)
          SliverFillRemaining(
            child: _buildFacilitiesList(),
          ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.info_outline,
            size: 64,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: 16),
          Text(
            'Belum ada fasilitas',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          mainAxisExtent: 40,
        ),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          return _buildFilterChip(category, category);
        },
      ),
    );
  }

  Widget _buildFilterChip(String value, String label) {
    final isSelected = _selectedCategory == value;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.background,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.primary,
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? AppColors.textOnPrimary : AppColors.primary,
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFacilitiesList() {
    final facilities = _filteredFacilities;
    
    if (facilities.isEmpty) {
      return Center(
        child: Text(
          'Tidak ada fasilitas di kategori ini',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    return ListView.builder(
      itemCount: facilities.length,
      itemBuilder: (context, index) {
        final facility = facilities[index];
        return _buildFacilityTile(facility);
      },
    );
  }

  Widget _buildFacilityTile(_FacilityItem facility) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowDark,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            facility.name,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: AppColors.textPrimary,
            ),
          ),
          if (facility.description != null && facility.description!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              facility.description!,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
