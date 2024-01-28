import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:restaurant_helper_tablet/widgets/navigation.dart';

class BaseView extends ConsumerWidget {
  const BaseView({super.key, required this.screen});
  final Widget screen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(body: screen,bottomNavigationBar: const Navigation());
  }
}