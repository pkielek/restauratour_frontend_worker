import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:utils/utils.dart';

part 'change_password.g.dart';
part 'change_password.freezed.dart';

@freezed
class PasswordChange with _$PasswordChange {
  factory PasswordChange(
      {required String password,
      required String confirmPassword,
      required String email,
      required String accessKey}) = _PasswordChange;

  factory PasswordChange.fromJson(Map<String, dynamic> json) =>
      _$PasswordChangeFromJson(json);
  

}

@riverpod
class Password extends _$Password {
  @override
  PasswordChange build() {
    return PasswordChange(password: "", confirmPassword: "", email: "", accessKey: "");
  }

  void updatePassword(String? input) {
    if (input == null) return;
    state = state.copyWith(password: input);
  }

  void updateConfirmPassword(String? input) {
    if (input == null) return;
    state = state.copyWith(confirmPassword: input);
  }

  void updateKey(String? input) {
    if (input == null) return;
    state = state.copyWith(accessKey: input);
  }

  void updateEmail(String? input) {
    if (input == null) return;
    state = state.copyWith(email:input);
  }

  void cancelPasswordUpdate() {
    ref.invalidateSelf();
  }

  Future<void> saveNewPassword() async {
    if (validatePassword(state.password).isNotEmpty ||
        state.password != state.confirmPassword) {
      fluttertoastDefault(
          "Nowe hasło nie spełnia wymagań - odnieś się do błędów pod polami",
          true);
      return;
    }
    if (!state.email.isValidEmail()) {
      fluttertoastDefault("Ustaw poprawny adres e-mail",true);
      return;
    }
    try {
      await Dio().post('${dotenv.env['WORKER_API_URL']!}update-password',
          data: state.toJson());
      fluttertoastDefault("Hasło zapisano poprawnie!");
      cancelPasswordUpdate();
      return;
    } on DioException catch (e) {
      if (e.response != null) {
        Map responseBody = e.response!.data;
        fluttertoastDefault(responseBody['detail'], true);
      } else {
        fluttertoastDefault(
            "Coś poszło nie tak. Spróbuj jeszcze raz ponownie", true);
      }
      return;
    }
  }
}
