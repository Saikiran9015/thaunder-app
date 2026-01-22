import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../business_logic/template_bloc/template_bloc.dart';
import '../../core/theme/app_theme.dart';

class Sidebar extends StatefulWidget {
  const Sidebar({super.key});

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  String? selectedBrand;
  String? selectedCategory = 'phone';

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          right: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
      ),
      child: Column(
        children: [
          // Logo Section
          Container(
            height: 80,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade200, width: 1),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/logo.png',
                  height: 50,
                  fit: BoxFit.contain,
                ),
              ],
            ),
          ),

          // Selection Controls
          BlocBuilder<TemplateBloc, TemplateState>(
            buildWhen: (previous, current) => current is MetadataLoaded,
            builder: (context, state) {
              List<String> categories = ['phone', 'tablet', 'laptop', 'watch'];
              List<String> brands = ['Apple', 'Samsung', 'Google', 'OnePlus', 'Xiaomi'];

              if (state is MetadataLoaded) {
                categories = state.categories;
                brands = state.brands;
              }

              return Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Device Category'),
                    const SizedBox(height: 8),
                    _buildDropdown(
                      value: selectedCategory,
                      items: categories,
                      onChanged: (val) {
                        setState(() {
                          selectedCategory = val;
                          context.read<TemplateBloc>().add(LoadTemplatesEvent(category: val, brand: selectedBrand));
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    _buildLabel('Mobile Company'),
                    const SizedBox(height: 8),
                    _buildDropdown(
                      value: selectedBrand,
                      items: brands,
                      hint: 'Select Brand',
                      onChanged: (val) {
                        setState(() {
                          selectedBrand = val;
                          context.read<TemplateBloc>().add(LoadTemplatesEvent(category: selectedCategory, brand: val));
                        });
                      },
                    ),
                  ],
                ),
              );
            },
          ),

          const Divider(indent: 20, endIndent: 20),

          // Scrollable Template List
          Expanded(
            child: BlocBuilder<TemplateBloc, TemplateState>(
              builder: (context, state) {
                if (state is TemplateLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is TemplatesLoaded) {
                  if (state.templates.isEmpty) {
                    return _buildEmptyState();
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: state.templates.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final template = state.templates[index];
                      return _buildTemplateCard(context, template);
                    },
                  );
                }

                if (state is TemplateError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(state.message, style: const TextStyle(color: Colors.red)),
                    ),
                  );
                }

                return _buildEmptyState();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: Colors.grey,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildDropdown({
    String? value,
    required List<String> items,
    String? hint,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: hint != null ? Text(hint) : null,
          isExpanded: true,
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item.substring(0, 1).toUpperCase() + item.substring(1),
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildTemplateCard(BuildContext context, dynamic template) {
    return BlocBuilder<TemplateBloc, TemplateState>(
      builder: (context, state) {
        final isSelected = state is TemplateSelected && state.template.id == template.id;

        return InkWell(
          onTap: () {
            context.read<TemplateBloc>().add(SelectTemplateEvent(template));
          },
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.primaryColor.withAlpha(13) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? AppTheme.primaryColor : Colors.grey.shade200,
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.phone_android,
                    size: 20,
                    color: isSelected ? AppTheme.primaryColor : Colors.grey,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        template.name,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? AppTheme.primaryColor : AppTheme.textPrimary,
                        ),
                      ),
                      Text(
                        template.brand,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  const Icon(Icons.check_circle, color: AppTheme.primaryColor, size: 18),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 48, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text(
            'No templates found',
            style: TextStyle(color: Colors.grey.shade400, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
