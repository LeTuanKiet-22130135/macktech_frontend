import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'auth_api.g.dart';

@RestApi()
abstract class AuthApi {
  factory AuthApi(Dio dio, {String baseUrl}) = _AuthApi;

  @POST('/api/auth/login/user')
  Future<dynamic> loginUser(
    @Body() Map<String, dynamic> body,
  );

  @POST('/api/auth/register/user')
  Future<void> registerUser(
    @Body() Map<String, dynamic> body,
  );

  @POST('/api/auth/login/admin')
  Future<dynamic> adminLogin(
    @Body() Map<String, dynamic> body,
  );

  @GET('/api/auth/check-phone')
  Future<dynamic> checkPhone(
    @Query('phone') String phone,
  );

  @POST('/api/auth/password-recovery/send-otp')
  Future<void> sendOtp(
    @Body() Map<String, dynamic> body,
  );

  @POST('/api/auth/password-recovery/verify-otp')
  Future<dynamic> verifyOtp(
    @Body() Map<String, dynamic> body,
  );

  @POST('/api/auth/password-recovery/reset-password')
  Future<void> resetPassword(
    @Body() Map<String, dynamic> body,
  );

  @DELETE('/api/auth/account')
  Future<void> deleteAccount(
    @Body() Map<String, dynamic> body,
  );
}
