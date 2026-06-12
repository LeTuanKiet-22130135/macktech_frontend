import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'user_api.g.dart';

@RestApi()
abstract class UserApi {
  factory UserApi(Dio dio, {String baseUrl}) = _UserApi;

  @GET('/api/user/profile')
  Future<dynamic> fetchProfile();

  @POST('/api/user/profile')
  Future<void> updateProfile(
    @Body() Map<String, dynamic> body,
  );

  @PUT('/api/user/avatar')
  Future<void> updateAvatar(
    @Body() Map<String, dynamic> body,
  );

  @PUT('/api/user/password')
  Future<void> changePassword(
    @Body() Map<String, dynamic> body,
  );
}
