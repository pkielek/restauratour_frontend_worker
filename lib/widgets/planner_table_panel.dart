import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:reservations/reservations.dart';
import 'package:restaurant_helper_tablet/model/reservation_providers.dart';
import 'package:routemaster/routemaster.dart';
import 'package:utils/utils.dart';

class PlannerTablePanel extends ConsumerWidget {
  const PlannerTablePanel(
      {super.key, required this.data, required this.tableId});
  final String tableId;
  final RestaurantReservation? data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LayoutBuilder(builder: (context, constraints) {
      return SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: IntrinsicHeight(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0,top:40.0),
                  child: Column(children: [
                    Text(data != null ? data!.name : "Stolik ${tableId}",
                        style: headerStyle, textAlign: TextAlign.center),
                    if (data != null &&
                        data!.date.isBefore(DateTime.now()) &&
                        data!.needService)
                      Text("Klient poprosił o obsługę kelnera",
                          textAlign: TextAlign.center,
                          style: listStyle.copyWith(color: primaryColor)),
                  ]),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (data != null && data!.date.isBefore(DateTime.now()))
                          Padding(
                            padding: const EdgeInsets.only(bottom: 15.0),
                            child: Text(
                              "Rezerwacja trwa\nod ${data!.date.fullHour()} do ${data!.date.add(Duration(minutes: (data!.reservationHourLength * 60).toInt())).fullHour()}",
                              textAlign: TextAlign.center,
                              style: listLightStyle,
                            ),
                          ),
                        if (data != null && data!.date.isBefore(DateTime.now()))
                          const Padding(
                            padding: EdgeInsets.only(bottom: 8.0),
                            child: Text(
                              "Zamówienie rezerwacji:",
                              textAlign: TextAlign.center,
                              style: listStyle,
                            ),
                          ),
                        if (data != null && data!.date.isBefore(DateTime.now()))
                          for (final item in data!.order.entries)
                            ListTile(
                                leading: Text("${item.value['count']}x",
                                    style: smallDetailStyle.copyWith(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold)),
                                title: Text(
                                  item.value['name'],
                                  style: smallDetailStyle.copyWith(
                                      color: Colors.black,
                                      fontWeight: FontWeight.normal),
                                )),
                        if (data != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 15.0),
                            child: Text(
                              "Rezerwacja zacznie\n się o ${data!.date.fullHour()}",
                              textAlign: TextAlign.center,
                              style: listLightStyle,
                            ),
                          ),
                        if (data != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Text(
                              "Liczba pozycji w zamówieniu: ${data!.order.entries.map((e) => e.value['count'] as int).reduce((value, element) => value + element)}" ,
                              textAlign: TextAlign.center,
                              style: listStyle,
                            ),
                          ),
                        if (data != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 12.0),
                            child: DefaultButton(
                                callback: () => Routemaster.of(context)
                                    .push('/reservations/${data!.id}'),
                                text: "Przejdź do rezerwacji"),
                          )
                      ]),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical:12.0),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text("Najbliższe rezerwacje:",
                            style: listStyle, textAlign: TextAlign.center),
                        for (final weekdayCount in ref
                            .watch(TableComingReservationsProvider(tableId))
                            .when(
                              data: (data) => data,
                              error: (error, stackTrace) => {},
                              loading: () => {},
                            )
                            .entries)
                          Text(
                              "${getWeekdayName(weekdayCount.key)} : ${weekdayCount.value}",
                              style: listLightStyle,
                              textAlign: TextAlign.center)
                      ]),
                )
              ],
            ),
          ),
        ),
      );
    });
  }
}
