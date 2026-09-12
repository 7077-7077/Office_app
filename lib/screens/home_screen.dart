import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:office_app/models/asset_model.dart';
import 'package:office_app/screens/asset_detail_screen.dart';
import 'package:office_app/screens/asset_form_screen.dart';
import 'package:office_app/services/excel_service.dart';
import 'package:office_app/services/firestore_service.dart';
import 'package:office_app/theme.dart';
import 'package:office_app/widgets/animated_widgets.dart';
import 'package:office_app/widgets/custom_widgets.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback? onViewAll;
  const HomeScreen({super.key, this.onViewAll});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isImporting = false;
  int _touchedIndex = -1;

  Future<void> _importExcel() async {
    setState(() => _isImporting = true);
    try {
      final newRecords = await ExcelService.pickAndParseExcel();
      if (newRecords.isNotEmpty) {
        final count = await FirestoreService.bulkAddAssets(newRecords);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Successfully imported $count records!'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Import failed: $e'), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) setState(() => _isImporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return StreamBuilder<List<AssetRecord>>(
      stream: FirestoreService.getAssets(),
      builder: (context, snapshot) {
        final allAssets = snapshot.data ?? [];
        final recentRecords = allAssets.take(3).toList();
        final totalAssets = allAssets.length;
        final rentAssets = allAssets.where((r) => r.assetStatus.toLowerCase() == 'rent').length;
        final purchasedAssets = totalAssets - rentAssets;

        return Scaffold(
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
                          : [const Color(0xFFFFFFFF), const Color(0xFFF3F4F6)],
                    ),
                  ),
                ),
              ),
              SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Office Pulse', style: theme.textTheme.bodyMedium),
                              Text('Dashboard', style: theme.textTheme.displayLarge),
                            ],
                          ),
                          CircleAvatar(
                            backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                            radius: 24,
                            child: const Icon(Icons.notifications_outlined, color: AppTheme.primaryColor),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Chart Dashboard Section
                      if (totalAssets > 0)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 24),
                          child: GlassCard(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Inventory Breakdown',
                                    style: TextStyle(
                                      color: theme.textTheme.titleLarge?.color, 
                                      fontSize: 18, 
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  SizedBox(
                                    height: 180,
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: PieChart(
                                            PieChartData(
                                              pieTouchData: PieTouchData(
                                                touchCallback: (event, response) {
                                                  setState(() {
                                                    if (!event.isInterestedForInteractions || response == null || response.touchedSection == null) {
                                                      _touchedIndex = -1;
                                                      return;
                                                    }
                                                    _touchedIndex = response.touchedSection!.touchedSectionIndex;
                                                  });
                                                },
                                              ),
                                              borderData: FlBorderData(show: false),
                                              sectionsSpace: 4,
                                              centerSpaceRadius: 40,
                                              sections: [
                                                PieChartSectionData(
                                                  color: Colors.green,
                                                  value: purchasedAssets.toDouble(),
                                                  title: totalAssets > 0 ? '${((purchasedAssets / totalAssets) * 100).toStringAsFixed(0)}%' : '0%',
                                                  radius: _touchedIndex == 0 ? 60 : 50,
                                                  titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                                                ),
                                                PieChartSectionData(
                                                  color: Colors.orange,
                                                  value: rentAssets.toDouble(),
                                                  title: totalAssets > 0 ? '${((rentAssets / totalAssets) * 100).toStringAsFixed(0)}%' : '0%',
                                                  radius: _touchedIndex == 1 ? 60 : 50,
                                                  titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 24),
                                        Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            _ChartLegend(color: Colors.green, label: 'Purchased', value: '$purchasedAssets'),
                                            const SizedBox(height: 12),
                                            _ChartLegend(color: Colors.orange, label: 'Rent', value: '$rentAssets'),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                      // Quick Stats Row with Animated Counter
                      Row(
                        children: [
                          _StatCard(title: 'Total', value: totalAssets, icon: Icons.inventory_2_rounded, color: AppTheme.primaryColor),
                          const SizedBox(width: 12),
                          _StatCard(title: 'Purchased', value: purchasedAssets, icon: Icons.shopping_bag_rounded, color: Colors.green),
                          const SizedBox(width: 12),
                          _StatCard(title: 'Rent', value: rentAssets, icon: Icons.access_time_filled_rounded, color: Colors.orange),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Add New Employee Premium Card
                      ScaleOnPress(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AssetFormScreen())),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [AppTheme.primaryColor, AppTheme.secondaryColor.withValues(alpha: 0.8)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primaryColor.withValues(alpha: 0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(Icons.person_add_alt_1_rounded, color: Colors.white, size: 32),
                              ),
                              const SizedBox(width: 20),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Add New Employee',
                                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      'Create & pre-fill asset records',
                                      style: TextStyle(color: Colors.white70, fontSize: 13),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white70, size: 20),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Bulk Import Excel Card
                      ScaleOnPress(
                        onTap: _isImporting ? null : _importExcel,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.3), width: 1.5),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: _isImporting 
                                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryColor))
                                  : const Icon(Icons.drive_file_move_rounded, color: AppTheme.primaryColor, size: 24),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Bulk Import from Excel',
                                      style: TextStyle(color: theme.textTheme.titleLarge?.color, fontSize: 16, fontWeight: FontWeight.w600),
                                    ),
                                    Text(
                                      'Upload spreadsheet for mass entry',
                                      style: TextStyle(color: theme.textTheme.bodySmall?.color, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Recent Employees', style: theme.textTheme.titleLarge),
                          TextButton(
                            onPressed: widget.onViewAll,
                            child: const Text('View All', style: TextStyle(color: AppTheme.primaryColor)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      if (snapshot.connectionState == ConnectionState.waiting)
                        Column(
                          children: List.generate(3, (i) => const Padding(
                            padding: EdgeInsets.only(bottom: 12),
                            child: ShimmerSkeleton(height: 72, borderRadius: 20),
                          )),
                        )
                      else if (recentRecords.isEmpty)
                        Center(child: Text('No employees found', style: TextStyle(color: theme.textTheme.bodySmall?.color)))
                      else
                        ...recentRecords.asMap().entries.map((entry) => StaggeredListAnimation(
                              index: entry.key,
                              child: _RecentEmployeeCard(record: entry.value),
                            )),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ChartLegend extends StatelessWidget {
  final Color color;
  final String label;
  final String value;
  const _ChartLegend({required this.color, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(label, style: TextStyle(color: theme.textTheme.bodySmall?.color, fontSize: 14)),
        const SizedBox(width: 8),
        Text(value, style: TextStyle(color: theme.textTheme.titleLarge?.color, fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final int value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: GlassCard(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 12),
              AnimatedCounter(
                value: value,
                style: TextStyle(
                  color: theme.textTheme.displayLarge?.color,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  color: theme.textTheme.bodySmall?.color,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentEmployeeCard extends StatelessWidget {
  final AssetRecord record;
  const _RecentEmployeeCard({required this.record});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRent = record.assetStatus.toLowerCase() == 'rent';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: ScaleOnPress(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AssetDetailScreen(record: record))),
        child: GlassCard(
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Hero(
              tag: 'avatar-${record.id}',
              child: CircleAvatar(
                backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                child: const Icon(Icons.person, color: AppTheme.primaryColor),
              ),
            ),
            title: Hero(
              tag: 'name-${record.id}',
              child: Material(
                color: Colors.transparent,
                child: Text(
                  record.employeeName,
                  style: TextStyle(
                    color: theme.textTheme.titleLarge?.color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            subtitle: Text(
              '${record.laptopBrand} ${record.laptopModelNo}',
              style: TextStyle(color: theme.textTheme.bodySmall?.color),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: (isRent ? Colors.orange : Colors.green).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                record.assetStatus.toUpperCase(),
                style: TextStyle(
                  color: isRent ? Colors.orange : Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
