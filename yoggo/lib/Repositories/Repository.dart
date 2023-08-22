import 'package:http/http.dart' as http;
import 'package:yoggo/component/bookIntro/viewModel/book_intro_model.dart';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:yoggo/component/home/viewModel/home_screen_book_model.dart';

import 'package:yoggo/component/bookPage/viewModel/book_page_model.dart';

class DataRepository {
  static bool _isLoaded = false;
  static const bool _bookIntroLoaded = false;

  static List<HomeScreenBookModel> _loadedHomeScreenData = [];

  static Future<List<HomeScreenBookModel>> loadHomeBookRepository() async {
    // home screen에서 책 목록들
    if (!_isLoaded) {
      await dotenv.load(fileName: ".env");

      final response =
          // // release 버전
          await http.get(Uri.parse(dotenv.get("API_SERVER") + 'content/all'));
      // // dev 버전
      // await http.get(Uri.parse('https://yoggo-server.fly.dev/content/dev'));
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as List<dynamic>;
        final data =
            jsonData.map((item) => HomeScreenBookModel.fromJson(item)).toList();
        _loadedHomeScreenData = data;
        _isLoaded = true;
      }
    }
    return _loadedHomeScreenData;
  }

  // static Future<List<BookIntroModel>> bookIntroRepository(
  //     // 홈 > 책 하나 클릭한 상태
  //     int contentId) async {
  //   // home screen에서 책 목록들
  //   if (!_bookIntroLoaded) {
  //     final response = await http
  //         .get(Uri.parse('https://yoggo-server.fly.dev/content/$contentId'));

  //     if (response.statusCode == 200) {
  //       final jsonData = json.decode(response.body) as List<dynamic>;
  //       final data =
  //           jsonData.map((item) => BookIntroModel.fromJson(item)).toList();
  //       _loadedBookIntroData = data;
  //       _bookIntroLoaded = true;
  //     }
  //   }
  //   return _loadedBookIntroData;
  // }

  // ...

  // static final List<BookIntroModel> _loadedBookIntroData = [];
  static final List<BookIntroModel> _loadedBookIntroData = [];
  static final List<int> _loadedBookNumber = [];

  static Future<List<BookIntroModel>> bookIntroRepository(int contentId) async {
    if (_loadedBookNumber.contains(contentId)) {
      // 이미 로드한 데이터가 있다면 해당 contentId에 맞는 데이터를 추출하여 리턴
      final loadedData = _loadedBookIntroData
          .where((data) => data.contentId == contentId)
          .toList();
      return loadedData;
    }
    _loadedBookNumber.add(contentId);
    final response = await http
        .get(Uri.parse('https://yoggo-server.fly.dev/content/$contentId'));
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body) as List<dynamic>;
      final data =
          jsonData.map((item) => BookIntroModel.fromJson(item)).toList();
      _loadedBookIntroData.addAll(data); // 로드한 데이터를 저장
      return data;
    } else {
      return []; // 에러 발생 시 빈 리스트 리턴
    }
  }

// book page
  static final Map<int, List<BookPageModel>> _loadedBookPageDataMap = {};
  static final List<int> _loadedBookPageNumber = [];

  static Future<List<BookPageModel>> bookPageRepository(
      int contentVoiceId) async {
    if (_loadedBookPageNumber.contains(contentVoiceId)) {
      // 이미 로드한 데이터가 있다면 해당 contentVoiceId에 맞는 데이터를 추출하여 리턴
      return _loadedBookPageDataMap[contentVoiceId] ?? [];
    }

    _loadedBookPageNumber.add(contentVoiceId);
    final response = await http.get(Uri.parse(
        'https://yoggo-server.fly.dev/content/page?contentVoiceId=$contentVoiceId'));
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body) as List<dynamic>;
      final bookPageData =
          jsonData.map((item) => BookPageModel.fromJson(item)).toList();

      _loadedBookPageDataMap[contentVoiceId] = bookPageData; // 로드한 데이터를 저장
      return bookPageData;
    } else {
      return []; // 에러 발생 시 빈 리스트 리턴
    }
  }
}
