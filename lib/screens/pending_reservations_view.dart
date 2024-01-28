import 'package:auth/auth.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:reservations/reservations.dart';
import 'package:restaurant_helper_tablet/model/reservation_providers.dart';
import 'package:routemaster/routemaster.dart';
import 'package:utils/utils.dart';

import 'base_view.dart';

class PendingReservationsView extends ConsumerWidget {
  const PendingReservationsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BaseView(
        screen: ref.watch(pendingReservationsProvider).when(
            data: (data) {
              return GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    childAspectRatio: 3.0, crossAxisCount: 2),
                padding: const EdgeInsets.only(top: 12),
                shrinkWrap: true,
                itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.all(8),
                  child: Hero(
                    tag: "reservation:${data[index].id}",
                    child: Material(
                      child: InkWell(
                        onTap: () => Routemaster.of(context).push(data[index].id.toString()),
                        child: ReservationTile(
                            data: data[index], type: AuthType.worker),
                      ),
                    ),
                  ),
                ),
                itemCount: data.length,
              );
            },
            error: (error, stackTrace) => const Center(
                child: Text("Coś poszło nie tak, spróbuj ponownie później!",
                    style: headerStyle)),
            loading: () => const Center(child: Loading("Ładowanie rezerwacji..."))));
  }
}
