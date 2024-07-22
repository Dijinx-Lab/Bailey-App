class ScanPrintsArgs {
  final bool singleScan;
  final int? initIndex;
  final List<String?> scans;

  ScanPrintsArgs({
    required this.scans,
    this.singleScan = false,
    this.initIndex,
  });
}
