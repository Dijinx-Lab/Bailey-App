class BaseResponse<T> {
  final int? status;
  final T? snapshot;
  final String? error;

  BaseResponse(
    this.status,
    this.snapshot,
    this.error,
  );
}
