import 'package:flutter/material.dart';
import 'package:office_app/models/asset_model.dart';
import 'package:office_app/screens/asset_form_screen.dart';
import 'package:office_app/theme.dart';
import 'package:office_app/widgets/custom_widgets.dart';
import 'package:office_app/screens/asset_detail_screen.dart';
import 'package:office_app/services/excel_service.dart';
import 'package:office_app/services/firestore_service.dart';

class AssetListScreen extends StatefulWidget {
  const AssetListScreen({super.key});

  @override
  State<AssetListScreen> createState() => _AssetListScreenState();
}

class _AssetListScreenState extends State<AssetListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  String _selectedFilter = "All";
  bool _isImporting = false;
  bool _isExporting = false;
  final Set<String> _selectedIds = {};
  List<AssetRecord> _currentAssetsForExport = [];

  final List<String> _filters = ["All", "Purchased", "Rent", "WFH", "Office"];

  Future<void> _importExcel() async {
    setState(() => _isImporting = true);
    try {
      final newRecords = await ExcelService.pickAndParseExcel();
      if (newRecords.isNotEmpty) {
        final count = await FirestoreService.bulkAddAssets(newRecords);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Successfully imported $count records to Firestore!'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else if (newRecords.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No valid records found in the selected file.'),
              backgroundColor: Colors.orange,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e'), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) setState(() => _isImporting = false);
    }
  }

  Future<void> _exportExcel() async {
    if (_currentAssetsForExport.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No data available to export')),
      );
      return;
    }

    setState(() => _isExporting = true);
    try {
      await ExcelService.exportToExcel(_currentAssetsForExport);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Excel export ready!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e'), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  Future<void> _deleteSelected() async {
    final count = _selectedIds.length;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1B4B).withValues(alpha: 0.9),
        title: const Text('Confirm Delete', style: TextStyle(color: Colors.white)),
        content: Text('Delete $count selected assets permanently?', style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await FirestoreService.deleteAssets(_selectedIds.toList());
      setState(() => _selectedIds.clear());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Deleted $count records'), backgroundColor: Colors.orange),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bool isSelectionMode = _selectedIds.isNotEmpty;

    return PopScope(
      canPop: !isSelectionMode,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (isSelectionMode) {
          setState(() => _selectedIds.clear());
        }
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark 
                        ? [AppTheme.backgroundColor, const Color(0xFF1E1B4B)]
                        : [const Color(0xFFFFFFFF), const Color(0xFFF1F5F9)],
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Animated Header/Selection Bar
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: isSelectionMode
                        ? Padding(
                            key: const ValueKey('selection_bar'),
                            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                            child: GlassCard(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                child: Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.close_rounded, color: isDark ? Colors.white : Colors.black87),
                                      onPressed: () => setState(() => _selectedIds.clear()),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${_selectedIds.length} Selected',
                                      style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 18, fontWeight: FontWeight.bold),
                                    ),
                                    const Spacer(),
                                    IconButton(
                                      icon: const Icon(Icons.delete_sweep_rounded, color: Colors.redAccent),
                                      onPressed: _deleteSelected,
                                      tooltip: 'Delete Selected',
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        : Padding(
                            key: const ValueKey('normal_header'),
                            padding: const EdgeInsets.all(24.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Asset Inventory', style: theme.textTheme.displayLarge),
                                      const SizedBox(height: 8),
                                      Text('High-Fidelity IT Asset Management', style: theme.textTheme.bodyMedium, overflow: TextOverflow.ellipsis),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    _isImporting
                                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryColor))
                                        : IconButton(
                                            onPressed: _importExcel,
                                            icon: const Icon(Icons.drive_folder_upload_rounded, color: AppTheme.primaryColor, size: 28),
                                            tooltip: 'Bulk Upload Excel',
                                          ),
                                    const SizedBox(width: 8),
                                    if (_isExporting)
                                      const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryColor))
                                    else
                                      IconButton(
                                        onPressed: _exportExcel,
                                        icon: const Icon(Icons.file_download_outlined, color: AppTheme.primaryColor, size: 28),
                                        tooltip: 'Download Spreadsheet',
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                  ),

                  // Search Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
                      style: TextStyle(color: theme.textTheme.titleLarge?.color),
                      decoration: InputDecoration(
                        hintText: 'Search by employee, ID, or model...',
                        hintStyle: TextStyle(color: theme.textTheme.bodySmall?.color),
                        prefixIcon: const Icon(Icons.search, color: AppTheme.primaryColor),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.close_rounded, color: theme.textTheme.bodySmall?.color, size: 20),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _searchQuery = "");
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                      ),
                    ),
                  ),

                  // Filter Chips
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 50,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: _filters.length,
                      itemBuilder: (context, index) {
                        final filter = _filters[index];
                        final isSelected = _selectedFilter == filter;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(filter),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() => _selectedFilter = filter);
                            },
                            backgroundColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
                            selectedColor: AppTheme.primaryColor.withValues(alpha: 0.2),
                            checkmarkColor: AppTheme.primaryColor,
                            labelStyle: TextStyle(
                              color: isSelected ? AppTheme.primaryColor : theme.textTheme.bodySmall?.color,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              fontSize: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: isSelected ? AppTheme.primaryColor.withValues(alpha: 0.5) : Colors.transparent,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 16),
                  Expanded(
                    child: StreamBuilder<List<AssetRecord>>(
                      stream: FirestoreService.getAssets(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.redAccent)));
                        }

                        final allAssets = snapshot.data ?? [];
                        final filteredAssets = allAssets.where((record) {
                          final matchesSearch = record.employeeName.toLowerCase().contains(_searchQuery) ||
                              record.companyId.toLowerCase().contains(_searchQuery) ||
                              record.laptopModelNo.toLowerCase().contains(_searchQuery);

                          bool matchesFilter = true;
                          if (_selectedFilter == "Purchased") {
                            matchesFilter = record.assetStatus.toLowerCase() == "purchased";
                          } else if (_selectedFilter == "Rent") {
                            matchesFilter = record.assetStatus.toLowerCase() == "rent";
                          } else if (_selectedFilter == "WFH") {
                            matchesFilter = record.workFrom.toLowerCase().contains("home") || record.workFrom.toLowerCase() == "wfh";
                          } else if (_selectedFilter == "Office") {
                            matchesFilter = record.workFrom.toLowerCase().contains("office") || record.workFrom.toLowerCase() == "wfo";
                          }

                          return matchesSearch && matchesFilter;
                        }).toList();

                        // Store current filtered assets for the export button to use
                        _currentAssetsForExport = filteredAssets;

                        if (filteredAssets.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.inventory_2_outlined, size: 64, color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.2)),
                                const SizedBox(height: 16),
                                Text('No matching assets found', style: TextStyle(color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.5))),
                              ],
                            ),
                          );
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
                          itemCount: filteredAssets.length,
                          itemBuilder: (context, index) {
                            final record = filteredAssets[index];
                            final id = record.id ?? '';
                            return _AssetExpandableCard(
                              record: record,
                              isSelected: _selectedIds.contains(id),
                              onSelect: () {
                                setState(() {
                                  if (_selectedIds.contains(id)) {
                                    _selectedIds.remove(id);
                                  } else {
                                    _selectedIds.add(id);
                                  }
                                });
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: isSelectionMode ? null : _AddAssetButton(),
      ),
    );
  }
}

