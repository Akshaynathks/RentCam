import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rent_cam/core/widget/appbar.dart';
import 'package:rent_cam/core/widget/color.dart';
import 'package:rent_cam/core/utils/responsive_helper.dart';
import 'package:rent_cam/features/search/bloc/search_bloc/search_bloc.dart';
import 'package:rent_cam/features/search/bloc/search_bloc/search_event.dart';
import 'package:rent_cam/features/search/bloc/search_bloc/search_state.dart';
import 'package:rent_cam/features/product/model/product_model.dart';
import 'package:rent_cam/features/product/view/product_detail_page.dart';

class SearchPage extends StatelessWidget {
  final List<Product> allProducts;

  const SearchPage({super.key, required this.allProducts});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SearchBloc(allProducts: allProducts),
      child: Scaffold(
        appBar: const CustomAppBar(
          title: 'Search Products',
        ),
        body: Padding(
          padding: ResponsiveHelper.getResponsivePadding(context),
          child: Column(
            children: [
              BlocBuilder<SearchBloc, SearchState>(
                builder: (context, state) {
                  return CustomSearchBar(
                    hintText: 'Search products...',
                    onChanged: (query) {
                      context.read<SearchBloc>().add(SearchQueryChanged(query));
                    },
                  );
                },
              ),
              SizedBox(
                  height: ResponsiveHelper.getResponsiveHeight(context, 1)),
              BlocBuilder<SearchBloc, SearchState>(
                builder: (context, state) {
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip(
                          context,
                          'Beginner',
                          context.read<SearchBloc>().currentFilter ==
                              'Beginner',
                          () => context
                              .read<SearchBloc>()
                              .add(FilterChanged('Beginner')),
                        ),
                        SizedBox(
                            width:
                                ResponsiveHelper.getResponsivePadding(context)
                                        .horizontal /
                                    2),
                        _buildFilterChip(
                          context,
                          'Professional',
                          context.read<SearchBloc>().currentFilter ==
                              'Professional',
                          () => context
                              .read<SearchBloc>()
                              .add(FilterChanged('Professional')),
                        ),
                        SizedBox(
                            width:
                                ResponsiveHelper.getResponsivePadding(context)
                                        .horizontal /
                                    2),
                        _buildFilterChip(
                          context,
                          'Canon',
                          context.read<SearchBloc>().currentBrand == 'Canon',
                          () => context
                              .read<SearchBloc>()
                              .add(BrandFilterChanged('Canon')),
                        ),
                        SizedBox(
                            width:
                                ResponsiveHelper.getResponsivePadding(context)
                                        .horizontal /
                                    2),
                        _buildFilterChip(
                          context,
                          'Nikon',
                          context.read<SearchBloc>().currentBrand == 'Nikon',
                          () => context
                              .read<SearchBloc>()
                              .add(BrandFilterChanged('Nikon')),
                        ),
                        SizedBox(
                            width:
                                ResponsiveHelper.getResponsivePadding(context)
                                        .horizontal /
                                    2),
                        _buildFilterChip(
                          context,
                          'Lens',
                          context.read<SearchBloc>().currentCategory == 'Lens',
                          () => context
                              .read<SearchBloc>()
                              .add(CategoryFilterChanged('Lens')),
                        ),
                        SizedBox(
                            width:
                                ResponsiveHelper.getResponsivePadding(context)
                                        .horizontal /
                                    2),
                        _buildFilterChip(
                          context,
                          'Camera',
                          context.read<SearchBloc>().currentCategory ==
                              'Camera',
                          () => context
                              .read<SearchBloc>()
                              .add(CategoryFilterChanged('Camera')),
                        ),
                        SizedBox(
                            width:
                                ResponsiveHelper.getResponsivePadding(context)
                                        .horizontal /
                                    2),
                        _buildPriceFilterChip(context),
                      ],
                    ),
                  );
                },
              ),
              SizedBox(
                  height: ResponsiveHelper.getResponsiveHeight(context, 1)),
              BlocBuilder<SearchBloc, SearchState>(
                builder: (context, state) {
                  if (state is SearchSuccess && state.showPriceFilter) {
                    return _buildPriceRangeFilter(context);
                  }
                  return const SizedBox.shrink();
                },
              ),
              Expanded(
                child: BlocBuilder<SearchBloc, SearchState>(
                  builder: (context, state) {
                    if (state is SearchLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is SearchFailure) {
                      return Center(
                        child: Text(
                          state.error,
                          style: TextStyle(
                            fontSize: ResponsiveHelper.getResponsiveFontSize(
                                context, 16),
                            color: AppColors.error,
                          ),
                        ),
                      );
                    } else if (state is SearchSuccess) {
                      if (state.products.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off,
                                size: ResponsiveHelper.getResponsiveIconSize(
                                    context, 80),
                                color: AppColors.textSecondary,
                              ),
                              SizedBox(
                                  height: ResponsiveHelper.getResponsiveHeight(
                                      context, 1)),
                              Text(
                                'No products available',
                                style: TextStyle(
                                  fontSize:
                                      ResponsiveHelper.getResponsiveFontSize(
                                          context, 18),
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(
                                  height: ResponsiveHelper.getResponsiveHeight(
                                      context, 0.5)),
                              Text(
                                'Try different filters or search terms',
                                style: TextStyle(
                                  fontSize:
                                      ResponsiveHelper.getResponsiveFontSize(
                                          context, 14),
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      return ListView.builder(
                        itemCount: state.products.length,
                        itemBuilder: (context, index) {
                          final product = state.products[index];
                          return ListTile(
                            contentPadding: EdgeInsets.symmetric(
                              horizontal:
                                  ResponsiveHelper.getResponsivePadding(context)
                                          .horizontal /
                                      2,
                              vertical:
                                  ResponsiveHelper.getResponsivePadding(context)
                                          .vertical /
                                      4,
                            ),
                            title: Text(
                              product.name,
                              style: TextStyle(
                                color: AppColors.buttonText,
                                fontSize:
                                    ResponsiveHelper.getResponsiveFontSize(
                                        context, 16),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            subtitle: Text(
                              '₹${product.rentalPrice}/Day',
                              style: TextStyle(
                                color: AppColors.buttonText,
                                fontSize:
                                    ResponsiveHelper.getResponsiveFontSize(
                                        context, 14),
                              ),
                            ),
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                product.images.first,
                                width: ResponsiveHelper.getResponsiveIconSize(
                                    context, 60),
                                height: ResponsiveHelper.getResponsiveIconSize(
                                    context, 60),
                                fit: BoxFit.cover,
                              ),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ProductDetailPage(productId: product.id),
                                ),
                              );
                            },
                          );
                        },
                      );
                    }
                    return Container();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriceFilterChip(BuildContext context) {
    return BlocBuilder<SearchBloc, SearchState>(
      builder: (context, state) {
        final isSelected = state is SearchSuccess && state.showPriceFilter;
        return FilterChip(
          label: Text(
            'Price Range',
            style: TextStyle(
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14),
              color: isSelected ? Colors.white : AppColors.buttonText,
            ),
          ),
          selected: isSelected,
          onSelected: (bool value) {
            context.read<SearchBloc>().add(TogglePriceFilter());
          },
          backgroundColor: AppColors.indicatorInactive,
          selectedColor: AppColors.indicatorActive,
          checkmarkColor: Colors.white,
          padding: EdgeInsets.symmetric(
            horizontal:
                ResponsiveHelper.getResponsivePadding(context).horizontal / 4,
            vertical:
                ResponsiveHelper.getResponsivePadding(context).vertical / 4,
          ),
        );
      },
    );
  }

  Widget _buildPriceRangeFilter(BuildContext context) {
    return BlocBuilder<SearchBloc, SearchState>(
      builder: (context, state) {
        if (state is SearchSuccess) {
          return Container(
            padding: EdgeInsets.all(
                ResponsiveHelper.getResponsivePadding(context).horizontal / 2),
            decoration: BoxDecoration(
              color: AppColors.indicatorInactive,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Price Range (₹/Day)',
                  style: TextStyle(
                    fontSize:
                        ResponsiveHelper.getResponsiveFontSize(context, 16),
                    fontWeight: FontWeight.w500,
                    color: AppColors.buttonText,
                  ),
                ),
                SizedBox(
                    height: ResponsiveHelper.getResponsiveHeight(context, 0.5)),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '₹${state.minPrice.round()}',
                        style: TextStyle(
                          fontSize: ResponsiveHelper.getResponsiveFontSize(
                              context, 14),
                          color: AppColors.buttonText,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        '₹${state.maxPrice.round()}',
                        style: TextStyle(
                          fontSize: ResponsiveHelper.getResponsiveFontSize(
                              context, 14),
                          color: AppColors.buttonText,
                        ),
                      ),
                    ),
                  ],
                ),
                RangeSlider(
                  values: RangeValues(state.minPrice, state.maxPrice),
                  min: 0,
                  max: 10000,
                  divisions: 100,
                  activeColor: AppColors.indicatorActive,
                  inactiveColor: AppColors.indicatorInactive,
                  onChanged: (RangeValues values) {
                    context.read<SearchBloc>().add(PriceRangeChanged(
                          minPrice: values.start,
                          maxPrice: values.end,
                        ));
                  },
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildFilterChip(
    BuildContext context,
    String label,
    bool selected,
    VoidCallback onSelected,
  ) {
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14),
          color: selected ? Colors.white : AppColors.buttonText,
        ),
      ),
      selected: selected,
      onSelected: (bool value) => onSelected(),
      backgroundColor: AppColors.indicatorInactive,
      selectedColor: AppColors.indicatorActive,
      checkmarkColor: Colors.white,
      padding: EdgeInsets.symmetric(
        horizontal:
            ResponsiveHelper.getResponsivePadding(context).horizontal / 4,
        vertical: ResponsiveHelper.getResponsivePadding(context).vertical / 4,
      ),
    );
  }
}

class CustomSearchBar extends StatelessWidget {
  final String hintText;
  final Function(String) onChanged;

  const CustomSearchBar({
    required this.hintText,
    required this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.indicatorInactive,
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextField(
        style: TextStyle(
          color: AppColors.buttonText,
          fontSize: ResponsiveHelper.getResponsiveFontSize(context, 16),
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: AppColors.textSecondary,
            fontSize: ResponsiveHelper.getResponsiveFontSize(context, 16),
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal:
                ResponsiveHelper.getResponsivePadding(context).horizontal,
            vertical:
                ResponsiveHelper.getResponsivePadding(context).vertical / 2,
          ),
          suffixIcon: Icon(
            Icons.search,
            color: AppColors.indicatorActive,
            size: ResponsiveHelper.getResponsiveIconSize(context, 24),
          ),
        ),
        onChanged: onChanged,
      ),
    );
  }
}
