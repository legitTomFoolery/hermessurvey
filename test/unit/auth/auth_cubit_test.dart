import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:gsecsurvey/features/auth/logic/auth_cubit.dart';

void main() {
  group('AuthCubit', () {
    late AuthCubit authCubit;

    setUp(() {
      authCubit = AuthCubit();
    });

    tearDown(() {
      authCubit.close();
    });

    test('initial state is AuthInitial', () {
      expect(authCubit.state, isA<AuthInitial>());
    });

    blocTest<AuthCubit, AuthState>(
      'emits AuthLoading when signInWithEmail is called',
      build: () => authCubit,
      act: (cubit) => cubit.signInWithEmail('test@example.com', 'password123'),
      expect: () => [isA<AuthLoading>()],
    );

    blocTest<AuthCubit, AuthState>(
      'emits AuthLoading when signUpWithEmail is called',
      build: () => authCubit,
      act: (cubit) =>
          cubit.signUpWithEmail('Test User', 'test@example.com', 'password123'),
      expect: () => [isA<AuthLoading>()],
    );

    blocTest<AuthCubit, AuthState>(
      'emits AuthLoading when resetPassword is called',
      build: () => authCubit,
      act: (cubit) => cubit.resetPassword('test@example.com'),
      expect: () => [isA<AuthLoading>()],
    );

    blocTest<AuthCubit, AuthState>(
      'emits AuthLoading when signInWithGoogle is called',
      build: () => authCubit,
      act: (cubit) => cubit.signInWithGoogle(),
      expect: () => [isA<AuthLoading>()],
    );

    test('resetState sets state to AuthInitial', () {
      authCubit.emit(AuthLoading());
      authCubit.resetState();
      expect(authCubit.state, isA<AuthInitial>());
    });

    group('checkUserAccountExists', () {
      test('returns false when no user is signed in', () async {
        final result = await authCubit.checkUserAccountExists();
        expect(result, false);
      });
    });
  });
}
