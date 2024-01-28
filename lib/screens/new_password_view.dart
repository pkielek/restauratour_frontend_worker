import 'package:auth/auth.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:utils/utils.dart';

class NewPasswordView extends ConsumerWidget {
  const NewPasswordView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            child:RegisterFields(type: AuthType.worker)
          ),
        ),
      ),
    );
  }
}
