import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yoggo/component/bookPage/viewModel/book_page_model.dart';
import '../../../Repositories/Repository.dart';
import 'dart:convert';

class BookPageCubit extends Cubit<List<BookPageModel>> {
  static final Map<int, List<BookPageModel>> _dataMap = {}; // Map으로 변경
  final DataRepository dataRepository;
  BookPageCubit(this.dataRepository) : super([]);
  void loadBookPageData(int contentVoiceId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // // 먼저 Shared Preferences에서 데이터를 불러옵니다.
    // final cachedData =
    //     prefs.getStringList('book_contentVoiceId_$contentVoiceId');
    // if (cachedData != null) {
    //   final cachedBookPageData = cachedData
    //       .map((item) => BookPageModel.fromJson(json.decode(item)))
    //       .toList();
    //   emit(cachedBookPageData); // 불러온 데이터를 emit하여 UI에 표시
    //   return;
    // }

    // Shared Preferences에 저장된 데이터가 없는 경우, API를 호출하여 데이터를 가져옵니다.
    final data = await dataRepository.bookPageRepository(contentVoiceId);

    final serializedData =
        data.map((item) => json.encode(item.toJson())).toList();

    _dataMap[contentVoiceId] = data; // 가져온 데이터를 Map에 저장합니다.
    // prefs.setStringList('book_contentVoiceId_$contentVoiceId', serializedData);
    data.sort((a, b) => a.pageNum.compareTo(b.pageNum));
    emit(data);
  }
}
