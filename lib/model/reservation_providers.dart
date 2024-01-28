import 'package:auth/auth.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:reservations/reservations.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:utils/utils.dart';

part 'reservation_providers.g.dart';

@Riverpod(keepAlive: true)
Stream<List<RestaurantReservation>> todaysReservations(
    TodaysReservationsRef ref) async* {
  while (true) {
    try {
      final response = await Dio().get(
          '${dotenv.env['WORKER_API_URL']!}todays-reservations',
          options: Options(headers: {
            "Authorization": "Bearer ${ref.read(authProvider).value!.jwtToken}"
          }));
      yield (response.data as List<dynamic>)
          .map((e) => RestaurantReservation.fromJson(e))
          .toList();
      await Future.delayed(Duration(seconds: 30));
    } on DioException {
      fluttertoastDefault(
          "Nie udało się wczytać dzisiejszych rezerwacji", true);
      yield [];
      await Future.delayed(Duration(seconds: 5));
    }
  }
}

@riverpod
Future<Map<int, int>> tableComingReservations(
    TableComingReservationsRef ref, String id) async {
  try {
    final response = await Dio().get(
        '${dotenv.env['WORKER_API_URL']!}table-coming-reservations',
        queryParameters: {"table_real_id": id},
        options: Options(headers: {
          "Authorization": "Bearer ${ref.read(authProvider).value!.jwtToken}"
        }));
    return (response.data as Map<String, dynamic>).map(
        (key, value) => MapEntry<int, int>(int.parse(key), value));
  } on DioException {
    fluttertoastDefault(
        "Nie udało się wczytać najbliższych rezerwacji stolika", true);
    return {};
  }
}

@Riverpod(keepAlive: true)
Stream<int> pendingReservationsCount(PendingReservationsCountRef ref) async* {
  while (true) {
    try {
      final response = await Dio().get(
          '${dotenv.env['WORKER_API_URL']!}pending-reservations-count',
          options: Options(headers: {
            "Authorization": "Bearer ${ref.read(authProvider).value!.jwtToken}"
          }));
      yield response.data as int;
    } on DioException {
      fluttertoastDefault(
          "Nie udało się wczytać liczby oczekujących rezerwacji", true);
      yield 0;
    }
    await Future.delayed(Duration(seconds: 60));
  }
}

@Riverpod(keepAlive: true)
Stream<int> needingServiceReservationsCount(
    NeedingServiceReservationsCountRef ref) async* {
  while (true) {
    try {
      final response = await Dio().get(
          '${dotenv.env['WORKER_API_URL']!}needing-service-reservations-count',
          options: Options(headers: {
            "Authorization": "Bearer ${ref.read(authProvider).value!.jwtToken}"
          }));
      yield response.data as int;
    } on DioException {
      fluttertoastDefault(
          "Nie udało się wczytać liczby oczekujących rezerwacji", true);
      yield 0;
    }
    await Future.delayed(const Duration(seconds: 15));
  }
}

@riverpod
class PendingReservations extends _$PendingReservations {
  @override
  Future<List<RestaurantReservation>> build() async {
    try {
      final response = await Dio().get(
          '${dotenv.env['WORKER_API_URL']!}pending-reservations',
          options: Options(headers: {
            "Authorization": "Bearer ${ref.read(authProvider).value!.jwtToken}"
          }));
      return (response.data as List<dynamic>)
          .map((e) => RestaurantReservation.fromJson(e))
          .toList();
    } on DioException catch (e) {
      if (e.response != null) {
        Map responseBody = e.response!.data;
        throw responseBody['detail'];
      } else {
        throw "Coś poszło nie tak, spróbuj ponownie później";
      }
    }
  }

  Future<void> decideReservation(int id, bool isAccepted) async {
    try {
      await Dio().post('${dotenv.env['WORKER_API_URL']!}decide-reservation',
          data: {"reservation_id": id, "accept": isAccepted},
          options: Options(headers: {
            "Authorization": "Bearer ${ref.read(authProvider).value!.jwtToken}"
          }));
      fluttertoastDefault(
          "Poprawnie ${isAccepted ? "zaakceptowano" : "odrzucono"} rezerwację");
    } on DioException catch (e) {
      if (e.response != null) {
        Map responseBody = e.response!.data;
        fluttertoastDefault(responseBody['detail'], true);
      } else {
        fluttertoastDefault("Coś poszło nie tak, spróbuj ponownie później");
      }
    }
    ref.invalidateSelf();
  }
}

@riverpod
class CurrentReservations extends _$CurrentReservations {
  @override
  Future<RestaurantReservationHistory> build() async {
    return RestaurantReservationHistory(
        reservations: await getNext(1), pagination: 1);
  }

  Future<void> paginate() async {
    if (!state.value!.finishedLoading) {
      state = AsyncData(state.value!
          .copyWith(pagination: state.value!.pagination + 1, isLoading: true));
      final nextItems = await getNext();
      if (nextItems.isEmpty) {
        state = AsyncData(
            state.value!.copyWith(finishedLoading: true, isLoading: false));
      } else {
        state = AsyncData(state.value!.copyWith(
            reservations: [...state.value!.reservations, ...nextItems],
            isLoading: false));
      }
    }
  }

  Future<List<RestaurantReservation>> getNext([int? pagination]) async {
    try {
      final response = await Dio().get(
          '${dotenv.env['WORKER_API_URL']!}current-reservations',
          queryParameters: {'page': pagination ?? state.value!.pagination},
          options: Options(headers: {
            "Authorization": "Bearer ${ref.read(authProvider).value!.jwtToken}"
          }));
      return (response.data as List<dynamic>)
          .map((e) => RestaurantReservation.fromJson(e))
          .toList();
    } on DioException catch (e) {
      if (e.response != null) {
        Map responseBody = e.response!.data;
        throw responseBody['detail'];
      } else {
        throw "Coś poszło nie tak, spróbuj ponownie później";
      }
    }
  }

  void refresh() {
    ref.invalidateSelf();
  }
}
