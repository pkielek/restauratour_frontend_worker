import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:restaurant_helper_tablet/model/reservation_providers.dart';
import 'package:restaurant_helper_tablet/screens/base_view.dart';
import 'package:restaurant_helper_tablet/widgets/planner_table_panel.dart';
import 'package:utils/utils.dart';
import 'package:auth/auth.dart';
import 'package:planner/planner.dart';

class PlannerView extends ConsumerWidget {
  const PlannerView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = ref.watch(PlannerInfoProvider(AuthType.worker));
    final notifier = ref.read(PlannerInfoProvider(AuthType.worker).notifier);
    final todaysReservations = ref.watch(todaysReservationsProvider);
    final Map<String, Color> explicitContainerColors = todaysReservations.when(
      data: (data) {
        Map<String, Color> colors = {};
        colors.addAll({
          for (final id in data
              .where((element) =>
                  element.date.isBefore(DateTime.now()) && element.needService)
              .map((e) => e.tableId))
            id!: Colors.transparent
        });
        colors.addAll({
          for (final id in data
              .where((element) =>
                  element.date.isBefore(DateTime.now()) &&
                  !colors.containsKey(element.tableId))
              .map((e) => e.tableId))
            id!: Colors.red
        });
        colors.addAll({
          for (final id in data
              .where((element) => !colors.containsKey(element.tableId))
              .map((e) => e.tableId))
            id!: Colors.yellow
        });
        return colors;
      },
      error: (error, stackTrace) => {},
      loading: () => {},
    );
    ref.listen(
        PlannerInfoProvider(AuthType.worker).select((value) => value.when(
            data: (data) => data.isChanged,
            error: (_, __) => false,
            loading: () => false)), (previous, next) {
      ref.read(unsavedChangesProvider.notifier).state = next;
    });
    return BaseView(
        screen: provider.when(
            data: (board) {
              return Row(
                children: [
                  Expanded(
                    child: PlannerBoard(
                        board: board,
                        notifier: notifier,
                        explicitColors: explicitContainerColors),
                  ),
                  Container(
                    padding: const EdgeInsets.all(10.0),
                    decoration: const BoxDecoration(
                        color: Colors.white,
                        border: Border(
                            left: BorderSide(width: 2, color: Colors.black))),
                    width: 250,
                    child: todaysReservations.when(
                        data: (data) => board.currentAction == BoardAction.none
                            ? const Padding(
                              padding: EdgeInsets.only(top:40),
                              child: Column(children: [
                                  Text("Witaj w RestauraTOUR",
                                      style: headerStyle,
                                      textAlign: TextAlign.center),
                                  Text(
                                      "Kliknij stolik, by zobaczyć jego szczegóły",
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 16),
                                      textAlign: TextAlign.center)
                                ]),
                            )
                            : PlannerTablePanel(
                                tableId: board.tables[board.selectedTable!].id,
                                data: data
                                        .where((e) =>
                                            e.tableId ==
                                            board.tables[board.selectedTable!]
                                                .id)
                                        .isEmpty
                                    ? null
                                    : data.firstWhere((e) =>
                                        e.tableId ==
                                        board.tables[board.selectedTable!].id)),
                        loading: () => const Center(
                            child: Loading(
                                "Trwa ładowanie dzisiejszych rezerwacji...")),
                        error: (error, stackTrace) => Center(
                                child: Text(
                              error.toString(),
                              style: boldBig,
                            ))),
                  )
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
