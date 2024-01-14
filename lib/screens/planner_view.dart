import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:utils/utils.dart';
import 'package:auth/auth.dart';
import 'package:planner/planner.dart';

class PlannerView extends ConsumerWidget {
  const PlannerView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = ref.watch(PlannerInfoProvider(AuthType.worker));
    final notifier = ref.read(PlannerInfoProvider(AuthType.worker).notifier);
    ref.listen(
        PlannerInfoProvider(AuthType.worker).select((value) => value.when(
            data: (data) => data.isChanged,
            error: (_, __) => false,
            loading: () => false)), (previous, next) {
      ref.read(unsavedChangesProvider.notifier).state = next;
    });
    return Scaffold(
        body: provider.when(
            data: (board) {
              return Row(
                children: [
                  Expanded(
                    child: PlannerBoard(board: board, notifier: notifier),
                  ),
                ],
              );
            },
            error: (error, stackTrace) => Center(
                    child: Text(
                  error.toString(),
                  style: boldBig,
                )),
            loading: () => const Center(
                child: Loading("Trwa ładowanie planu restauracji..."))));
  }
}
