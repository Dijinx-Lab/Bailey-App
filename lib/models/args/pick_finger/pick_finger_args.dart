class PickFingerArgs {
  final bool previousHandScanned;
  final String currentHand;
  final String mode;

  PickFingerArgs(
      {required this.previousHandScanned,
      required this.currentHand,
      required this.mode});
}
