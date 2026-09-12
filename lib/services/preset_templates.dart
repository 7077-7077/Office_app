import 'dart:math';

/// Asset preset template definition
class AssetPreset {
  final String title;
  final String iconName;
  final String laptopBrand;
  final String laptopModelNo;
  final String configuration;
  final String purchaseOrRent;
  final String screenCompany;
  final String workFrom;
  final String remark;

  const AssetPreset({
    required this.title,
    required this.iconName,
    required this.laptopBrand,
    required this.laptopModelNo,
    required this.configuration,
    required this.purchaseOrRent,
    required this.screenCompany,
    required this.workFrom,
    required this.remark,
  });
}

class PresetService {
  static const List<AssetPreset> presets = [
    AssetPreset(
      title: 'Developer Kit',
      iconName: 'code',
      laptopBrand: 'Apple',
      laptopModelNo: 'MacBook Pro 16" M3 Max',
      configuration: '36GB RAM / 1TB SSD / Liquid Retina XDR',
      purchaseOrRent: 'Purchased',
      screenCompany: 'Dell 27" 4K',
      workFrom: 'Hybrid',
      remark: 'High-performance engineering machine',
    ),
    AssetPreset(
      title: 'Designer Setup',
      iconName: 'palette',
      laptopBrand: 'Apple',
      laptopModelNo: 'MacBook Pro 14" M3 Pro',
      configuration: '18GB RAM / 512GB SSD / M3 Pro GPU',
      purchaseOrRent: 'Purchased',
      screenCompany: 'LG UltraFine 27"',
      workFrom: 'Office',
      remark: 'Color-calibrated creative workstation',
    ),
    AssetPreset(
      title: 'Corporate Windows',
      iconName: 'laptop',
      laptopBrand: 'Dell',
      laptopModelNo: 'Latitude 7440',
      configuration: 'Intel i7-1365U / 16GB RAM / 512GB NVMe',
      purchaseOrRent: 'Purchased',
      screenCompany: 'Dell P2422H',
      workFrom: 'Office',
      remark: 'Standard enterprise business laptop',
    ),
    AssetPreset(
      title: 'Rental Unit',
      iconName: 'schedule',
      laptopBrand: 'Lenovo',
      laptopModelNo: 'ThinkPad T14 Gen 4',
      configuration: 'Intel i5-1345U / 16GB RAM / 256GB SSD',
      purchaseOrRent: 'Rent',
      screenCompany: 'Standard 24" Monitor',
      workFrom: 'Remote',
      remark: 'Temporary rental allocation',
    ),
  ];

  /// Auto-generate asset number tag (e.g. OFF-2026-8941)
  static String generateAssetNumber() {
    final year = DateTime.now().year;
    final randomNum = Random().nextInt(9000) + 1000;
    return 'OFF-$year-$randomNum';
  }

  /// Auto-generate hostname (e.g. HOST-DEV-981)
  static String generateHostName([String prefix = 'HOST']) {
    final randomNum = Random().nextInt(900) + 100;
    return '$prefix-$randomNum';
  }

  /// Auto-generate serial number (e.g. SN-84920481)
  static String generateSerialNo([String prefix = 'SN']) {
    final randomNum = Random().nextInt(89999999) + 10000000;
    return '$prefix-$randomNum';
  }
}
