import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:myportofolio_mobile/models/education.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';

void main() {
  const baseUrl = 'https://example.test';

  group('Education JSON serialization', () {
    test('fromJson memetakan snake_case dan nilai default saat field opsional null', () {
      final edu = Education.fromJson({
        'id': 7,
        'school': 'Universitas Indonesia',
        'degree': 'S1 Sistem Informasi',
        'start_year': '2025',
        'end_year': null,
        'description': 'Fasilkom UI',
        'logo': null,
        'star_count': 3,
        'is_starred': true,
        'starred_by_names': 'nami',
      });

      expect(edu.id, 7);
      expect(edu.school, 'Universitas Indonesia');
      expect(edu.startYear, '2025');
      expect(edu.endYear, '');
      expect(edu.logo, '');
      expect(edu.starCount, 3);
      expect(edu.isStarred, isTrue);
      expect(edu.starredByNames, 'nami');
    });

    test('toJson menggunakan snake_case dan mengecualikan field read-only', () {
      const edu = Education(
        id: 99,
        school: 'Universitas Indonesia',
        degree: 'S1 Sistem Informasi',
        startYear: '2025',
        endYear: '2029',
        description: 'Fasilkom UI',
        logo: '/static/img/ui.png',
        starCount: 10,
        isStarred: true,
        starredByNames: 'admin',
      );

      final json = edu.toJson();

      expect(json['school'], 'Universitas Indonesia');
      expect(json['degree'], 'S1 Sistem Informasi');
      expect(json['start_year'], '2025');
      expect(json['end_year'], '2029');
      expect(json['description'], 'Fasilkom UI');
      expect(json['logo'], '/static/img/ui.png');
      expect(json.containsKey('id'), isFalse);
      expect(json.containsKey('star_count'), isFalse);
      expect(json.containsKey('is_starred'), isFalse);
      expect(json.containsKey('starred_by_names'), isFalse);
    });
  });

  group('ApiClient Education endpoints', () {
    test(
      'getEducations mengembalikan daftar Education pada HTTP 200',
      () async {
        final mockClient = MockClient((request) async {
          expect(request.method, 'GET');
          expect(request.url.toString(), '$baseUrl/api/v1/education/');
          expect(request.headers['Accept'], 'application/json');

          return http.Response(
            jsonEncode([
              {
                'id': 1,
                'school': 'Universitas Indonesia',
                'degree': 'S1 Sistem Informasi',
                'start_year': '2025',
                'end_year': '',
                'description': 'Fasilkom UI',
                'logo': '',
                'star_count': 2,
                'is_starred': false,
                'starred_by_names': 'user1, user2',
              },
            ]),
            200,
          );
        });

        final api = ApiClient(client: mockClient, baseUrl: baseUrl);
        final educations = await api.getEducations();

        expect(educations, hasLength(1));
        expect(educations.first.id, 1);
        expect(educations.first.school, 'Universitas Indonesia');
        expect(educations.first.starCount, 2);
      },
    );

    test(
      'createEducation mengirim header Token dan mengembalikan entri baru',
      () async {
        final mockClient = MockClient((request) async {
          expect(request.method, 'POST');
          expect(request.url.toString(), '$baseUrl/api/v1/education/');
          expect(request.headers['Authorization'], 'Token secret-token');
          expect(request.headers['Content-Type'], contains('application/json'));

          final body = jsonDecode(request.body) as Map<String, dynamic>;
          expect(body.containsKey('id'), isFalse);
          expect(body['school'], 'SMAN 1 Cibinong');
          expect(body['start_year'], '2022');

          return http.Response(
            jsonEncode({
              ...body,
              'id': 42,
              'star_count': 0,
              'is_starred': false,
              'starred_by_names': '',
            }),
            201,
          );
        });

        final api = ApiClient(client: mockClient, baseUrl: baseUrl);
        final created = await api.createEducation(
          const Education(
            school: 'SMAN 1 Cibinong',
            degree: 'MIPA',
            startYear: '2022',
            endYear: '2025',
            description: 'Lulus dengan nilai 94.05',
          ),
          token: 'secret-token',
        );

        expect(created.id, 42);
        expect(created.school, 'SMAN 1 Cibinong');
      },
    );

    test('updateEducation mengirim PATCH dengan Token dan mengembalikan entri terbarui', () async {
      final mockClient = MockClient((request) async {
        expect(request.method, 'PATCH');
        expect(request.url.toString(), '$baseUrl/api/v1/education/42/');
        expect(request.headers['Authorization'], 'Token secret-token');

        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['degree'], 'S1 Sistem Informasi (Updated)');

        return http.Response(
          jsonEncode({
            ...body,
            'id': 42,
            'star_count': 1,
            'is_starred': true,
            'starred_by_names': 'nami',
          }),
          200,
        );
      });

      final api = ApiClient(client: mockClient, baseUrl: baseUrl);
      final updated = await api.updateEducation(
        42,
        const Education(
          id: 42,
          school: 'Universitas Indonesia',
          degree: 'S1 Sistem Informasi (Updated)',
          startYear: '2025',
          description: 'Aktif di RISTEK',
        ),
        token: 'secret-token',
      );

      expect(updated.id, 42);
      expect(updated.degree, 'S1 Sistem Informasi (Updated)');
    });

    test(
      'deleteEducation mengirim DELETE dengan Token dan lulus pada HTTP 204',
      () async {
        final mockClient = MockClient((request) async {
          expect(request.method, 'DELETE');
          expect(request.url.toString(), '$baseUrl/api/v1/education/42/');
          expect(request.headers['Authorization'], 'Token secret-token');
          return http.Response('', 204);
        });

        final api = ApiClient(client: mockClient, baseUrl: baseUrl);
        await expectLater(
          api.deleteEducation(42, token: 'secret-token'),
          completes,
        );
      },
    );

    test('melempar ApiException(401) ketika token tidak valid', () async {
      final mockClient = MockClient((_) async {
        return http.Response('{"detail": "Invalid token."}', 401);
      });

      final api = ApiClient(client: mockClient, baseUrl: baseUrl);

      await expectLater(
        api.createEducation(
          const Education(
            school: 'UI',
            degree: 'SI',
            startYear: '2025',
            description: 'Test',
          ),
          token: 'expired-token',
        ),
        throwsA(
          isA<ApiException>()
              .having((e) => e.statusCode, 'statusCode', 401)
              .having((e) => e.message, 'message', contains('Invalid token')),
        ),
      );
    });
  });

  group('AuthState lifecycle', () {
    test('login menyimpan token dan logout tetap membersihkan token meski server 401', () async {
      final mockClient = MockClient((request) async {
        if (request.url.path == '/api/v1/auth/token/') {
          return http.Response(jsonEncode({'token': 'abc123'}), 200);
        }
        if (request.url.path == '/api/v1/auth/logout/') {
          return http.Response('{"detail": "Invalid token."}', 401);
        }
        return http.Response('Not found', 404);
      });

      final api = ApiClient(client: mockClient, baseUrl: baseUrl);
      final authState = AuthState(api);

      expect(authState.isLoggedIn, isFalse);

      await authState.login('nami', 'password123');
      expect(authState.isLoggedIn, isTrue);
      expect(authState.token, 'abc123');

      await authState.logout();
      expect(authState.isLoggedIn, isFalse);
      expect(authState.token, isNull);
    });
  });
}
