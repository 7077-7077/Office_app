import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:office_app/models/asset_model.dart';
import 'package:office_app/screens/asset_form_screen.dart';
import 'package:office_app/theme.dart';
import 'package:office_app/widgets/custom_widgets.dart';

class AssetDetailScreen extends StatelessWidget {
  final AssetRecord record;
  const AssetDetailScreen({super.key, required this.record});

  void _copyToClipboard(BuildContext context, String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copied to clipboard!'),
        backgroundColor: AppTheme.primaryColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final r = record;
    final isRent = r.assetStatus.toLowerCase() == 'rent';
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = theme.textTheme.displayLarge?.color ?? Colors.black87;

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
                      : [const Color(0xFFFFFFFF), const Color(0xFFF1F5F9)],
                ),
              ),
            ),
          ),
          CustomScrollView(
            slivers: [
              // Premium Hero Header
              SliverAppBar(
                expandedHeight: 200,
                backgroundColor: Colors.transparent,
                elevation: 0,
                pinned: true,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back_ios_new_rounded, color: textColor, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    children: [
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                AppTheme.primaryColor.withValues(alpha: 0.2),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                      Center(
                        child: Hero(
                          tag: 'avatar-${r.id}',
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                            child: const Icon(Icons.person, size: 60, color: AppTheme.primaryColor),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  IconButton(
                    icon: Icon(Icons.edit_note_rounded, color: textColor),
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AssetFormScreen(record: r))),
                  ),
                ],
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      Hero(
                        tag: 'name-${r.id}',
                        child: Material(
                          color: Colors.transparent,
                          child: Text(
                            r.employeeName,
                            style: theme.textTheme.displayMedium?.copyWith(fontSize: 32),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.3)),
                            ),
                            child: Text(
                              'ID: ${r.companyId}',
                              style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 8),
                          _DetailStatusBadge(label: r.assetStatus, color: isRent ? Colors.orange : Colors.green),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Actions Row
                      Row(
                        children: [
                          Expanded(
                            child: _ActionTile(
                              icon: Icons.copy_rounded,
                              label: 'Copy ID',
                              onTap: () => _copyToClipboard(context, r.companyId, 'Company ID'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _ActionTile(
                              icon: Icons.share_rounded,
                              label: 'Share Info',
                              onTap: () {}, // TODO: Implement sharing
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Detail Sections
                      _DetailSection(title: 'Personal Info', items: [
                        _DetailItem('Company Name', r.companyName, Icons.corporate_fare_outlined),
                        _DetailItem('Department', r.employeeDepartment, Icons.business_outlined),
                        _DetailItem('Email', r.employeeEmail, Icons.email_outlined),
                        _DetailItem('Contact', r.employeeContact, Icons.phone_android_outlined),
                        _DetailItem('Role / Group', r.workFrom, Icons.work_outline),
                        _DetailItem('Office Location', r.officeLocation, Icons.location_on_outlined),
                      ]),

                      _DetailSection(title: 'Main Hardware (Laptop)', items: [
                        _DetailItem('Brand', r.laptopBrand, Icons.laptop_mac),
                        _DetailItem('Model No', r.laptopModelNo, Icons.model_training),
                        _DetailItem('Serial No', r.laptopSerialNo, Icons.qr_code_2, onCopy: () => _copyToClipboard(context, r.laptopSerialNo, 'Serial No')),
                        _DetailItem('Prev Model', r.prevLaptopModelNo, Icons.history),
                        _DetailItem('Config', r.configuration, Icons.settings_suggest_outlined),
                      ]),

                      _DetailSection(title: 'Peripherals', items: [
                        _DetailItem('Headphone SN', r.headphoneSerialNo, Icons.headset_outlined),
                        _DetailItem('Charger SN', r.chargerSerialNo, Icons.power_outlined),
                        _DetailItem('Mouse SN', r.mouseSerialNo, Icons.mouse_outlined),
                        _DetailItem('Keyboard SN', r.keyboardSerialNo, Icons.keyboard_outlined),
                        _DetailItem('Screen Brand', r.screenCompany, Icons.monitor_outlined),
                        _DetailItem('Screen SN', r.screenSerialNo, Icons.qr_code),
                      ]),

                      _DetailSection(title: 'Dates & Warranty', items: [
                        _DetailItem('Issue Date', r.laptopIssueDate?.toString().split(' ')[0] ?? '-', Icons.calendar_today_outlined),
                        _DetailItem('Expiry Date', r.laptopExpiryDate?.toString().split(' ')[0] ?? '-', Icons.event_busy_outlined),
                      ]),

                      if (r.remark.isNotEmpty)
                        _DetailSection(title: 'Remarks', items: [
                          _DetailItem('Notes', r.remark, Icons.notes_rounded),
                        ]),
                      
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DetailSection extends StatelessWidget {
  final String title;
  final List<Widget> items;
  const _DetailSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title.toUpperCase(),
            style: const TextStyle(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
              letterSpacing: 1.2,
            ),
          ),
        ),
        GlassCard(
          child: Column(
            children: items,
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _DetailItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final VoidCallback? onCopy;
  const _DetailItem(this.label, this.value, this.icon, {this.onCopy});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.titleLarge?.color ?? Colors.black87;

    return ListTile(
      leading: Icon(icon, color: textColor.withValues(alpha: 0.2), size: 20),
      title: Text(label, style: TextStyle(color: textColor.withValues(alpha: 0.4), fontSize: 11)),
      subtitle: Text(value.isEmpty ? '-' : value, style: TextStyle(color: textColor, fontSize: 15, fontWeight: FontWeight.w500)),
      trailing: onCopy != null 
        ? IconButton(icon: const Icon(Icons.copy_rounded, size: 16, color: AppTheme.primaryColor), onPressed: onCopy)
        : null,
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ActionTile({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.titleLarge?.color ?? Colors.black87;

    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Icon(icon, color: AppTheme.primaryColor),
              const SizedBox(height: 8),
              Text(label, style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailStatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _DetailStatusBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 10),
      ),
    );
  }
}
