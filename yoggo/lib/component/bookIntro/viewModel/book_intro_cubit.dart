import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yoggo/component/bookIntro/viewModel/book_intro_model.dart';
import '../../../Repositories/Repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../home/viewModel/home_screen_cubit.dart';

class BookIntroCubit extends Cubit<List<BookIntroModel>> {
  final DataRepository dataRepository;
  static final Map<int, List<BookIntroModel>> _dataMap = {}; // Map으로 변경

  BookIntroCubit(this.dataRepository) : super([]);

  void loadBookIntroData(int? contentId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    //final cachedData = prefs.getStringList('book_$contentId');
    if (contentId == null) {
      return;
    }
    // if (_dataMap.containsKey(contentId)) {
    // if (cachedData != [] && cachedData != null) {
    //   // 이미 데이터가 로드되어 있다면, 저장된 데이터를 사용하여 emit합니다.
    //   //  emit(_dataMap[contentId]!);
    //   final cachedBookIntroData = cachedData
    //       .map((item) => BookIntroModel.fromJson(json.decode(item)))
    //       .toList();
    //   emit(cachedBookIntroData);
    //   return;
    // }

    // 현재 contentId에 대한 데이터가 없으면, 다른 contentId로 저장된 데이터가 있는지 확인합니다.

    // 캐시된 데이터가 하나도 없으면, 레포지토리에서 데이터를 가져옵니다.
    final data = await dataRepository.bookIntroRepository(contentId);
    final serializedData =
        data.map((item) => json.encode(item.toJson())).toList();
    _dataMap[contentId] = data; // 가져온 데이터를 Map에 저장합니다.
    //prefs.setStringList('book_$contentId', serializedData);

    emit(data);
  }

  void changeBookIntroData(int? contentId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    //final cachedData = prefs.getStringList('book_contentId_$contentId');
    if (contentId == null) {
      return;
    }
    // if (_dataMap.containsKey(contentId)) {
    final data = await dataRepository.bookIntroRepository2(contentId);
    final serializedData =
        data.map((item) => json.encode(item.toJson())).toList();
    _dataMap[contentId] = data; // 가져온 데이터를 Map에 저장합니다.
    prefs.setStringList('book_$contentId', serializedData);
    emit(data);
  }
}
