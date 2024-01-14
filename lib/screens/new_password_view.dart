import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:restaurant_helper_tablet/model.dart/change_password.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:utils/utils.dart';

class NewPasswordView extends ConsumerWidget {
  final RoundedLoadingButtonController _submitController =
      RoundedLoadingButtonController();

  NewPasswordView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    PasswordChange passwords = ref.watch(passwordProvider);
    return Scaffold(
      appBar: AppBar(
        primary: true,
        title: const Text("Ustaw nowe hasło", style: headerStyle),
        toolbarOpacity: 1.0,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.6,
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              EmailField(
                  onChanged: ref.read(passwordProvider.notifier).updateEmail,
                  initialValue: passwords.email),
              const SizedBox(height: 16),
              TextFormField(
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.visiblePassword,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  obscureText: true,
                  initialValue: passwords.password,
                  validator: (input) {
                    if (input == "" || input == null) return null;
                    return validatePassword(input).join('\n');
                  },
                  onChanged: ref.read(passwordProvider.notifier).updatePassword,
                  decoration: defaultDecoration(
                      icon: Icons.password, labelText: "Nowe hasło")),
              const SizedBox(height: 16),
              TextFormField(
                  textInputAction: TextInputAction.next,
                  obscureText: true,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  initialValue: passwords.confirmPassword,
                  validator: (input) {
                    if (input == "" || input == null) return null;
                    return input == passwords.password
                        ? null
                        : "Hasła muszą być identyczne";
                  },
                  onChanged:
                      ref.read(passwordProvider.notifier).updateConfirmPassword,
                  decoration: defaultDecoration(
                      icon: Icons.password, labelText: "Potwierdź hasło")),
              const SizedBox(height: 16),
              TextFormField(
                  textInputAction: TextInputAction.send,
                  keyboardType: TextInputType.visiblePassword,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  initialValue: passwords.accessKey,
                  onChanged: ref.read(passwordProvider.notifier).updateKey,
                  decoration: InputDecoration(
                    hintText:
                        "Klucz aktywacyjny znajdziesz na mailu na który założono Ci konto",
                    icon: const Icon(
                      Icons.key,
                      color: Colors.black,
                    ),
                    labelText: "Klucz aktywacyjny",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0)),
                  )),
              const SizedBox(height: 24),
              RoundedLoadingButton(
                color: primaryColor,
                successIcon: Icons.done,
                failedIcon: Icons.close,
                resetAfterDuration: true,
                resetDuration: const Duration(seconds: 2),
                width: 2000,
                controller: _submitController,
                onPressed: ref.read(passwordProvider.notifier).saveNewPassword,
                child: const Text('Zmień hasło',
                    style: TextStyle(color: Colors.white)),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
