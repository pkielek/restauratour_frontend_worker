import 'package:auth/auth.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:routemaster/routemaster.dart';
import 'package:utils/utils.dart';


class LoginView extends ConsumerWidget {
  final RoundedLoadingButtonController _submitController =
      RoundedLoadingButtonController();

  LoginView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
        body: Row(
      children: [
        Expanded(
            child: Image.asset(
          'images/logo.webp',
          semanticLabel: 'Restaura TOUR Logo',
          width: size.width * 0.5,
          height: size.height * 0.5,
        )),
        Expanded(
            child: Align(
                alignment: Alignment.centerLeft,
                child: SizedBox(
                    width: size.width * 0.33,
                    height: size.height * 0.66,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Center(
                            child: SelectableText("Panel Kelnera",
                                style: boldBig)),
                        Form(
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            child: Column(children: [
                              EmailField(
                                  onChanged: ref
                                      .read(LoginProvider(AuthType.worker).notifier)
                                      .updateEmail,
                                  onSubmit:
                                      ref.read(LoginProvider(AuthType.worker).notifier).login),
                              const SizedBox(height: 15),
                              PasswordField(
                                  type: AuthType.worker,
                                  onSubmit:
                                      ref.read(LoginProvider(AuthType.worker).notifier).login),
                              const SizedBox(height: 15),
                              RoundedLoadingButton(
                                color: primaryColor,
                                successIcon: Icons.done,
                                failedIcon: Icons.close,
                                resetAfterDuration: true,
                                resetDuration: const Duration(seconds: 2),
                                width: 2000,
                                controller: _submitController,
                                onPressed:
                                    ref.read(LoginProvider(AuthType.worker).notifier).login,
                                child: const Text('Zaloguj się!',
                                    style: TextStyle(color: Colors.white)),
                                
                              ),
                              const SizedBox(height: 15),
                              SelectableText(
                                  ref.watch(LoginProvider(AuthType.worker)).when(
                                      data: (data) => data.errorMessage,
                                      error: (_, __) => "Niespodziewany błąd",
                                      loading: () => ""),
                                  style: const TextStyle(color: Colors.red)),
                              const SizedBox(height: 30),

                              DefaultButton(callback: () => Routemaster.of(context).push("nowehaslo"), text: "Ustaw nowe hasło"),

                            ])),
                        const Center(
                            child: SelectableText(
                                "Piotr Kiełek © 2023 | Wszelkie prawa zastrzeżone",
                                style: footprintStyle)),
                      ],
                    ))))
      ],
    ));
  }
}
