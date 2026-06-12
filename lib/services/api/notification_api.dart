import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'notification_api.g.dart';

@RestApi()
abstract class NotificationApi {
  factory NotificationApi(Dio dio, {String baseUrl}) = _NotificationApi;

  @POST('/api/notifications/token')
  Future<void> registerToken(
    @Body() Map<String, dynamic> body,
  );

  @GET('/api/notifications/enabled')
  Future<dynamic> isEnabled();

  @POST('/api/notifications/send')
  Future<void> sendNotification(
    @Body() Map<String, dynamic> body,
  );

  @POST('/api/notifications/enabled')
  Future<void> setPreferences(
    @Body() Map<String, dynamic> body,
  );
}
