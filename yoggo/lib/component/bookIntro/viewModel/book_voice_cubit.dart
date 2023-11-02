import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../Repositories/Repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'book_voice_model.dart';

class BookVoiceCubit extends Cubit<List<BookVoiceModel>> {
  final DataRepository dataRepository;
  static final Map<int, List<BookVoiceModel>> _dataMap = {}; // Map으로 변경

  BookVoiceCubit(this.dataRepository) : super([]);

  Future<BookVoiceModel?> loadBookVoiceData(int contentId) async {
    //final SharedPreferences prefs = await SharedPreferences.getInstance();
    final data = await dataRepository.bookVoiceRepository(contentId);
    // final serializedData =
    //     data.map((item) => json.encode(item.toJson())).toList();
    // _dataMap[contentId] = data; // 가져온 데이터를 Map에 저장합니다.
    BookVoiceModel? clickedVoice;

    for (var item in data) {
      if (item.clicked == true) {
        clickedVoice = item;
        break;
      }
    }
    print("📚 load voice: $data");
    emit(data);
    return clickedVoice;
  }

//voice 클릭 시
  Future<void> clickBookVoiceData(int contentId, int clickedId) async {
    final data =
        await dataRepository.clickBookVoiceRepository(contentId, clickedId);

    // print("📌 click voice: $data");
    emit(data);
  }

  //voice 클릭 시
  Future<BookVoiceModel?> loadClickedBookVoiceData(int contentId) async {
    List<BookVoiceModel> data = state;
    BookVoiceModel? clickedVoice;
    for (var item in data) {
      if (item.clicked == true) {
        clickedVoice = item;
        break;
      }
    }
    //print(clickedVoice);
    emit(data);
    return clickedVoice;
  }

//my Voice 다시 받아올 때!
  Future<void> changeBookVoiceData(int contentId) async {
    //final SharedPreferences prefs = await SharedPreferences.getInstance();
    final data = await dataRepository.changeBookVoiceRepository(contentId);
    // final serializedData =
    //     data.map((item) => json.encode(item.toJson())).toList();
    // _dataMap[contentId] = data; // 가져온 데이터를 Map에 저장합니다.
    print("🔄 change voice: $data");
    emit(data);
  }
}
