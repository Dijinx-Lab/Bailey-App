class PickFingerArgs {
  final List<bool> handsScanned;
  final String currentHand;
  final String mode;

  PickFingerArgs(
      {required this.handsScanned,
      required this.currentHand,
      required this.mode});
}
