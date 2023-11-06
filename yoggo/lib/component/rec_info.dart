import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yoggo/size_config.dart';
import 'globalCubit/user/user_cubit.dart';
import 'package:amplitude_flutter/amplitude.dart';
import 'package:easy_localization/easy_localization.dart';
import '../component/rec.dart';
import 'dart:io' show File, Platform;
import 'dart:async';
import 'package:percent_indicator/percent_indicator.dart';

class RecInfo extends StatefulWidget {
  final FirebaseRemoteConfig abTest;
  final int contentId;
  const RecInfo({super.key, required this.abTest, required this.contentId});

  @override
  _RecInfoState createState() => _RecInfoState();
}

String mypath = '';

class _RecInfoState extends State<RecInfo> with SingleTickerProviderStateMixin {
  final Duration _duration = const Duration();
  final Duration _position = const Duration();
  //AudioPlayer advancedPlayer=
  AudioPlayer audioPlayer = AudioPlayer();
  final double _currentSliderValue = 0;
  bool playStart = false;
  late AnimationController _animationController;
  double percent = 0;

  //Timer timer;

  @override
  void initState() {
    super.initState();
    _sendRecInfoViewEvent();
    _initializeAnimationController();
    // TODO: Add initialization code
    //advancedPlayer = new AudioPlayer();
  }

  void _initializeAnimationController() {
    _animationController = AnimationController(
      duration: const Duration(seconds: 19), // 19초 동안 애니메이션
      vsync: this,
    );

    // Add a listener to update the LinearPercentIndicator
    _animationController.addListener(() {
      setState(() {
        percent = _animationController.value;
      });
    });
  }

  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  final Amplitude amplitude = Amplitude.getInstance();

  @override
  void dispose() {
    // TODO: Add cleanup code
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print(playStart);
    final userCubit = context.watch<UserCubit>();
    final userState = userCubit.state;
    final sw = (MediaQuery.of(context).size.width -
        MediaQuery.of(context).padding.left -
        MediaQuery.of(context).padding.right);
    final sh = (MediaQuery.of(context).size.height -
        MediaQuery.of(context).padding.top -
        MediaQuery.of(context).padding.bottom);
    SizeConfig().init(context);
    return Scaffold(
        body: Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('lib/images/bkground.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: SafeArea(
        minimum: EdgeInsets.only(
            left: 3 * SizeConfig.defaultSize!,
            right: 3 * SizeConfig.defaultSize!),
        bottom: false,
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                    // HEADER
                    flex: 14,
                    child: Row(children: [
                      Expanded(
                        flex: 1,
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: Icon(Icons.clear,
                                    size: 3 * SizeConfig.defaultSize!),
                                onPressed: () {
                                  Navigator.of(context)
                                      .popUntil((route) => route.isFirst);
                                },
                              )
                            ]),
                      ),
                      Expanded(
                        flex: 8,
                        child: Row(
                          mainAxisAlignment:
                              MainAxisAlignment.center, // 아이콘을 맨 왼쪽으로 정렬
                          children: [
                            Text(
                              'LOVEL',
                              style: TextStyle(
                                fontFamily: 'Modak',
                                fontSize: SizeConfig.defaultSize! * 5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                          flex: 1,
                          child: Container(
                              color: const Color.fromARGB(0, 0, 0, 0)))
                    ])),
                Expanded(
                    flex: 89,
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 0.5 * SizeConfig.defaultSize!,
                          ),
                          Text(
                            '녹음-안내1',
                            style: TextStyle(
                              fontSize: SizeConfig.defaultSize! * 2.2,
                              fontFamily: 'font-basic'.tr(),
                            ),
                          ).tr(),
                          Text(
                            '녹음-안내2',
                            style: TextStyle(
                              fontSize: SizeConfig.defaultSize! * 2.2,
                              fontFamily: 'font-basic'.tr(),
                            ),
                          ).tr(),
                          SizedBox(
                            height: 1.8 * SizeConfig.defaultSize!,
                          ),
                          SizedBox(
                            height: sh * 0.06,
                          ),
                          Container(
                            width: sw * 0.4,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                    SizeConfig.defaultSize! * 3),
                                color: Colors.white),
                            child: Row(
                              children: [
                                IconButton(
                                    icon: playStart
                                        ? const Icon(Icons.stop)
                                        : const Icon(Icons.play_arrow),
                                    onPressed: () async {
                                      if (playStart) {
                                        playStart = false;
                                        // 이미 애니메이션이 시작되었으면 오디오 일시 중지
                                        audioPlayer.stop();
                                        _animationController.dispose();
                                        setState(() {
                                          percent = 0;
                                          _initializeAnimationController();
                                        });
                                        // _initializeAnimationController();

                                        setState(() {
                                          playStart = false;
                                        });
                                      } else {
                                        // 애니메이션 시작 및 오디오 재생
                                        if (Platform.isAndroid) {
                                          audioPlayer.play(AssetSource(
                                              'scripts/emma-sample.wav'));
                                        } else {
                                          audioPlayer.play(AssetSource(
                                              'scripts/emma-sample.flac'));
                                        }
                                        _animationController.forward();
                                        setState(() {
                                          playStart = true;
                                        });
                                      }
                                    }),
                                LinearPercentIndicator(
                                  curve: Curves.linear,
                                  width: 0.3 * sw,
                                  animation:
                                      playStart, // 애니메이션을 playStart 변수로 제어
                                  lineHeight: 0.01 * sh,
                                  animationDuration:
                                      19000, // 오디오 길이에 따라 애니메이션 지속 시간 설정
                                  percent: percent,
                                  // playStart
                                  //     ? 1.0
                                  //     : 0.0, // 애니메이션 진행 및 중지에 따라 퍼센트 설정
                                  center: const Text(""),
                                  progressColor:
                                      const Color.fromARGB(255, 59, 59, 59),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: sh * 0.06,
                          ),
                          GestureDetector(
                            onTap: () {
                              // print("TAP");
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Rec(
                                    contentId: widget.contentId,

                                    // 다음 화면으로 contetnVoiceId를 가지고 이동
                                    abTest: widget.abTest,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                                width: 31.1 * SizeConfig.defaultSize!,
                                height: 4.5 * SizeConfig.defaultSize!,
                                decoration: ShapeDecoration(
                                  color: const Color(0xFFFFA91A),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                child: Stack(children: [
                                  Positioned(
                                      right: 1 * SizeConfig.defaultSize!,
                                      top: 0.75 * SizeConfig.defaultSize!,
                                      child: Icon(
                                        Icons.chevron_right,
                                        color: Colors.black,
                                        size: SizeConfig.defaultSize! * 3,
                                      )),
                                  Center(
                                    child: Text(
                                      "녹음안내-이동버튼",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 2.3 *
                                              SizeConfig.defaultSize! *
                                              double.parse('font-ratio'.tr()),
                                          fontFamily: 'font-book'.tr()),
                                    ).tr(),
                                  ),
                                ])),
                          )
                        ])),
                Expanded(flex: 10, child: Container())
              ],
            ),
          ],
        ),
      ),
    ));
  }

  Future<void> _sendRecInfoViewEvent() async {
    try {
      // 이벤트 로깅
      await analytics.logEvent(
        name: 'rec_info_view',
        parameters: <String, dynamic>{},
      );
      await amplitude.logEvent(
        'rec_info_view',
        eventProperties: {},
      );
    } catch (e) {
      // 이벤트 로깅 실패 시 에러 출력
      print('Failed to log event: $e');
    }
  }
}
