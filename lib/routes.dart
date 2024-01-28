import 'package:flutter/material.dart';
import 'package:restaurant_helper_tablet/screens/new_password_view.dart';
import 'package:restaurant_helper_tablet/screens/pending_reservations_view.dart';
import 'package:routemaster/routemaster.dart';
import 'package:utils/utils.dart';

import 'screens/login_view.dart';
import 'screens/order_view.dart';
import 'screens/reservations_view.dart';
import 'screens/planner_view.dart';
import 'screens/reservation_view.dart';



final loggedOutRoute = RouteMap(routes: {
  '/': (_) => MaterialPage(child:LoginView()),
  '/nowehaslo': (_) => MaterialPage(child:NewPasswordView())
}, onUnknownRoute: (_) => const Redirect('/'));

final loadingRoute = RouteMap(routes: {
  '/': (_) => const MaterialPage(child:LoadingScreen())
}, onUnknownRoute: (_) => const MaterialPage(child:LoadingScreen()));

final navigationRoutes = {
  '/pulpit': (_) => const MaterialPage(child:PlannerView(),name:'pulpit'),
  '/reservations': (_) => const MaterialPage(child:ReservationsView(),name:'reservations'),
  '/pending': (_) => const MaterialPage(child:PendingReservationsView(),name:'pending'),
  
};

final routes = RouteMap(routes: {
  '/': (_) => const Redirect('/pulpit'),
  '/pending/:id': (route) => MaterialPage(child: ReservationView(reservationId: route.pathParameters['id']!,isPending: true),name:'pending/:id'),
  '/reservations/:id': (route) => MaterialPage(child: ReservationView(reservationId: route.pathParameters['id']!,isPending: false),name:'reservations/:id'),
  '/reservations/:id/order': (route) => MaterialPage(child: OrderView(reservationId: route.pathParameters['id']!),name:'reservations/:id/order'),
  
  ...navigationRoutes
});