import 'package:mentoring_get_cep/src/model/cep_model.dart';
import 'package:retrofit/retrofit.dart';
import 'package:dio/dio.dart';

part 'rest_client.g.dart';

@RestApi(baseUrl: 'http://viacep.com.br/')
abstract class RestClient {
  factory RestClient(Dio dio, {String baseUrl}) = _RestClient;

  @GET('/ws/{cep}/json/')
  Future<CepModel> getCep(@Path('cep') String cep);
}
