import 'package:auth/auth.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:reservations/reservations.dart';
import 'package:routemaster/routemaster.dart';
import 'package:utils/utils.dart';

import '../model/reservation_providers.dart';

class ReservationView extends ConsumerWidget {
  const ReservationView(
      {super.key, required this.reservationId, required this.isPending});
  final String reservationId;
  final bool isPending;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (int.tryParse(reservationId) == null) {
      return const Scaffold(
        body: Center(child: Text("Błąd aplikacji", style: headerStyle)),
      );
    }
    final id = int.parse(reservationId);

    final initData = isPending
        ? ref
            .read(pendingReservationsProvider.select((value) => value
                .whenData((value2) => value2.firstWhere((e) => e.id == id))))
            .value!
        : ref
                .read(currentReservationsProvider.select((value) =>
                    value.whenData((value2) =>
                        value2.reservations.firstWhere((e) => e.id == id))))
                .value ??
            ref
                .read(todaysReservationsProvider.select((value) =>
                    value.whenData((value2) => value2.firstWhere((e) => e.id == id))))
                .value!;
    final isOngoing = initData.date.isBefore(DateTime.now()) &&
        initData.date
            .add(Duration(
                minutes: (initData.reservationHourLength * 60).toInt()))
            .isAfter(DateTime.now());
    return Scaffold(
        body: Row(children: [
      Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        AspectRatio(
          aspectRatio: 3.0,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Hero(
              tag: "reservation:$reservationId",
              child: Material(
                child: InkWell(
                  onTap: () async {},
                  child: ReservationTile(
                      data: initData,
                      type: AuthType.worker,
                      needsService: isOngoing && initData.needService),
                ),
              ),
            ),
          ),
        ),
        Expanded(
            child: IconButton(
                onPressed: Routemaster.of(context).pop,
                icon: const Icon(Icons.arrow_back,
                    color: Colors.black, size: 200)))
      ])),
      Expanded(
          child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text("Uwagi do zamówienia:",
                style: headerStyle, textAlign: TextAlign.center),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(initData.additionalDetails, style: listLightStyle),
          ),
          if (!isPending)
            const Padding(
              padding: EdgeInsets.only(top: 16),
              child: Text("Zamówienie do rezerwacji:",
                  style: headerStyle, textAlign: TextAlign.center),
            ),
          if (!isPending && initData.order.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Text(
                "Rezerwacja nie ma zamówienia",
                textAlign: TextAlign.center,
                style: listStyle,
              ),
            ),
          if (!isPending && initData.order.isNotEmpty)
            for (final item in initData.order.entries)
              ListTile(
                  leading:
                      Text("${item.value['count']}x", style: listLightStyle),
                  title: Text(
                    item.value['name'],
                    style: listStyle,
                  ),
                  trailing: Text(
                    item.value['total_price'],
                    style: listLightStyle,
                  )),
          if (!isPending)
            Padding(
              padding: const EdgeInsets.only(top: 24.0),
              child: DefaultButton(
                  callback: () => Routemaster.of(context).push('order'),
                  text: "Edytuj zamówienie"),
            ),
          if (isPending)
            const Text(
              "Zaakceptować rezerwację?",
              style: headerStyle,
              textAlign: TextAlign.center,
            ),
          if (isPending)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                    tooltip: "Zaakceptuj rezerwację",
                    onPressed: () => ref
                        .read(pendingReservationsProvider.notifier)
                        .decideReservation(id, true)
                        .then((value) => Routemaster.of(context).pop()),
                    icon:
                        const Icon(Icons.done, color: Colors.green, size: 150)),
                IconButton(
                    tooltip: "Odrzuć rezerwację",
                    onPressed: () => ref
                        .read(pendingReservationsProvider.notifier)
                        .decideReservation(id, true)
                        .then((value) => Routemaster.of(context).pop()),
                    icon: const Icon(Icons.close, color: Colors.red, size: 150))
              ],
            )
        ],
      )),
    ]));
    // return SingleChildScrollView(
    //   child: Column(
    //     crossAxisAlignment: CrossAxisAlignment.stretch,
    //     children: [
    //       Padding(
    //         padding: const EdgeInsets.all(8),
    //         child: Hero(
    //           tag: "reservation:$reservationId",
    //           child: Material(
    //             child: InkWell(
    //               onTap: () async {},
    //               child: IntrinsicHeight(
    //                   child: ReservationTile(data: data)),
    //             ),
    //           ),
    //         ),
    //       ),
    //       const SizedBox(height: 32),
    //       if (isOngoing && data.status == ReservationStatus.accepted)
    //         DefaultButton(
    //             callback: () => ref
    //                 .read(ReservationProvider(AuthType.user).notifier)
    //                 .notifyService(id),
    //             text: data.needService
    //                 ? "Odwołaj prośbę"
    //                 : "Poproś o kelnera"),
    //       if (!isPast && data.status != ReservationStatus.rejected)
    //         DefaultButton(
    //             callback: () async => await ref
    //                     .read(ReservationProvider(AuthType.user)
    //                         .notifier)
    //                     .cancel(id)
    //                 ? Routemaster.of(context).pop()
    //                 : null,
    //             text: "Anuluj rezerwację"),
    //       if (data.status == ReservationStatus.accepted)
    //         const Padding(
    //           padding: EdgeInsets.only(top: 16),
    //           child: Text("Zamówienie do rezerwacji:",
    //               style: headerStyle, textAlign: TextAlign.center),
    //         ),
    //       if (data.status == ReservationStatus.accepted &&
    //           data.order.isEmpty)
    //         Padding(
    //           padding: const EdgeInsets.symmetric(
    //               horizontal: 8, vertical: 4),
    //           child: Column(children: [
    //             Text(
    //               isPast
    //                   ? "Rezerwacja nie miała zamówienia"
    //                   : "Rezerwacja nie ma jeszcze zamówienia - warto je złożyć wcześniej by ułatwić pracę kelnerom!",
    //               textAlign: TextAlign.center,
    //               style: listStyle,
    //             ),
    //             Image.asset("images/missing2.png"),
    //             const Text("© Storyset, Freepik",
    //                 textAlign: TextAlign.center,
    //                 style: footprintStyle)
    //           ]),
    //         ),
    //       if (data.status == ReservationStatus.accepted &&
    //           data.order.isNotEmpty)
    //         for (final item in data.order.entries)
    //           ListTile(
    //               leading: Text("${item.value['count']}x",
    //                   style: listLightStyle),
    //               title: Text(
    //                 item.value['name'],
    //                 style: listStyle,
    //               ),
    //               trailing: Text(
    //                 item.value['total_price'],
    //                 style: listLightStyle,
    //               )),
    //       if (!isPast && data.status == ReservationStatus.accepted)
    //         Padding(
    //           padding: const EdgeInsets.only(top: 24.0),
    //           child: DefaultButton(
    //               callback: () =>
    //                   Routemaster.of(context).push('order'),
    //               text:
    //                   "${data.order.isEmpty ? "Złóż" : "Edytuj"} zamówienie"),
    //         ),

    //       const SizedBox(height: 36),
    //     ],
    //   ),
    // );
    // },
    // error: (error, stackTrace) {
    //   return const Center(
    //       child: Text("Coś poszło nie tak, spróbuj ponownie później!",
    //           style: headerStyle));
    // },
    // loading: () => const Loading("Trwa ładowanie rezerwacji...")));
  }
}
