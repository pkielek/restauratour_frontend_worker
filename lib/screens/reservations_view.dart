import 'package:auth/auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:reservations/reservations.dart';
import 'package:restaurant_helper_tablet/model/reservation_providers.dart';
import 'package:routemaster/routemaster.dart';
import 'package:utils/utils.dart';

import 'base_view.dart';

class ReservationsView extends HookConsumerWidget {
  const ReservationsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scrollController = useScrollController();
    scrollController.addListener(() async => scrollController.position.pixels ==
                scrollController.position.maxScrollExtent &&
            !ref.read(reservationHistoryProvider).value!.isLoading &&
            !ref.read(reservationHistoryProvider).value!.finishedLoading
        ? await ref.read(reservationHistoryProvider.notifier).paginate()
        : null);
    return BaseView(
        screen: ref.watch(currentReservationsProvider).when(
            data: (data) {
              return Column(
                children: [
                  Expanded(
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              childAspectRatio: 3.0, crossAxisCount: 2),
                      padding: const EdgeInsets.only(top: 12),
                      shrinkWrap: true,
                      itemBuilder: (context, index) => Padding(
                        padding: const EdgeInsets.all(8),
                        child: Hero(
                          tag: "reservation:${data.reservations[index].id}",
                          child: Material(
                            child: InkWell(
                              onTap: () => Routemaster.of(context)
                                  .push(data.reservations[index].id.toString()),
                              child: ReservationTile(
                                  data: data.reservations[index],
                                  type: AuthType.worker,
                                  needsService: data.reservations[index].date
                                          .isBefore(DateTime.now()) &&
                                      data.reservations[index].date.add(Duration(
                                              minutes: (data.reservations[index]
                                                          .reservationHourLength *
                                                      60)
                                                  .toInt())).isAfter(
                                          DateTime.now()) &&
                                      data.reservations[index].needService),
                            ),
                          ),
                        ),
                      ),
                      itemCount: data.reservations.length,
                    ),
                  ),
                  if (data.isLoading && !data.finishedLoading)
                    const SizedBox(
                        height: 100, child: CircularProgressIndicator())
                ],
              );
            },
            error: (error, stackTrace) => const Center(
                child: Text("Coś poszło nie tak, spróbuj ponownie później!",
                    style: headerStyle)),
            loading: () =>
                const Center(child: Loading("Ładowanie rezerwacji..."))));
  }
}
