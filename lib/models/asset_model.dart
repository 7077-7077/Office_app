class AssetRecord {
  final String? id;
  final String? userId; // Link to account owner
  final String companyId; 
  final String companyName;
  final String employeeName;
  final String employeeDepartment;
  final String employeeEmail;
  final String employeeContact;
  final String workFrom;
  final String laptopBrand;
  final String laptopModelNo;
  final String laptopSerialNo; 
  final String prevLaptopModelNo;
  final String configuration; 
  final String computerHostName; 
  final String headphoneSerialNo;
  final String mouseSerialNo;
  final String keyboardSerialNo;
  final String chargerSerialNo;
  final String screenSerialNo; 
  final String screenCompany; 
  final String wifiMacAddress;
  final String dataCardNo;
  final String deskNo;
  final DateTime? laptopIssueDate;
  final DateTime? laptopExpiryDate;
  final String softwareInstalled;
  final DateTime? softwareExpiryDate;
  final DateTime? softwareRenewalDate; 
  final String softwareSerialNo;
  final String officeLocation;
  final String assetStatus; 
  final String remark;
  final String companyAssetName;
  final String hdfcItemIdName;
  final String assetNumber;
  final DateTime? assetIssueDate;
  final DateTime? assetExpiryDate;
  final DateTime? createdAt; 
  final DateTime? completedAt; 
  final String purchaseOrRent;
  final String managedByName;

  AssetRecord({
    this.id,
    this.userId,
    required this.companyId,
    required this.companyName,
    required this.employeeName,
    required this.employeeDepartment,
    required this.employeeEmail,
    required this.employeeContact,
    required this.workFrom,
    required this.laptopBrand,
    required this.laptopModelNo,
    required this.laptopSerialNo,
    required this.prevLaptopModelNo,
    required this.configuration,
    required this.computerHostName,
    required this.headphoneSerialNo,
    required this.mouseSerialNo,
    required this.keyboardSerialNo,
    required this.chargerSerialNo,
    required this.screenSerialNo,
    required this.screenCompany,
    required this.wifiMacAddress,
    required this.dataCardNo,
    required this.deskNo,
    this.laptopIssueDate,
    this.laptopExpiryDate,
    required this.softwareInstalled,
    this.softwareExpiryDate,
    this.softwareRenewalDate,
    required this.softwareSerialNo,
    required this.officeLocation,
    required this.assetStatus,
    required this.remark,
    required this.companyAssetName,
    required this.hdfcItemIdName,
    required this.assetNumber,
    this.assetIssueDate,
    this.assetExpiryDate,
    this.createdAt,
    this.completedAt,
    required this.purchaseOrRent,
    this.managedByName = '',
  });

  factory AssetRecord.fromMap(Map<String, dynamic> map, [String? docId]) {
    final normalizedMap = map.map((key, value) => MapEntry(key.toLowerCase().trim(), value));

    dynamic getVal(List<String> keys) {
      for (var k in keys) {
        final normalizedK = k.toLowerCase().trim();
        if (normalizedMap.containsKey(normalizedK)) return normalizedMap[normalizedK];
      }
      return null;
    }

    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      if (value is DateTime) return value;
      if (value is String) return DateTime.tryParse(value);
      if (value.runtimeType.toString().contains('Timestamp')) return (value as dynamic).toDate();
      return null;
    }

    return AssetRecord(
      id: docId ?? getVal(['id', 'ID', 'no', 's.no', 'sr.no', 'serial'])?.toString(),
      userId: getVal(['userId', 'userid', 'ownerid', 'user_id'])?.toString(),
      companyId: getVal(['companyId', 'employee id', 'company id', 'id', 'emp id', 'employeeid', 'emp_id', 'staff id', 'worker id'])?.toString() ?? 'N/A',
      companyName: getVal(['companyName', 'company name', 'vendor', 'company_name', 'company', 'organization', 'employer'])?.toString() ?? '',
      employeeName: getVal(['employeeName', 'employee name', 'name', 'employeename', 'employee_name', 'full name', 'fullname', 'user name', 'staff name'])?.toString() ?? 'Unknown',
      employeeDepartment: getVal(['employeeDepartment', 'department', 'employee department', 'dept', 'employee_department', 'division', 'unit', 'team'])?.toString() ?? '',
      employeeEmail: getVal(['employeeEmail', 'email', 'employee email', 'email id', 'employee_email', 'email_id', 'mail'])?.toString() ?? '',
      employeeContact: getVal(['employeeContact', 'contact', 'phone', 'mobile', 'contact number', 'phone number', 'employee_contact', 'telephone'])?.toString() ?? '',
      workFrom: getVal(['workFrom', 'work from', 'location type', 'wfh/wfo', 'work_from', 'mode', 'working mode'])?.toString() ?? 'WFO',
      laptopBrand: getVal(['laptopBrand', 'laptop brand', 'brand', 'make', 'laptop_brand', 'manufacturer'])?.toString() ?? '',
      laptopModelNo: getVal(['laptopModelNo', 'laptop model', 'model', 'model no', 'laptop_model_no', 'laptop_model', 'machine model'])?.toString() ?? '',
      laptopSerialNo: getVal(['laptopSerialNo', 'serial no', 'serial number', 'sn', 'service tag', 'laptop_serial_no', 'serial_no', 'serial_number', 'laptop serial no.', 's/n', 's.n.', 'asset serial'])?.toString() ?? '',
      prevLaptopModelNo: getVal(['prevLaptopModelNo', 'previous laptop', 'old laptop', 'prev_laptop_model_no', 'prev_laptop', 'old model'])?.toString() ?? '',
      configuration: getVal(['configuration', 'config', 'ram/ssd', 'specs', 'technical configuration', 'configuration_specs', 'processor', 'ram', 'system config'])?.toString() ?? '',
      computerHostName: getVal(['computerHostName', 'host name', 'hostname', 'computer name', 'pc name', 'asset name'])?.toString() ?? '',
      headphoneSerialNo: getVal(['headphoneSerialNo', 'headphone sn', 'headset sn', 'headphone serial', 'headphone s/n', 'headphone s.n.'])?.toString() ?? '',
      mouseSerialNo: getVal(['mouseSerialNo', 'mouse sn', 'mouse serial', 'mouse serial no.', 'mouse s/n', 'mouse s.n.'])?.toString() ?? '',
      keyboardSerialNo: getVal(['keyboardSerialNo', 'keyboard sn', 'keyboard serial', 'keyboard serial no.', 'keyboard s/n', 'keyboard s.n.'])?.toString() ?? '',
      chargerSerialNo: getVal(['chargerSerialNo', 'charger sn', 'charger serial', 'charger no', 'charger_serial_no', 'charger serial no.', 'charger s/n', 'charger s.n.', 'adapter sn', 'adapter serial'])?.toString() ?? '',
      screenSerialNo: getVal(['screenSerialNo', 'screen sn', 'monitor sn', 'screen serial', 'monitor serial', 'screen s/n', 'monitor s/n'])?.toString() ?? '',
      screenCompany: getVal(['screenCompany', 'screen brand', 'monitor brand', 'monitor manufacturer', 'display brand'])?.toString() ?? '',
      wifiMacAddress: getVal(['wifiMacAddress', 'wifi mac', 'mac address', 'wifi physical address'])?.toString() ?? '',
      dataCardNo: getVal(['dataCardNo', 'data card', 'dongle', 'datacard no'])?.toString() ?? '',
      deskNo: getVal(['deskNo', 'desk number', 'seat no', 'cubicle no'])?.toString() ?? '',
      laptopIssueDate: parseDate(getVal(['laptopIssueDate', 'issue date', 'laptop issue', 'issued on'])),
      laptopExpiryDate: parseDate(getVal(['laptopExpiryDate', 'expiry date', 'laptop expiry', 'valid till'])),
      softwareInstalled: getVal(['softwareInstalled', 'software', 'apps', 'applications'])?.toString() ?? '',
      softwareExpiryDate: parseDate(getVal(['softwareExpiryDate', 'software expiry', 'license expiry'])),
      softwareRenewalDate: parseDate(getVal(['softwareRenewalDate', 'renewal date', 'license renewal'])),
      softwareSerialNo: getVal(['softwareSerialNo', 'software sn', 'license key', 'product key', 'software serial'])?.toString() ?? '',
      officeLocation: getVal(['officeLocation', 'office', 'location', 'branch', 'office_location', 'laptop location', 'site', 'work location'])?.toString() ?? '',
      assetStatus: getVal(['assetStatus', 'status', 'purchased/rent', 'rent/purchased', 'asset_status', 'availability'])?.toString() ?? 'Purchased',
      remark: getVal(['remark', 'notes', 'comments', 'remarks', 'other info'])?.toString() ?? '',
      companyAssetName: getVal(['companyAssetName', 'asset name', 'item name', 'component name'])?.toString() ?? '',
      hdfcItemIdName: getVal(['hdfcItemIdName', 'hdfc id', 'item id', 'internal id'])?.toString() ?? '',
      assetNumber: getVal(['assetNumber', 'asset tag', 'tag number', 'asset no'])?.toString() ?? '',
      assetIssueDate: parseDate(getVal(['assetIssueDate', 'asset issue', 'date', 'allocation date', 'assigned on'])),
      assetExpiryDate: parseDate(getVal(['assetExpiryDate', 'asset expiry'])),
      createdAt: parseDate(getVal(['createdAt', 'created at'])) ?? DateTime.now(),
      completedAt: parseDate(getVal(['completedAt', 'completed at'])),
      purchaseOrRent: getVal(['purchaseOrRent', 'purchase or rent', 'purchased/rent', 'rent/purchased', 'p/r'])?.toString() ?? 'Purchased',
      managedByName: getVal(['managedByName', 'managed by', 'manager', 'added by', 'managed_by', 'manager_name', 'added_by'])?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'companyId': companyId,
      'companyName': companyName,
      'employeeName': employeeName,
      'employeeDepartment': employeeDepartment,
      'employeeEmail': employeeEmail,
      'employeeContact': employeeContact,
      'workFrom': workFrom,
      'laptopBrand': laptopBrand,
      'laptopModelNo': laptopModelNo,
      'laptopSerialNo': laptopSerialNo,
      'prevLaptopModelNo': prevLaptopModelNo,
      'configuration': configuration,
      'computerHostName': computerHostName,
      'headphoneSerialNo': headphoneSerialNo,
      'mouseSerialNo': mouseSerialNo,
      'keyboardSerialNo': keyboardSerialNo,
      'chargerSerialNo': chargerSerialNo,
      'screenSerialNo': screenSerialNo,
      'screenCompany': screenCompany,
      'wifiMacAddress': wifiMacAddress,
      'dataCardNo': dataCardNo,
      'deskNo': deskNo,
      'laptopIssueDate': laptopIssueDate,
      'laptopExpiryDate': laptopExpiryDate,
      'softwareInstalled': softwareInstalled,
      'softwareExpiryDate': softwareExpiryDate,
      'softwareRenewalDate': softwareRenewalDate,
      'softwareSerialNo': softwareSerialNo,
      'officeLocation': officeLocation,
      'assetStatus': assetStatus,
      'remark': remark,
      'companyAssetName': companyAssetName,
      'hdfcItemIdName': hdfcItemIdName,
      'assetNumber': assetNumber,
      'assetIssueDate': assetIssueDate,
      'assetExpiryDate': assetExpiryDate,
      'createdAt': createdAt ?? DateTime.now(),
      'completedAt': completedAt,
      'purchaseOrRent': purchaseOrRent,
      'managedByName': managedByName,
    };
  }
}
