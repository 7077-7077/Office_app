import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:office_app/models/asset_model.dart';
import 'package:office_app/theme.dart';
import 'package:office_app/widgets/custom_widgets.dart';
import 'package:office_app/services/firestore_service.dart';
import 'package:office_app/services/pdf_service.dart';

class AssetFormScreen extends StatefulWidget {
  final AssetRecord? record;
  const AssetFormScreen({super.key, this.record});

  @override
  State<AssetFormScreen> createState() => _AssetFormScreenState();
}

class _AssetFormScreenState extends State<AssetFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

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
    _mouseSNController.text = r.mouseSerialNo;
    _keyboardSNController.text = r.keyboardSerialNo;
    _chargerSNController.text = r.chargerSerialNo;
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

  Future<void> _saveAsset() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final asset = AssetRecord(
        id: widget.record?.id,
        companyId: _companyIdController.text,
        companyName: _companyNameController.text,
        employeeName: _nameController.text,
        employeeDepartment: _deptController.text,
        employeeEmail: _emailController.text,
        employeeContact: _contactController.text,
        workFrom: _workFromController.text,
        laptopBrand: _laptopBrandController.text,
        laptopModelNo: _laptopModelController.text,
        laptopSerialNo: _laptopSerialController.text,
        prevLaptopModelNo: _prevLaptopModelController.text,
        configuration: _configController.text,
        computerHostName: _hostNameController.text,
        headphoneSerialNo: _headphoneSNController.text,
        mouseSerialNo: _mouseSNController.text,
        keyboardSerialNo: _keyboardSNController.text,
        chargerSerialNo: _chargerSNController.text,
        screenSerialNo: _screenSerialController.text,
        screenCompany: _screenCompanyController.text,
        wifiMacAddress: _wifiMacController.text,
        dataCardNo: _dataCardController.text,
        deskNo: _deskNoController.text,
        laptopIssueDate: _laptopIssueDate,
        laptopExpiryDate: _laptopExpiryDate,
        softwareInstalled: _softwareController.text,
        softwareExpiryDate: _softwareExpiryDate,
        softwareRenewalDate: _softwareRenewalDate,
        softwareSerialNo: _softwareSNController.text,
        officeLocation: _officeLocationController.text,
        assetStatus: _assetStatus,
        purchaseOrRent: _assetStatus,
        remark: _remarkController.text,
        companyAssetName: _companyAssetNameController.text,
        hdfcItemIdName: _hdfcItemIdController.text,
        assetNumber: _assetNumberController.text,
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Asset Saved to Cloud Successfully!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save: $e'), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _downloadPdf() async {
    final asset = AssetRecord(
      id: widget.record?.id,
      companyId: _companyIdController.text,
      companyName: _companyNameController.text,
      employeeName: _nameController.text,
      employeeDepartment: _deptController.text,
      employeeEmail: _emailController.text,
      employeeContact: _contactController.text,
      workFrom: _workFromController.text,
      laptopBrand: _laptopBrandController.text,
      laptopModelNo: _laptopModelController.text,
      laptopSerialNo: _laptopSerialController.text,
      prevLaptopModelNo: _prevLaptopModelController.text,
      configuration: _configController.text,
      computerHostName: _hostNameController.text,
      headphoneSerialNo: _headphoneSNController.text,
      mouseSerialNo: _mouseSNController.text,
      keyboardSerialNo: _keyboardSNController.text,
      chargerSerialNo: _chargerSNController.text,
      screenSerialNo: _screenSerialController.text,
      screenCompany: _screenCompanyController.text,
      wifiMacAddress: _wifiMacController.text,
      dataCardNo: _dataCardController.text,
      deskNo: _deskNoController.text,
      laptopIssueDate: _laptopIssueDate,
      laptopExpiryDate: _laptopExpiryDate,
      softwareInstalled: _softwareController.text,
      softwareExpiryDate: _softwareExpiryDate,
      softwareRenewalDate: _softwareRenewalDate,
      softwareSerialNo: _softwareSNController.text,
      officeLocation: _officeLocationController.text,
      assetStatus: _assetStatus,
      purchaseOrRent: _assetStatus,
      remark: _remarkController.text,
      companyAssetName: _companyAssetNameController.text,
      hdfcItemIdName: _hdfcItemIdController.text,
      assetNumber: _assetNumberController.text,
      assetIssueDate: _assetIssueDate,
      assetExpiryDate: _assetExpiryDate,
      createdAt: widget.record?.createdAt ?? DateTime.now(),
      completedAt: widget.record == null ? DateTime.now() : widget.record?.completedAt,
      managedByName: widget.record?.managedByName ?? '',
    );

    await PdfService.generateAndDownloadPdf(asset);
  }

  Future<void> _selectDate(BuildContext context, String field) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppTheme.primaryColor,
              primary: AppTheme.primaryColor,
              surface: Theme.of(context).cardColor,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        switch (field) {
          case 'laptopIssue': _laptopIssueDate = picked; break;
          case 'laptopExpiry': _laptopExpiryDate = picked; break;
          case 'softwareExpiry': _softwareExpiryDate = picked; break;
          case 'softwareRenewal': _softwareRenewalDate = picked; break;
          case 'assetIssue': _assetIssueDate = picked; break;
          case 'assetExpiry': _assetExpiryDate = picked; break;
        }
      });
    }
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryColor, size: 28),
          const SizedBox(width: 12),
          Text(title, style: theme.textTheme.titleLarge?.copyWith(letterSpacing: 0.5, fontSize: 18)),
          const SizedBox(width: 12),
          Expanded(child: Container(height: 1, color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.1))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = theme.textTheme.titleLarge?.color ?? Colors.black87;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(widget.record == null ? 'Add New Asset Record' : 'Edit Asset Record'),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 20), onPressed: () => Navigator.pop(context)),
      ),
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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildSectionHeader('Employee Information', Icons.person_rounded),
                    CustomTextField(label: 'Company ID Number', hint: 'e.g. EMP-12345', icon: Icons.fingerprint_rounded, controller: _companyIdController, validator: (v) => v!.isEmpty ? 'ID required' : null),
                    CustomTextField(label: 'Employee Name', hint: 'e.g. Sujit Girame', icon: Icons.badge_outlined, controller: _nameController, validator: (v) => v!.isEmpty ? 'Name required' : null),
                    CustomTextField(label: 'Employee Department', hint: 'e.g. IT, Sales, HR', icon: Icons.business_outlined, controller: _deptController),
                    CustomTextField(label: 'Employee Email Id', hint: 'email@company.com', icon: Icons.email_outlined, controller: _emailController, keyboardType: TextInputType.emailAddress),
                    CustomTextField(label: 'Employee Contact Details', hint: '+91 9XXXX XXXXX', icon: Icons.phone_outlined, controller: _contactController, keyboardType: TextInputType.phone),
                    Row(
                      children: [
                        Expanded(child: CustomTextField(label: 'Work From', hint: 'Home / Office', icon: Icons.work_outline, controller: _workFromController)),
                        const SizedBox(width: 16),
                        Expanded(child: CustomTextField(label: 'Office Location', hint: 'Mumbai / Pune', icon: Icons.location_on_outlined, controller: _officeLocationController)),
                      ],
                    ),

                    _buildSectionHeader('Asset Status & Ownership', Icons.admin_panel_settings_rounded),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 4, bottom: 8), 
                            child: Text(
                              'Asset Type', 
                              style: TextStyle(
                                fontWeight: FontWeight.w600, 
                                color: textColor.withValues(alpha: 0.5),
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: isDark ? AppTheme.cardColor.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.03), 
                              borderRadius: BorderRadius.circular(16), 
                              border: Border.all(color: textColor.withValues(alpha: 0.05)),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _assetStatus,
                                dropdownColor: theme.cardColor,
                                isExpanded: true,
                                icon: const Icon(Icons.keyboard_arrow_down, color: AppTheme.primaryColor),
                                items: ['Purchased', 'Rent'].map((String value) => DropdownMenuItem<String>(
                                  value: value, 
                                  child: Text(
                                    value, 
                                    style: TextStyle(color: textColor),
                                  ),
                                )).toList(),
                                onChanged: (val) => setState(() => _assetStatus = val!),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    _buildSectionHeader('Laptop Details', Icons.laptop_rounded),
                    Row(
                      children: [
                        Expanded(child: CustomTextField(label: 'Laptop Brand', hint: 'Dell / HP', icon: Icons.copyright_rounded, controller: _laptopBrandController)),
                        const SizedBox(width: 16),
                        Expanded(child: CustomTextField(label: 'Laptop Model No', hint: 'Latitude 5420', icon: Icons.devices_other_outlined, controller: _laptopModelController)),
                      ],
                    ),
                    CustomTextField(label: 'Laptop Serial Number', hint: 'SN-ABC123XYZ', icon: Icons.pin_outlined, controller: _laptopSerialController),
                    CustomTextField(label: 'Previous Laptop Model', hint: 'Mention if upgraded', icon: Icons.history_outlined, controller: _prevLaptopModelController),
                    CustomTextField(label: 'Technical Configuration', hint: 'e.g. 16GB RAM, 512GB SSD, i7', icon: Icons.settings_input_component_outlined, controller: _configController),
                    CustomTextField(label: 'Computer / Host Name', hint: 'e.g. MUM-IT-LAP-01', icon: Icons.computer_outlined, controller: _hostNameController),
                    Row(
                      children: [
                        Expanded(child: CustomTextField(label: 'Issue Date', hint: _laptopIssueDate == null ? 'Select Date' : DateFormat('MMM dd, yyyy').format(_laptopIssueDate!), icon: Icons.calendar_today_outlined, readOnly: true, onTap: () => _selectDate(context, 'laptopIssue'))),
                        const SizedBox(width: 16),
                        Expanded(child: CustomTextField(label: 'Expiry Date', hint: _laptopExpiryDate == null ? 'Select Date' : DateFormat('MMM dd, yyyy').format(_laptopExpiryDate!), icon: Icons.calendar_today_outlined, readOnly: true, onTap: () => _selectDate(context, 'laptopExpiry'))),
                      ],
                    ),

                    _buildSectionHeader('Secondary Screen Details', Icons.monitor_rounded),
                    CustomTextField(label: 'Screen Company', hint: 'Dell / Samsung', icon: Icons.corporate_fare_outlined, controller: _screenCompanyController),
                    CustomTextField(label: 'Screen Serial Number', hint: 'SN-SCR123XYZ', icon: Icons.pin_outlined, controller: _screenSerialController),

                    _buildSectionHeader('Hardware Peripherals', Icons.mouse_rounded),
                    CustomTextField(label: 'Headphone Serial No', hint: 'SN123456789', icon: Icons.headphones_outlined, controller: _headphoneSNController),
                    CustomTextField(label: 'Charger Serial No', hint: 'SN123456789', icon: Icons.power_outlined, controller: _chargerSNController),
                    Row(
                      children: [
                        Expanded(child: CustomTextField(label: 'Mouse Serial No', hint: 'SN123456', icon: Icons.mouse_outlined, controller: _mouseSNController)),
                        const SizedBox(width: 16),
                        Expanded(child: CustomTextField(label: 'Keyboard Serial No', hint: 'SN123456', icon: Icons.keyboard_outlined, controller: _keyboardSNController)),
                      ],
                    ),

                    _buildSectionHeader('Connectivity & Desk', Icons.wifi_rounded),
                    CustomTextField(label: 'WiFi MAC Address', hint: 'AA:BB:CC:DD:EE:FF', icon: Icons.lan_outlined, controller: _wifiMacController),
                    Row(
                      children: [
                        Expanded(child: CustomTextField(label: 'Data Card No', hint: 'Jio / Airtel No', icon: Icons.code_rounded, controller: _dataCardController)),
                        const SizedBox(width: 16),
                        Expanded(child: CustomTextField(label: 'Desk No', hint: 'e.g. D-12', icon: Icons.desk_outlined, controller: _deskNoController)),
                      ],
                    ),

                    _buildSectionHeader('Software Details', Icons.apps_rounded),
                    CustomTextField(label: 'Software Installed', hint: 'e.g. Office 365, Adobe', icon: Icons.code_rounded, controller: _softwareController),
                    CustomTextField(label: 'License Key / SN', hint: 'XXXX-XXXX-XXXX', icon: Icons.vpn_key_outlined, controller: _softwareSNController),
                    Row(
                      children: [
                        Expanded(child: CustomTextField(label: 'Expiry Date', hint: _softwareExpiryDate == null ? 'Select Date' : DateFormat('MMM dd, yyyy').format(_softwareExpiryDate!), icon: Icons.event_available_outlined, readOnly: true, onTap: () => _selectDate(context, 'softwareExpiry'))),
                        const SizedBox(width: 16),
                        Expanded(child: CustomTextField(label: 'Renewal Date', hint: _softwareRenewalDate == null ? 'Select Date' : DateFormat('MMM dd, yyyy').format(_softwareRenewalDate!), icon: Icons.update_rounded, readOnly: true, onTap: () => _selectDate(context, 'softwareRenewal'))),
                      ],
                    ),

                    _buildSectionHeader('Corporate Asset Info', Icons.inventory_2_rounded),
                    CustomTextField(label: 'Company Name', hint: 'e.g. ABC Pvt Ltd', icon: Icons.corporate_fare_outlined, controller: _companyNameController),
                    CustomTextField(label: 'Asset Name', hint: 'Official Title', icon: Icons.label_important_outline, controller: _companyAssetNameController),
                    CustomTextField(label: 'HDFC ITEM ID', hint: 'Internal ID', icon: Icons.fingerprint_outlined, controller: _hdfcItemIdController),
                    CustomTextField(label: 'Asset Number', hint: 'External tag', icon: Icons.numbers_outlined, controller: _assetNumberController),
                    Row(
                      children: [
                        Expanded(child: CustomTextField(label: 'Issue Date', hint: _assetIssueDate == null ? 'Select Date' : DateFormat('MMM dd, yyyy').format(_assetIssueDate!), icon: Icons.calendar_month_outlined, readOnly: true, onTap: () => _selectDate(context, 'assetIssue'))),
                        const SizedBox(width: 16),
                        Expanded(child: CustomTextField(label: 'Expiry Date', hint: _assetExpiryDate == null ? 'Select Date' : DateFormat('MMM dd, yyyy').format(_assetExpiryDate!), icon: Icons.calendar_month_outlined, readOnly: true, onTap: () => _selectDate(context, 'assetExpiry'))),
                      ],
                    ),

                    _buildSectionHeader('Other Remarks', Icons.notes_rounded),
                    CustomTextField(label: 'Remark', hint: 'Notes...', icon: Icons.comment_bank_outlined, controller: _remarkController),

                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [AppTheme.primaryColor, AppTheme.secondaryColor]), 
                        borderRadius: BorderRadius.circular(16), 
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryColor.withValues(alpha: 0.3), 
                            blurRadius: 10, 
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveAsset,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent, 
                          shadowColor: Colors.transparent, 
                          padding: const EdgeInsets.symmetric(vertical: 18),
                        ),
                        child: _isLoading 
                          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : Text(
                              widget.record == null ? 'Save Asset Record' : 'Update Asset Record', 
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1, color: Colors.white),
                            ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.3), width: 1.5),
                      ),
                      child: TextButton.icon(
                        onPressed: _downloadPdf,
                        icon: const Icon(Icons.picture_as_pdf_rounded, color: AppTheme.primaryColor),
                        label: const Text(
                          'Download PDF',
                          style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
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
