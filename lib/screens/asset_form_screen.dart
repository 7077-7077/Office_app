import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:office_app/models/asset_model.dart';
import 'package:office_app/services/firestore_service.dart';
import 'package:office_app/services/pdf_service.dart';
import 'package:office_app/services/preset_templates.dart';
import 'package:office_app/theme.dart';
import 'package:office_app/widgets/animated_widgets.dart';
import 'package:office_app/widgets/custom_widgets.dart';

class AssetFormScreen extends StatefulWidget {
  final AssetRecord? record;
  const AssetFormScreen({super.key, this.record});

  @override
  State<AssetFormScreen> createState() => _AssetFormScreenState();
}

class _AssetFormScreenState extends State<AssetFormScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  int _currentStep = 0;

  // Employee Information
  final _companyIdController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _nameController = TextEditingController();
  final _deptController = TextEditingController();
  final _emailController = TextEditingController();
  final _contactController = TextEditingController();
  final _workFromController = TextEditingController();
  final _officeLocationController = TextEditingController();

  // Asset Status
  String _assetStatus = 'Purchased';

  // Laptop Details
  final _laptopBrandController = TextEditingController();
  final _laptopModelController = TextEditingController();
  final _laptopSerialController = TextEditingController();
  final _prevLaptopModelController = TextEditingController();
  final _configController = TextEditingController();
  final _hostNameController = TextEditingController();
  DateTime? _laptopIssueDate;
  DateTime? _laptopExpiryDate;

  // Screen Details
  final _screenSerialController = TextEditingController();
  final _screenCompanyController = TextEditingController();

  // Peripherals
  final _headphoneSNController = TextEditingController();
  final _mouseSNController = TextEditingController();
  final _keyboardSNController = TextEditingController();
  final _chargerSNController = TextEditingController();

  // Connectivity & Office
  final _wifiMacController = TextEditingController();
  final _dataCardController = TextEditingController();
  final _deskNoController = TextEditingController();

  // Software Details
  final _softwareController = TextEditingController();
  final _softwareSNController = TextEditingController();
  DateTime? _softwareExpiryDate;
  DateTime? _softwareRenewalDate;

  // Company Asset Details
  final _companyAssetNameController = TextEditingController();
  final _hdfcItemIdController = TextEditingController();
  final _assetNumberController = TextEditingController();
  DateTime? _assetIssueDate;
  DateTime? _assetExpiryDate;

  // Remark
  final _remarkController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.record != null) {
      _populateFields(widget.record!);
    } else {
      _autoFillFromProfile();
      // Pre-fill initial random tag if empty
      _assetNumberController.text = PresetService.generateAssetNumber();
    }
  }

  Future<void> _autoFillFromProfile() async {
    final profile = await FirestoreService.getUserProfileFuture();
    if (profile != null && mounted) {
      setState(() {
        if (_companyNameController.text.isEmpty) _companyNameController.text = profile.companyName;
        if (_officeLocationController.text.isEmpty) _officeLocationController.text = 'Main Office';
      });
    }
  }

  void _populateFields(AssetRecord r) {
    _companyIdController.text = r.companyId;
    _companyNameController.text = r.companyName;
    _nameController.text = r.employeeName;
    _deptController.text = r.employeeDepartment;
    _emailController.text = r.employeeEmail;
    _contactController.text = r.employeeContact;
    _workFromController.text = r.workFrom;
    _officeLocationController.text = r.officeLocation;
    _assetStatus = r.purchaseOrRent;
    _laptopBrandController.text = r.laptopBrand;
    _laptopModelController.text = r.laptopModelNo;
    _laptopSerialController.text = r.laptopSerialNo;
    _prevLaptopModelController.text = r.prevLaptopModelNo;
    _configController.text = r.configuration;
    _hostNameController.text = r.computerHostName;
    _laptopIssueDate = r.laptopIssueDate;
    _laptopExpiryDate = r.laptopExpiryDate;

    _screenSerialController.text = r.screenSerialNo;
    _screenCompanyController.text = r.screenCompany;
    _headphoneSNController.text = r.headphoneSerialNo;
    _chargerSNController.text = r.chargerSerialNo;
    _mouseSNController.text = r.mouseSerialNo;
    _keyboardSNController.text = r.keyboardSerialNo;
    _wifiMacController.text = r.wifiMacAddress;
    _dataCardController.text = r.dataCardNo;
    _deskNoController.text = r.deskNo;

    _softwareController.text = r.softwareInstalled;
    _softwareSNController.text = r.softwareSerialNo;
    _softwareExpiryDate = r.softwareExpiryDate;
    _softwareRenewalDate = r.softwareRenewalDate;
    _companyAssetNameController.text = r.companyAssetName;
    _hdfcItemIdController.text = r.hdfcItemIdName;
    _assetNumberController.text = r.assetNumber;
    _assetIssueDate = r.assetIssueDate;
    _assetExpiryDate = r.assetExpiryDate;
    _remarkController.text = r.remark;
  }

  void _applyPreset(AssetPreset preset) {
    setState(() {
      _laptopBrandController.text = preset.laptopBrand;
      _laptopModelController.text = preset.laptopModelNo;
      _configController.text = preset.configuration;
      _assetStatus = preset.purchaseOrRent;
      _screenCompanyController.text = preset.screenCompany;
      _workFromController.text = preset.workFrom;
      _remarkController.text = preset.remark;

      if (_laptopSerialController.text.isEmpty) {
        _laptopSerialController.text = PresetService.generateSerialNo('LP');
      }
      if (_hostNameController.text.isEmpty) {
        _hostNameController.text = PresetService.generateHostName('DEV');
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Applied "${preset.title}" preset template!'),
        backgroundColor: AppTheme.primaryColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _saveAsset() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in required fields (Name & Company ID)'),
          backgroundColor: Colors.orangeAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final asset = AssetRecord(
        id: widget.record?.id,
        companyId: _companyIdController.text.trim(),
        companyName: _companyNameController.text.trim(),
        employeeName: _nameController.text.trim(),
        employeeDepartment: _deptController.text.trim(),
        employeeEmail: _emailController.text.trim(),
        employeeContact: _contactController.text.trim(),
        workFrom: _workFromController.text.trim(),
        laptopBrand: _laptopBrandController.text.trim(),
        laptopModelNo: _laptopModelController.text.trim(),
        laptopSerialNo: _laptopSerialController.text.trim(),
        prevLaptopModelNo: _prevLaptopModelController.text.trim(),
        configuration: _configController.text.trim(),
        computerHostName: _hostNameController.text.trim(),
        headphoneSerialNo: _headphoneSNController.text.trim(),
        mouseSerialNo: _mouseSNController.text.trim(),
        keyboardSerialNo: _keyboardSNController.text.trim(),
        chargerSerialNo: _chargerSNController.text.trim(),
        screenSerialNo: _screenSerialController.text.trim(),
        screenCompany: _screenCompanyController.text.trim(),
        wifiMacAddress: _wifiMacController.text.trim(),
        dataCardNo: _dataCardController.text.trim(),
        deskNo: _deskNoController.text.trim(),
        laptopIssueDate: _laptopIssueDate,
        laptopExpiryDate: _laptopExpiryDate,
        softwareInstalled: _softwareController.text.trim(),
        softwareExpiryDate: _softwareExpiryDate,
        softwareRenewalDate: _softwareRenewalDate,
        softwareSerialNo: _softwareSNController.text.trim(),
        officeLocation: _officeLocationController.text.trim(),
        assetStatus: _assetStatus,
        purchaseOrRent: _assetStatus,
        remark: _remarkController.text.trim(),
        companyAssetName: _companyAssetNameController.text.trim(),
        hdfcItemIdName: _hdfcItemIdController.text.trim(),
        assetNumber: _assetNumberController.text.trim(),
        assetIssueDate: _assetIssueDate,
        assetExpiryDate: _assetExpiryDate,
        createdAt: widget.record?.createdAt ?? DateTime.now(),
        completedAt: widget.record == null ? DateTime.now() : widget.record?.completedAt,
        managedByName: widget.record?.managedByName ?? '',
      );

      if (widget.record == null) {
        await FirestoreService.addAsset(asset);
      } else {
        await FirestoreService.updateAsset(asset);
      }

      if (mounted) {
        _showSuccessDialog(asset);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving: $e'), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSuccessDialog(AssetRecord asset) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;

        return Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.cardColor : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 25,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_rounded, color: Colors.green, size: 36),
              ),
              const SizedBox(height: 16),
              Text(
                'Asset Record Saved!',
                style: theme.textTheme.titleLarge?.copyWith(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Details for "${asset.employeeName}" have been stored successfully.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 28),

              // Generate PDF Button
              ScaleOnPress(
                onTap: () async {
                  Navigator.pop(context); // Close bottom sheet
                  Navigator.pop(this.context); // Return to directory
                  await PdfService.generateAndDownloadPdf(asset);
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [AppTheme.primaryColor, AppTheme.secondaryColor]),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryColor.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.picture_as_pdf_rounded, color: Colors.white, size: 22),
                      SizedBox(width: 10),
                      Text(
                        'Generate & Download PDF Report',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(this.context);
                },
                child: const Text('Return to Directory', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  Future<void> _selectDate(BuildContext context, String dateType) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      setState(() {
        if (dateType == 'laptopIssue') _laptopIssueDate = picked;
        if (dateType == 'laptopExpiry') _laptopExpiryDate = picked;
        if (dateType == 'softwareExpiry') _softwareExpiryDate = picked;
        if (dateType == 'softwareRenewal') _softwareRenewalDate = picked;
        if (dateType == 'assetIssue') _assetIssueDate = picked;
        if (dateType == 'assetExpiry') _assetExpiryDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
          SafeArea(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // App Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: Icon(Icons.arrow_back_ios_new_rounded, color: textColor, size: 20),
                          onPressed: () => Navigator.pop(context),
                        ),
                        Text(
                          widget.record == null ? 'New Asset Record' : 'Edit Asset Record',
                          style: theme.textTheme.titleLarge?.copyWith(fontSize: 20),
                        ),
                        if (widget.record != null)
                          IconButton(
                            icon: const Icon(Icons.picture_as_pdf_rounded, color: AppTheme.primaryColor),
                            onPressed: () => PdfService.generateAndDownloadPdf(widget.record!),
                          )
                        else
                          const SizedBox(width: 48),
                      ],
                    ),
                  ),

                  // Presets Quick Bar
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Text('Presets:', style: TextStyle(color: textColor.withValues(alpha: 0.5), fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                        ...PresetService.presets.map((preset) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ScaleOnPress(
                                onTap: () => _applyPreset(preset),
                                child: Chip(
                                  backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                                  side: BorderSide(color: AppTheme.primaryColor.withValues(alpha: 0.3)),
                                  avatar: const Icon(Icons.auto_awesome_rounded, size: 14, color: AppTheme.primaryColor),
                                  label: Text(preset.title, style: const TextStyle(fontSize: 12, color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
                                ),
                              ),
                            )),
                      ],
                    ),
                  ),

                  // Step Indicators Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    child: Row(
                      children: [
                        _buildStepTab(0, '1. Employee', Icons.person_outlined),
                        _buildStepTab(1, '2. Hardware', Icons.laptop_mac_outlined),
                        _buildStepTab(2, '3. Peripherals', Icons.devices_other_outlined),
                        _buildStepTab(3, '4. Software', Icons.integration_instructions_outlined),
                      ],
                    ),
                  ),

                  // Form Content Body
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      child: IndexedStack(
                        index: _currentStep,
                        children: [
                          _buildStep1Employee(),
                          _buildStep2Hardware(),
                          _buildStep3Peripherals(),
                          _buildStep4SoftwareAndNotes(),
                        ],
                      ),
                    ),
                  ),

                  // Navigation & Save Footer
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    decoration: BoxDecoration(
                      color: (isDark ? AppTheme.cardColor : Colors.white).withValues(alpha: 0.9),
                      border: Border(top: BorderSide(color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05))),
                    ),
                    child: Row(
                      children: [
                        if (_currentStep > 0)
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => setState(() => _currentStep--),
                              icon: const Icon(Icons.arrow_back_rounded, size: 18),
                              label: const Text('Previous'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                            ),
                          )
                        else
                          const Spacer(),

                        const SizedBox(width: 12),

                        if (_currentStep < 3)
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => setState(() => _currentStep++),
                              icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                              label: const Text('Next Step'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryColor,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                            ),
                          )
                        else
                          Expanded(
                            flex: 2,
                            child: ScaleOnPress(
                              onTap: _isLoading ? null : _saveAsset,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(colors: [AppTheme.primaryColor, AppTheme.secondaryColor]),
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.primaryColor.withValues(alpha: 0.3),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _saveAsset,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                  ),
                                  child: _isLoading
                                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                      : const Text(
                                          'Save Asset & Finish',
                                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                                        ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepTab(int index, String label, IconData icon) {
    final isSelected = _currentStep == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _currentStep = index),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppTheme.primaryColor : Colors.grey.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            children: [
              Icon(icon, size: 18, color: isSelected ? Colors.white : Colors.grey),
              const SizedBox(height: 4),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.white : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Step 1: Employee & Location Info
  Widget _buildStep1Employee() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Employee Details', Icons.badge_outlined),
        CustomTextField(
          label: 'Employee Name *',
          hint: 'e.g. John Doe',
          icon: Icons.person_outline,
          controller: _nameController,
          validator: (v) => v == null || v.trim().isEmpty ? 'Name is required' : null,
        ),
        CustomTextField(
          label: 'Company ID *',
          hint: 'e.g. EMP-1092',
          icon: Icons.card_membership_outlined,
          controller: _companyIdController,
          validator: (v) => v == null || v.trim().isEmpty ? 'Company ID is required' : null,
        ),
        CustomTextField(label: 'Company Name', hint: 'e.g. Acme Corp', icon: Icons.corporate_fare_outlined, controller: _companyNameController),
        CustomTextField(label: 'Department', hint: 'e.g. Engineering', icon: Icons.business_outlined, controller: _deptController),
        CustomTextField(label: 'Email', hint: 'e.g. john@company.com', icon: Icons.email_outlined, controller: _emailController, keyboardType: TextInputType.emailAddress),
        CustomTextField(label: 'Contact No', hint: 'e.g. +1 234 567 8900', icon: Icons.phone_android_outlined, controller: _contactController, keyboardType: TextInputType.phone),
        Row(
          children: [
            Expanded(child: CustomTextField(label: 'Work From', hint: 'Hybrid / Office / Remote', icon: Icons.work_outline, controller: _workFromController)),
            const SizedBox(width: 16),
            Expanded(child: CustomTextField(label: 'Office Location', hint: 'New York HQ', icon: Icons.location_on_outlined, controller: _officeLocationController)),
          ],
        ),
      ],
    );
  }

  // Step 2: Hardware & Laptop Details
  Widget _buildStep2Hardware() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Laptop Specs', Icons.laptop_mac_outlined),

        // Status Segment Selector
        Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Ownership Type', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              const SizedBox(height: 8),
              Row(
                children: ['Purchased', 'Rent'].map((status) {
                  final isSelected = _assetStatus == status;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _assetStatus = status),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: isSelected ? AppTheme.primaryColor : AppTheme.primaryColor.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: isSelected ? AppTheme.primaryColor : Colors.transparent),
                        ),
                        child: Text(
                          status,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: isSelected ? Colors.white : AppTheme.primaryColor, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),

        CustomTextField(label: 'Laptop Brand', hint: 'Apple / Dell / Lenovo', icon: Icons.laptop_mac, controller: _laptopBrandController),
        CustomTextField(label: 'Laptop Model No', hint: 'e.g. MacBook Pro M3', icon: Icons.model_training, controller: _laptopModelController),
        
        Row(
          children: [
            Expanded(child: CustomTextField(label: 'Serial Number', hint: 'e.g. C02G801QMD6M', icon: Icons.qr_code_2, controller: _laptopSerialController)),
            const SizedBox(width: 8),
            Padding(
              padding: const EdgeInsets.only(top: 14),
              child: IconButton.filledTonal(
                icon: const Icon(Icons.auto_awesome_rounded, size: 20),
                tooltip: 'Auto-Gen Serial',
                onPressed: () => setState(() => _laptopSerialController.text = PresetService.generateSerialNo('LP')),
              ),
            ),
          ],
        ),

        Row(
          children: [
            Expanded(child: CustomTextField(label: 'Computer Host Name', hint: 'e.g. DEV-LAP-09', icon: Icons.dns_outlined, controller: _hostNameController)),
            const SizedBox(width: 8),
            Padding(
              padding: const EdgeInsets.only(top: 14),
              child: IconButton.filledTonal(
                icon: const Icon(Icons.auto_awesome_rounded, size: 20),
                tooltip: 'Auto-Gen Host',
                onPressed: () => setState(() => _hostNameController.text = PresetService.generateHostName('HOST')),
              ),
            ),
          ],
        ),

        CustomTextField(label: 'Configuration Specs', hint: 'e.g. 16GB RAM / 512GB SSD', icon: Icons.settings_suggest_outlined, controller: _configController),
        CustomTextField(label: 'Previous Laptop Model', hint: 'e.g. ThinkPad T14', icon: Icons.history, controller: _prevLaptopModelController),

        Row(
          children: [
            Expanded(child: CustomTextField(label: 'Laptop Issue Date', hint: _laptopIssueDate == null ? 'Select Date' : DateFormat('MMM dd, yyyy').format(_laptopIssueDate!), icon: Icons.calendar_month_outlined, readOnly: true, onTap: () => _selectDate(context, 'laptopIssue'))),
            const SizedBox(width: 16),
            Expanded(child: CustomTextField(label: 'Laptop Expiry Date', hint: _laptopExpiryDate == null ? 'Select Date' : DateFormat('MMM dd, yyyy').format(_laptopExpiryDate!), icon: Icons.calendar_month_outlined, readOnly: true, onTap: () => _selectDate(context, 'laptopExpiry'))),
          ],
        ),
      ],
    );
  }

  // Step 3: Peripherals & Connectivity
  Widget _buildStep3Peripherals() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Screen & Monitors', Icons.monitor_outlined),
        CustomTextField(label: 'Screen / Monitor Brand', hint: 'e.g. Dell 27"', icon: Icons.monitor_outlined, controller: _screenCompanyController),
        CustomTextField(label: 'Screen Serial No', hint: 'e.g. CN-08912', icon: Icons.qr_code, controller: _screenSerialController),

        _buildSectionHeader('Accessories & Peripherals', Icons.devices_other_outlined),
        CustomTextField(label: 'Headphone Serial No', hint: 'e.g. HP-9018', icon: Icons.headset_outlined, controller: _headphoneSNController),
        CustomTextField(label: 'Charger Serial No', hint: 'e.g. CHG-8812', icon: Icons.power_outlined, controller: _chargerSNController),
        CustomTextField(label: 'Mouse Serial No', hint: 'e.g. MS-1244', icon: Icons.mouse_outlined, controller: _mouseSNController),
        CustomTextField(label: 'Keyboard Serial No', hint: 'e.g. KB-9912', icon: Icons.keyboard_outlined, controller: _keyboardSNController),

        _buildSectionHeader('Connectivity & Desk', Icons.wifi_outlined),
        CustomTextField(label: 'WiFi MAC Address', hint: 'e.g. 00:1B:44:11:3A:B7', icon: Icons.wifi_outlined, controller: _wifiMacController),
        CustomTextField(label: 'Data Card / SIM No', hint: 'e.g. 89012401', icon: Icons.sim_card_outlined, controller: _dataCardController),
        CustomTextField(label: 'Desk / Seat No', hint: 'e.g. Desk-3B', icon: Icons.chair_outlined, controller: _deskNoController),
      ],
    );
  }

  // Step 4: Software, Tags & Remarks
  Widget _buildStep4SoftwareAndNotes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Software Licenses', Icons.integration_instructions_outlined),
        CustomTextField(label: 'Software Installed', hint: 'e.g. VS Code, Adobe CC, Office 365', icon: Icons.apps_outlined, controller: _softwareController),
        CustomTextField(label: 'Software License Key / SN', hint: 'e.g. XXXX-YYYY-ZZZZ', icon: Icons.key_outlined, controller: _softwareSNController),

        Row(
          children: [
            Expanded(child: CustomTextField(label: 'Software Expiry', hint: _softwareExpiryDate == null ? 'Select Date' : DateFormat('MMM dd, yyyy').format(_softwareExpiryDate!), icon: Icons.calendar_month_outlined, readOnly: true, onTap: () => _selectDate(context, 'softwareExpiry'))),
            const SizedBox(width: 16),
            Expanded(child: CustomTextField(label: 'Software Renewal', hint: _softwareRenewalDate == null ? 'Select Date' : DateFormat('MMM dd, yyyy').format(_softwareRenewalDate!), icon: Icons.calendar_month_outlined, readOnly: true, onTap: () => _selectDate(context, 'softwareRenewal'))),
          ],
        ),

        _buildSectionHeader('Asset Tagging', Icons.tag_outlined),
        Row(
          children: [
            Expanded(child: CustomTextField(label: 'Asset Number / Tag', hint: 'e.g. OFF-2026-9812', icon: Icons.numbers_outlined, controller: _assetNumberController)),
            const SizedBox(width: 8),
            Padding(
              padding: const EdgeInsets.only(top: 14),
              child: IconButton.filledTonal(
                icon: const Icon(Icons.auto_awesome_rounded, size: 20),
                tooltip: 'Auto-Gen Tag',
                onPressed: () => setState(() => _assetNumberController.text = PresetService.generateAssetNumber()),
              ),
            ),
          ],
        ),

        _buildSectionHeader('Other Remarks', Icons.notes_rounded),
        CustomTextField(label: 'Remark & Notes', hint: 'Any special instructions...', icon: Icons.comment_bank_outlined, controller: _remarkController),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 16),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryColor, size: 20),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _companyIdController.dispose();
    _companyNameController.dispose();
    _nameController.dispose();
    _deptController.dispose();
    _emailController.dispose();
    _contactController.dispose();
    _workFromController.dispose();
    _officeLocationController.dispose();
    _laptopBrandController.dispose();
    _laptopModelController.dispose();
    _laptopSerialController.dispose();
    _prevLaptopModelController.dispose();
    _configController.dispose();
    _hostNameController.dispose();
    _screenSerialController.dispose();
    _screenCompanyController.dispose();
    _headphoneSNController.dispose();
    _chargerSNController.dispose();
    _mouseSNController.dispose();
    _keyboardSNController.dispose();
    _wifiMacController.dispose();
    _dataCardController.dispose();
    _deskNoController.dispose();
    _softwareController.dispose();
    _softwareSNController.dispose();
    _companyAssetNameController.dispose();
    _hdfcItemIdController.dispose();
    _assetNumberController.dispose();
    _remarkController.dispose();
    super.dispose();
  }
}
