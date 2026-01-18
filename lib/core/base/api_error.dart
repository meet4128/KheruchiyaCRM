class APIError {
  int code = 0;
  String? message;
  dynamic exception;

  APIError({required this.code, this.message});
}
