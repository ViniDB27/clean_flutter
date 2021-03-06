import 'package:faker/faker.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'package:clean_flutter/domain/helpers/helpers.dart';
import 'package:clean_flutter/domain/usecases/usecases.dart';

import 'package:clean_flutter/data/http/http.dart';
import 'package:clean_flutter/data/usecases/usecases.dart';

class HttpClientSpy extends Mock implements HttpClient {}

void main() {
  RemoteAuthentication sut;

  AuthenticationParams params;
  HttpClientSpy httpClient;
  String url;

  setUp(() {
    httpClient = HttpClientSpy();
    url = faker.internet.httpUrl();
    sut = RemoteAuthentication(httpClient: httpClient, url: url);
    params = AuthenticationParams(
      email: faker.internet.email(),
      password: faker.internet.password(),
    );
  });

  test("Should call HttpClient with correct values", () async {
    await sut.auth(params);

    verify(httpClient.request(
      url: url,
      method: "post",
      body: {
        "email": params.email,
        "password": params.password,
      },
    ));
  });

  test("Should throw UnexpectedError if HttpClient returns 400", () async {
    when(httpClient.request(
      url: anyNamed('url'),
      method: anyNamed('method'),
      body: anyNamed('body'),
    )).thenThrow(HttpErrors.badRequest);

    final future = sut.auth(params);

    expect(future, throwsA(DomainErrors.unexpected));
  });

  test("Should throw UnexpectedError if HttpClient returns 404", () async {
    when(httpClient.request(
      url: anyNamed('url'),
      method: anyNamed('method'),
      body: anyNamed('body'),
    )).thenThrow(HttpErrors.notFound);

    final future = sut.auth(params);

    expect(future, throwsA(DomainErrors.unexpected));
  });
 
  test("Should throw UnexpectedError if HttpClient returns 500", () async {
    when(httpClient.request(
      url: anyNamed('url'),
      method: anyNamed('method'),
      body: anyNamed('body'),
    )).thenThrow(HttpErrors.serverError);

    final future = sut.auth(params);

    expect(future, throwsA(DomainErrors.unexpected));
  });

  test("Should throw InvalidCredentialsError if HttpClient returns 401", () async {
    when(httpClient.request(
      url: anyNamed('url'),
      method: anyNamed('method'),
      body: anyNamed('body'),
    )).thenThrow(HttpErrors.unauthorized);

    final future = sut.auth(params);

    expect(future, throwsA(DomainErrors.invalidCredentials));
  });
}
