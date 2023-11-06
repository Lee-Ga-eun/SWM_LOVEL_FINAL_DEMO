import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yoggo/size_config.dart';
import 'globalCubit/user/user_cubit.dart';
import 'package:amplitude_flutter/amplitude.dart';
import 'package:easy_localization/easy_localization.dart';
import '../component/rec.dart';

class RecInfo extends StatefulWidget {
  final FirebaseRemoteConfig abTest;
  final int contentId;
  const RecInfo({super.key, required this.abTest, required this.contentId});

  @override
  _RecInfoState createState() => _RecInfoState();
}

String mypath = '';

class _RecInfoState extends State<RecInfo> {
  @override
  void initState() {
    super.initState();
    _sendRecInfoViewEvent();

    // TODO: Add initialization code
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
                          // Text(
                          //   '녹음-안내',
                          //   style: TextStyle(
                          //     fontSize: SizeConfig.defaultSize! * 2.2,
                          //     fontFamily: 'font-basic'.tr(),
                          //   ),
                          // ).tr(),
                          SizedBox(
                            height: 1.8 * SizeConfig.defaultSize!,
                          ),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  // crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Image(
                                      image: AssetImage('lib/images/quite.png'),
                                    ),
                                    SizedBox(
                                      height: SizeConfig.defaultSize! * 2,
                                    ),
                                    Text(
                                      "녹음-안내-1",
                                      style: TextStyle(
                                          fontSize: SizeConfig.defaultSize! *
                                              2 *
                                              double.parse('font-ratio'.tr()),
                                          fontWeight: FontWeight.w400,
                                          fontFamily: 'font-basic'.tr()),
                                      textAlign: TextAlign.center,
                                    ).tr()
                                  ],
                                ),
                                SizedBox(
                                  width: SizeConfig.defaultSize! * 4,
                                ),
                                Column(
                                  children: [
                                    const Image(
                                      image:
                                          AssetImage('lib/images/speach1.png'),
                                    ),
                                    SizedBox(
                                      height: SizeConfig.defaultSize! * 2,
                                    ),
                                    Text(
                                      "녹음-안내-2",
                                      style: TextStyle(
                                        fontSize: SizeConfig.defaultSize! *
                                            2 *
                                            double.parse('font-ratio'.tr()),
                                        fontWeight: FontWeight.w400,
                                        fontFamily: 'font-basic'.tr(),
                                      ),
                                      textAlign: TextAlign.center,
                                    ).tr()
                                  ],
                                ),
                                SizedBox(
                                  width: SizeConfig.defaultSize! * 4,
                                ),
                                Column(
                                  children: [
                                    const Image(
                                      image:
                                          AssetImage('lib/images/thumbsUp.png'),
                                    ),
                                    SizedBox(
                                      height: SizeConfig.defaultSize! * 2,
                                    ),
                                    Text(
                                      "녹음-안내-3",
                                      style: TextStyle(
                                        fontSize: SizeConfig.defaultSize! *
                                            2 *
                                            double.parse('font-ratio'.tr()),
                                        fontWeight: FontWeight.w400,
                                        fontFamily: 'font-basic'.tr(),
                                      ),
                                      textAlign: TextAlign.center,
                                    ).tr()
                                  ],
                                ),
                                SizedBox(
                                  width: SizeConfig.defaultSize! * 4,
                                ),
                                Column(
                                  children: [
                                    const Image(
                                      image:
                                          AssetImage('lib/images/infinite.png'),
                                    ),
                                    SizedBox(
                                      height: SizeConfig.defaultSize! * 2,
                                    ),
                                    Text(
                                      "녹음-안내-4",
                                      style: TextStyle(
                                        fontSize: SizeConfig.defaultSize! *
                                            2 *
                                            double.parse('font-ratio'.tr()),
                                        fontWeight: FontWeight.w400,
                                        fontFamily: 'font-basic'.tr(),
                                      ),
                                      textAlign: TextAlign.center,
                                    ).tr(),
                                    // Positioned(
                                    //     child: IconButton(
                                    //   padding: EdgeInsets.only(
                                    //       left: SizeConfig.defaultSize! * 13,
                                    //       top: SizeConfig.defaultSize! * 2),
                                    //   icon: Icon(
                                    //     Icons.arrow_circle_right_outlined,
                                    //     size: SizeConfig.defaultSize! * 4,
                                    //     color: Colors.black,
                                    //   ),
                                    //   onPressed: () {
                                    //     Navigator.push(
                                    //       context,
                                    //       MaterialPageRoute(
                                    //         builder: (context) => const Rec(
                                    //             // 다음 화면으로 contetnVoiceId를 가지고 이동
                                    //             ),
                                    //       ),
                                    //     );
                                    //   },
                                    // ))
                                  ],
                                ),
                              ]),
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
                // Expanded(
                //   flex: 12,
                //   child: Row(
                //     children: [
                //       Expanded(
                //         flex: 1,
                //         child: Container(color: const Color.fromARGB(0, 0, 100, 0)),
                //       ),
                //       Expanded(
                //         flex: 8,
                //         child: Container(color: const Color.fromARGB(0, 0, 100, 0)),
                //       ),
                //       Expanded(
                //           flex: 1,
                //           child: Row(
                //               mainAxisAlignment: MainAxisAlignment.end,
                //               children: [
                //                 IconButton(
                //                   padding: EdgeInsets.only(
                //                       //  left: SizeConfig.defaultSize! * 13,
                //                       // top: SizeConfig.defaultSize! * 2,
                //                       right: SizeConfig.defaultSize! * 4),
                //                   icon: Icon(
                //                     Icons.arrow_forward,
                //                     size: 3 * SizeConfig.defaultSize!,
                //                     color: Colors.black,
                //                   ),
                //                   onPressed: () {
                //                     Navigator.push(
                //                       context,
                //                       MaterialPageRoute(
                //                         builder: (context) => const Rec(
                //                             // 다음 화면으로 contetnVoiceId를 가지고 이동
                //                             ),
                //                       ),
                //                     );
                //                   },
                //                 ),
                //               ])),
                //     ],
                //   ),
                // ),
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
