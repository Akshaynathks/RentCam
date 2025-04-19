import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rent_cam/core/widget/appbar.dart';
import 'package:rent_cam/core/widget/color.dart';
import 'package:rent_cam/features/home/bloc/search_bloc/search_bloc.dart';
import 'package:rent_cam/features/home/bloc/search_bloc/search_event.dart';
import 'package:rent_cam/features/home/bloc/search_bloc/search_state.dart';
import 'package:rent_cam/features/home/model/product_model.dart';
import 'package:rent_cam/features/home/view/product_detail_page.dart';

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
          padding: const EdgeInsets.all(16.0),
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
              const SizedBox(height: 16),
              BlocBuilder<SearchBloc, SearchState>(
                builder: (context, state) {
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        FilterChip(
                          label: const Text('Beginner'),
                          selected: context.read<SearchBloc>().currentFilter ==
                              'Beginner',
                          onSelected: (selected) {
                            context
                                .read<SearchBloc>()
                                .add(FilterChanged('Beginner'));
                          },
                        ),
                        const SizedBox(width: 8),
                        FilterChip(
                          label: const Text('Professional'),
                          selected: context.read<SearchBloc>().currentFilter ==
                              'Professional',
                          onSelected: (selected) {
                            context
                                .read<SearchBloc>()
                                .add(FilterChanged('Professional'));
                          },
                        ),
                        const SizedBox(width: 8),
                        FilterChip(
                          label: const Text('Canon'),
                          selected: context.read<SearchBloc>().currentBrand ==
                              'Canon',
                          onSelected: (selected) {
                            context
                                .read<SearchBloc>()
                                .add(BrandFilterChanged('Canon'));
                          },
                        ),
                        const SizedBox(width: 8),
                        FilterChip(
                          label: const Text('Nikon'),
                          selected: context.read<SearchBloc>().currentBrand ==
                              'Nikon',
                          onSelected: (selected) {
                            context
                                .read<SearchBloc>()
                                .add(BrandFilterChanged('Nikon'));
                          },
                        ),
                        const SizedBox(width: 8),
                        FilterChip(
                          label: const Text('Lens'),
                          selected:
                              context.read<SearchBloc>().currentCategory ==
                                  'Lens',
                          onSelected: (selected) {
                            context
                                .read<SearchBloc>()
                                .add(CategoryFilterChanged('Lens'));
                          },
                        ),
                        const SizedBox(width: 8),
                        FilterChip(
                          label: const Text('Camera'),
                          selected:
                              context.read<SearchBloc>().currentCategory ==
                                  'Camera',
                          onSelected: (selected) {
                            context
                                .read<SearchBloc>()
                                .add(CategoryFilterChanged('Camera'));
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              Expanded(
                child: BlocBuilder<SearchBloc, SearchState>(
                  builder: (context, state) {
                    if (state is SearchLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is SearchFailure) {
                      return Center(child: Text(state.error));
                    } else if (state is SearchSuccess) {
                      return ListView.builder(
                        itemCount: state.products.length,
                        itemBuilder: (context, index) {
                          final product = state.products[index];
                          return ListTile(
                            title: Text(
                              product.name,
                              style: const TextStyle(color: AppColors.buttonText),
                            ),
                            subtitle: Text(
                              '₹${product.rentalPrice}/Day',
                              style: const TextStyle(color:  AppColors.buttonText),
                            ),
                            leading: Image.network(
                              product.images.first,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
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
                    return Container(); // Empty container as fallback
                  },
                ),
              ),
            ],
          ),
        ),
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
        style: TextStyle(color: AppColors.buttonText),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: AppColors.textSecondary),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          suffixIcon:
              const Icon(Icons.search, color: AppColors.indicatorActive),
        ),
        onChanged: onChanged,
      ),
    );
  }
}
