import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:restaurant_helper_tablet/model/reservation_providers.dart';
import 'package:restaurant_helper_tablet/routes.dart';
import 'package:routemaster/routemaster.dart';
import 'package:utils/utils.dart';

class Navigation extends ConsumerWidget {
  const Navigation({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = navigationRoutes.entries.toList();
    final currentRouteName = ModalRoute.of(context)!.settings.name;
    final routeIndex = currentRouteName!.contains('pending')
        ? 2
        : currentRouteName.contains('reservations')
            ? 1
            : 0;
    final int pendingReservationsNumber = ref
        .watch(pendingReservationsCountProvider)
        .when(
            data: (data) => data,
            error: (error, stackTrace) => 0,
            loading: () => 0);
    Widget pendingNavWidget = const NavigationDestination(
        icon: Icon(Icons.history), label: "Oczekujące");
    if (pendingReservationsNumber > 0) {
      pendingNavWidget = Badge.count(
        largeSize: 24,
        textStyle: listStyle,
        count: pendingReservationsNumber,
        textColor: Colors.white,
        backgroundColor: primaryColor,
        alignment: Alignment.center,
        offset: const Offset(18, -18),
        child: pendingNavWidget,
      );
    }
    final int needingServiceReservationsNumber = ref
        .watch(needingServiceReservationsCountProvider)
        .when(
            data: (data) => data,
            error: (error, stackTrace) => 0,
            loading: () => 0);
    Widget reservationsgNavWidget = const NavigationDestination(
        icon: Icon(Icons.chair_alt), label: "Rezerwacje");
    if (needingServiceReservationsNumber > 0) {
      reservationsgNavWidget = Badge.count(
        largeSize: 24,
        textStyle: listStyle,
        count: needingServiceReservationsNumber,
        textColor: Colors.white,
        backgroundColor: primaryColor,
        alignment: Alignment.center,
        offset: const Offset(18, -18),
        child: reservationsgNavWidget,
      );
    }
    return NavigationBar(
        onDestinationSelected: (value) =>
            Routemaster.of(context).replace(entries[value].key),
        selectedIndex: routeIndex,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: [
          const NavigationDestination(icon: Icon(Icons.home), label: "Pulpit"),
          reservationsgNavWidget,
          pendingNavWidget
        ]);
  }
}
