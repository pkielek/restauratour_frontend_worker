import 'package:flutter/material.dart';
import 'package:restaurant_helper_tablet/screens/new_password_view.dart';
import 'package:routemaster/routemaster.dart';
import 'package:utils/utils.dart';

import 'screens/login_view.dart';
import 'screens/planner_view.dart';



final loggedOutRoute = RouteMap(routes: {
  '/': (_) => MaterialPage(child:LoginView()),
  '/nowehaslo': (_) => MaterialPage(child:NewPasswordView())
}, onUnknownRoute: (_) => const Redirect('/'));

final loadingRoute = RouteMap(routes: {
  '/': (_) => const MaterialPage(child:LoadingScreen())
}, onUnknownRoute: (_) => const MaterialPage(child:LoadingScreen()));

final navigationRoutes = {
  '/pulpit': (_) => const MaterialPage(child:PlannerView(),name:'Plan restauracji'),
};

final routes = RouteMap(routes: {
  '/': (_) => const Redirect('/pulpit'),
  ...navigationRoutes
});