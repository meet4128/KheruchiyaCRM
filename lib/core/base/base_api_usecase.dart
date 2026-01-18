import 'package:dartz/dartz.dart';

import 'api_error.dart';

mixin BaseApiUseCase<Response, Params> {
  Future<Either<Response, APIError>> call(Params params);
}
