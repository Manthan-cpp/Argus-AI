import 'package:flutter_test/flutter_test.dart';
import 'package:argus_flutter/data/mock/mock_argus_repository.dart';

void main() {
  group('Auth Sign-In & Sign-Up Validation Tests', () {
    late MockArgusRepository repo;

    setUp(() {
      repo = MockArgusRepository();
    });

    test('1. Sign-up creates account and subsequent login succeeds with exact credentials', () async {
      final user = await repo.signUp('Marcus Cole', 'alphaSecure789');
      expect(user.fullName, equals('Marcus Cole'));

      final loggedIn = await repo.login('Marcus Cole', 'alphaSecure789');
      expect(loggedIn.fullName, equals('Marcus Cole'));
    });

    test('2. Sign-in succeeds with case-insensitive name matching', () async {
      await repo.signUp('Elena Vance', 'pass321');

      final loggedIn = await repo.login('elena vance', 'pass321');
      expect(loggedIn.fullName, equals('Elena Vance'));

      final loggedInUpper = await repo.login('ELENA VANCE', 'pass321');
      expect(loggedInUpper.fullName, equals('Elena Vance'));
    });

    test('3. Sign-in with wrong password throws clear, descriptive error', () async {
      await repo.signUp('Officer Dave', 'correctPass1');

      expect(
        () => repo.login('Officer Dave', 'wrongPass2'),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            contains('Incorrect password for "Officer Dave"'),
          ),
        ),
      );
    });

    test('4. Sign-in with non-existent account throws clear not-found error', () async {
      expect(
        () => repo.login('NonExistentUser', 'anyPass'),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            contains('Account "NonExistentUser" was not found'),
          ),
        ),
      );
    });

    test('5. Sign-up with already-registered username throws duplicate account error', () async {
      await repo.signUp('Commander Shepard', 'normandy1');

      expect(
        () => repo.signUp('Commander Shepard', 'differentPass'),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            contains('An account named "Commander Shepard" already exists'),
          ),
        ),
      );

      // Also case-insensitive check
      expect(
        () => repo.signUp('commander shepard', 'anotherPass'),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            contains('An account named "commander shepard" already exists'),
          ),
        ),
      );
    });

    test('6. Empty name or password inputs are rejected with clear ArgumentError', () async {
      expect(
        () => repo.signUp('', 'pass'),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () => repo.signUp('User', '  '),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () => repo.login('', 'pass'),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () => repo.login('User', ''),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