class _AssetExpandableCard extends StatefulWidget {
  final AssetRecord record;
  final bool isSelected;
  final VoidCallback onSelect;

  const _AssetExpandableCard({
    required this.record,
    required this.isSelected,
    required this.onSelect,
  });

  @override
  State<_AssetExpandableCard> createState() => _AssetExpandableCardState();
}

class _AssetExpandableCardState extends State<_AssetExpandableCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final r = widget.record;
    final isRent = r.assetStatus.toLowerCase() == 'rent';
    final theme = Theme.of(context);
    final textColor = theme.textTheme.titleLarge?.color ?? Colors.black87;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: widget.isSelected ? AppTheme.primaryColor : Colors.transparent,
            width: widget.isSelected ? 2 : 0,
          ),
          boxShadow: widget.isSelected
              ? [BoxShadow(color: AppTheme.primaryColor.withValues(alpha: 0.2), blurRadius: 15)]
              : null,
        ),
        child: GlassCard(
          child: Column(
            children: [
              // Collapsed Header
              InkWell(
                onTap: widget.isSelected
                    ? widget.onSelect
                    : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AssetDetailScreen(record: r),
                          ),
                        );
                      },
                onLongPress: widget.onSelect,
                borderRadius: BorderRadius.circular(24),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (widget.isSelected)
                            const Padding(
                              padding: EdgeInsets.only(right: 12, top: 4),
                              child: Icon(Icons.check_circle_rounded, color: AppTheme.primaryColor, size: 24),
                            ),
                          Hero(
                            tag: 'avatar-${r.id}',
                            child: CircleAvatar(
                              backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.2),
                              radius: 20,
                              child: const Icon(Icons.person, color: AppTheme.primaryColor),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Hero(
                                  tag: 'name-${r.id}',
                                  child: Material(
                                    color: Colors.transparent,
                                    child: Text(
                                      r.employeeName,
                                      style: theme.textTheme.titleLarge?.copyWith(
                                            color: widget.isSelected ? AppTheme.primaryColor : textColor,
                                          ),
                                    ),
                                  ),
                                ),
                                Text('ID: ${r.companyId}', style: TextStyle(color: AppTheme.primaryColor.withValues(alpha: 0.8), fontSize: 13, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              _StatusBadge(label: r.workFrom, color: AppTheme.primaryColor),
                              const SizedBox(height: 4),
                              _StatusBadge(label: r.assetStatus, color: isRent ? Colors.orange : Colors.green),
                            ],
                          ),
                          const SizedBox(width: 8),
                          if (!widget.isSelected)
                            Column(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit_note_rounded, color: AppTheme.primaryColor),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => AssetFormScreen(record: r),
                                      ),
                                    );
                                  },
                                  tooltip: 'Edit Profile',
                                  constraints: const BoxConstraints(),
                                  padding: EdgeInsets.zero,
                                ),
                                IconButton(
                                  icon: Icon(_isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: textColor.withValues(alpha: 0.5)),
                                  onPressed: () => setState(() => _isExpanded = !_isExpanded),
                                  constraints: const BoxConstraints(),
                                  padding: EdgeInsets.zero,
                                ),
                              ],
                            ),
                        ],
                      ),
                      if (!_isExpanded && !widget.isSelected) ...[
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            _SmallLabel(Icons.laptop, r.laptopBrand),
                            const SizedBox(width: 16),
                            _SmallLabel(Icons.location_on, r.officeLocation),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // Expanded Content
              if (_isExpanded && !widget.isSelected)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: Column(
                    children: [
                      Divider(color: textColor.withValues(alpha: 0.05), height: 32),
                      _InfoSection(title: 'Employee Details', items: {
                        'Department': r.employeeDepartment,
                        'Email': r.employeeEmail,
                        'Contact': r.employeeContact,
                        'Office': r.officeLocation,
                      }),
                      _InfoSection(title: 'Main Asset (Laptop)', items: {
                        'Brand': r.laptopBrand,
                        'Model': r.laptopModelNo,
                        'Serial No': r.laptopSerialNo,
                        'Prev Model': r.prevLaptopModelNo,
                        'Issue Date': r.laptopIssueDate?.toLocal().toString().split(' ')[0] ?? '-',
                        'Expiry Date': r.laptopExpiryDate?.toLocal().toString().split(' ')[0] ?? '-',
                      }),
                      _InfoSection(title: 'Technical Info', items: {
                        'Config': r.configuration,
                        'Host Name': r.computerHostName,
                      }),
                      _InfoSection(title: 'Screen Details', items: {
                        'Company': r.screenCompany,
                        'Serial No': r.screenSerialNo,
                      }),
                      _DetailSectionDetail(title: 'Hardware Peripherals', items: {
                        'Headphone SN': r.headphoneSerialNo,
                        'Charger SN': r.chargerSerialNo,
                        'Mouse SN': r.mouseSerialNo,
                        'Keyboard SN': r.keyboardSerialNo,
                      }),
                      _InfoSection(title: 'Corporate Info', items: {
                        'Company Name': r.companyName,
                        'Asset Name': r.companyAssetName,
                        'Asset Number': r.assetNumber,
                      }),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailSectionDetail extends StatelessWidget {
  final String title;
  final Map<String, String> items;
  const _DetailSectionDetail({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.titleLarge?.color ?? Colors.black87;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title.toUpperCase(), style: const TextStyle(color: AppTheme.primaryColor, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 3, mainAxisSpacing: 8, crossAxisSpacing: 16),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final key = items.keys.elementAt(index);
              final val = items[key]!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(key, style: TextStyle(color: textColor.withValues(alpha: 0.3), fontSize: 10)),
                  const SizedBox(height: 2),
                  Text(val, overflow: TextOverflow.ellipsis, style: TextStyle(color: textColor.withValues(alpha: 0.7), fontSize: 12)),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  final String title;
  final Map<String, String> items;
  const _InfoSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.titleLarge?.color ?? Colors.black87;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title.toUpperCase(), style: const TextStyle(color: AppTheme.primaryColor, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 3, mainAxisSpacing: 8, crossAxisSpacing: 16),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final key = items.keys.elementAt(index);
              final val = items[key]!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(key, style: TextStyle(color: textColor.withValues(alpha: 0.3), fontSize: 10)),
                  const SizedBox(height: 2),
                  Text(val.isEmpty ? '-' : val, overflow: TextOverflow.ellipsis, style: TextStyle(color: textColor.withValues(alpha: 0.7), fontSize: 12)),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _StatusBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8), border: Border.all(color: color.withValues(alpha: 0.3))),
      child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 10)),
    );
  }
}

class _SmallLabel extends StatelessWidget {
  final IconData icon;
  final String text;
  const _SmallLabel(this.icon, this.text);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final baseColor = theme.textTheme.bodySmall?.color ?? (isDark ? Colors.white70 : Colors.black54);

    return Row(
      children: [
        Icon(icon, size: 14, color: isDark ? AppTheme.primaryColor.withValues(alpha: 0.8) : AppTheme.primaryColor),
        const SizedBox(width: 6),
        Text(
          text.isEmpty ? '-' : text,
          style: TextStyle(
            color: baseColor.withValues(alpha: 0.9),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _AddAssetButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      width: 64,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(colors: [AppTheme.primaryColor, AppTheme.secondaryColor]),
        boxShadow: [BoxShadow(color: AppTheme.primaryColor.withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AssetFormScreen())),
        backgroundColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: const Icon(Icons.add, size: 32, color: Colors.white),
      ),
    );
  }
}
