import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yoggo/component/rec_end.dart';
import 'package:yoggo/size_config.dart';
import 'globalCubit/user/user_cubit.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http_parser/http_parser.dart';
import 'package:amplitude_flutter/amplitude.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:easy_localization/easy_localization.dart';

class RecLoading extends StatefulWidget {
  final void Function(String path)? onStop;
  final String path;
  bool? retry; // retry페이지에서 넘어왔을 경우

  RecLoading({
    Key? key,
    this.onStop,
    required this.path,
    this.retry,
  }) : super(key: key);

  @override
  _RecLoadingState createState() => _RecLoadingState();
}

class _RecLoadingState extends State<RecLoading> {
  late String token;

  Future<void> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      token = prefs.getString('token')!;
    });
  }

  Future<void> sendRecord() async {
    String audioUrl = widget.path;
    widget.onStop?.call(audioUrl);
    String recordName = audioUrl.split('/').last;

    final UserCubit userCubit;
    var url = Uri.parse('${dotenv.get("API_SERVER")}producer/record');

    var request = http.MultipartRequest('POST', url);
    request.headers['Authorization'] = 'Bearer $token';
    request.files.add(
      await http.MultipartFile.fromPath('recordUrl', audioUrl,
          contentType: MediaType('audio', 'x-wav')),
    );
    request.fields['recordName'] = recordName;
    var response = await request.send();
    if (response.statusCode == 200) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
    } else {}
  }

  Future<void> retryRecord() async {
    var url = Uri.parse('https://yoggo-server.fly.dev/user/retryRecord');

    var request = http.MultipartRequest('GET', url);
    request.headers['Authorization'] = 'Bearer $token';

    var response = await request.send();
    if (response.statusCode == 200) {
    } else {}
  }

  Future<void> _callApi() async {
    if (widget.retry != null) {
      if (widget.retry == true) {
        await retryRecord();
      }
    }
    await sendRecord();
    Amplitude.getInstance()
        .setUserProperties({'subscribe': true, 'record': true});
  }

  Future<void> _callQueuebitFunction() async {
    final userCubit = BlocProvider.of<UserCubit>(context);
    await userCubit.fetchUser();
  }

  @override
  void initState() {
    super.initState();
    _initializeAll();
  }

  Future<void> _initializeAll() async {
    await getToken();
    _processLoading();
  }

  Future<void> _processLoading() async {
    try {
      await _callApi();
      await _callQueuebitFunction();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const RecEnd()),
      );
    } catch (e) {
      print("Error occurred during loading: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('lib/images/bkground.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFFFA91A),
              ),
            ),
            SizedBox(
              height: SizeConfig.defaultSize! * 2,
            ),
            Text(
              'Do not exit the screen. Your precious voice is being transmitted. \nIf you leave the screen, the process will be erased.',
              style: TextStyle(
                  fontFamily: 'Molengo',
                  fontSize: SizeConfig.defaultSize! * 2.5),
              textAlign: TextAlign.center,
            ).tr()
          ],
        ),
      ),
    );
  }
}
