import 'dart:convert';
import 'dart:math';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yoggo/models/user.dart';
import 'package:yoggo/size_config.dart';
import '../component/globalCubit/user/user_cubit.dart';
import 'package:amplitude_flutter/amplitude.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  late UserCubit userCubit;

  String generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<void> signInWithGoogle(BuildContext context) async {
    userCubit = context.read<UserCubit>();
    //userCubit = context.watch<UserCubit>(listen: false);

    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    if (googleUser != null) {
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      UserModel user = UserModel(
        //name: googleUser.displayName!,
        //email: googleUser.email,
        //providerId: googleUser.id,
        idToken: googleAuth.idToken!,
        provider: 'google',
      );

      //googleUser.authentication.accessToken을 넘겨라 -> verify를 google에 해라. -> token을 다시 넘겨줘라
      var url = Uri.parse('${dotenv.get("API_SERVER")}auth/login');
      var response = await http.post(url,
          headers: {'Content-Type': 'application/json'},
          body: json.encode(user.toJson()));

      if (response.statusCode == 200 || response.statusCode == 201) {
        // 로그인 성공
        var responseData = json.decode(response.body);
        var token = responseData['token'];
        var purchase = responseData['purchase'];
        var record = responseData['record'];
        var username = responseData['username'];
        var prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        await prefs.setBool('purchase', purchase);
        await prefs.setBool('record', record);
        await prefs.setString('username', username);

        // await Navigator.push(context,
        //     MaterialPageRoute(builder: (context) => const HomeScreen()));
        //print(username); 기존 코드
        //await userCubit.login(username, 'email', purchase, record, false);
        await userCubit.fetchUser();
        final state = userCubit.state;
        if (state.isDataFetched) {
          OneSignal.login(state.userId.toString());
          //OneSignal.shared.setExternalUserId(state.userId.toString());
          amplitude.setUserId(state.userId.toString());
          amplitude
              .setUserProperties({'subscribe': purchase, 'record': record});
          LogInResult result = await Purchases.logIn(state.userId.toString());
          Navigator.of(context).pop();
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //       builder: (context) => const Purchase()), //HomeScreen()),
          // );
        }
      } else {
        // 로그인 실패
        print('로그인 실패. 상태 코드: ${response.statusCode}');
      }
    }
  }

  Future<void> signInWithApple(BuildContext context) async {
    userCubit = context.read<UserCubit>();
    // Trigger the authentication flow
    final rawNonce = generateNonce();
    final nonce = sha256ofString(rawNonce);
    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: nonce,
    );
    String? name = appleCredential.givenName;
    AppleUserModel user;
    if (name != null && name.isNotEmpty) {
      user = AppleUserModel(
        idToken: appleCredential.identityToken!,
        name: appleCredential.givenName!,
        // email: appleCredential.email,
        // providerId: appleCredential.userIdentifier!,
        provider: 'apple',
      );
    } else {
      user = AppleUserModel(
        idToken: appleCredential.identityToken!,
        name: 'User',
        // email: appleCredential.email,
        // providerId: appleCredential.userIdentifier!,
        provider: 'apple',
      );
    }
    var url = Uri.parse('${dotenv.get("API_SERVER")}auth/applelogin');
    var response = await http.post(url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(user.toJson()));

    if (response.statusCode == 200 || response.statusCode == 201) {
      // 로그인 성공
      var responseData = json.decode(response.body);
      var token = responseData['token'];
      var purchase = responseData['purchase'];
      var record = responseData['record'];
      var username = responseData['username'];
      var prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      await prefs.setBool('purchase', purchase);
      await prefs.setBool('record', record);
      await prefs.setString('username', username);

      // await Navigator.push(context,
      //     MaterialPageRoute(builder: (context) => const HomeScreen()));
      //print(username); 기존 코드
      //await userCubit.login(username, 'email', purchase, record, false);
      await userCubit.fetchUser();
      final state = userCubit.state;
      if (state.isDataFetched) {
        OneSignal.login(state.userId.toString());
        //OneSignal.shared.setExternalUserId(state.userId.toString());
        amplitude.setUserId(state.userId.toString());
        amplitude.setUserProperties({'subscribe': purchase, 'record': record});
        LogInResult result = await Purchases.logIn(state.userId.toString());
        Navigator.of(context).pop();
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _sendSignInViewEvent();
  }

  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static Amplitude amplitude = Amplitude.getInstance();

  @override
  Widget build(BuildContext context) {
    final userCubit = context.watch<UserCubit>();
    final userState = userCubit.state;
    SizeConfig().init(context);
    return Scaffold(
      body: Stack(
        children: [
          // 배경 이미지
          Positioned.fill(
            child: Image.asset(
              'lib/images/bkground.png', // 배경 이미지 파일 경로 (PNG 형식)
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 1 * SizeConfig.defaultSize!,
                  ),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      // crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 1 * SizeConfig.defaultSize!,
                        ),
                        IconButton(
                          icon: Icon(Icons.clear,
                              size: 3 * SizeConfig.defaultSize!),
                          onPressed: () {
                            _sendSigninXClickEvent();
                            Navigator.of(context).pop();
                          },
                        )
                      ]),
                  Text('LOVEL', // 원하는 텍스트를 여기에 입력하세요
                      style: TextStyle(
                        fontSize: 8 * SizeConfig.defaultSize!,
                        color: Colors.black,
                        fontFamily: 'modak',
                      )),
                  SizedBox(height: 0 * SizeConfig.defaultSize!),
                  Text(
                    'Unlimited linkage between devices through your account', // 원하는 텍스트를 여기에 입력하세요
                    style: TextStyle(
                      fontSize: 2.2 * SizeConfig.defaultSize!,
                      color: Colors.black,
                      fontFamily: 'font-basic',
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 4 * SizeConfig.defaultSize!),
                  GestureDetector(
                      onTap: () {
                        _sendSigninGoogleClickEvent();
                        signInWithGoogle(context);
                      },
                      child: Stack(children: [
                        Container(
                          height: 4.5 * SizeConfig.defaultSize!,
                          width: 27.5 * SizeConfig.defaultSize!,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(
                                1.5 * SizeConfig.defaultSize!),
                          ),
                        ),
                        Positioned(
                          top: 0,
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'lib/images/logo-google.png', // 본인의 이미지 경로로 변경
                                height: 24.0,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Continue with Google',
                                style: TextStyle(
                                  fontSize: 1.9 * SizeConfig.defaultSize!,
                                  color: Colors.black,
                                  fontFamily: 'Roboto',
                                  // fontWeight: FontWeight.w600
                                ),
                              ),
                            ],
                          ),
                        )
                      ])),
                  SizedBox(height: 2 * SizeConfig.defaultSize!),
                  GestureDetector(
                      onTap: () {
                        _sendSigninAppleClickEvent();
                        signInWithApple(context);
                      },
                      child: Stack(children: [
                        Container(
                          height: 4.5 * SizeConfig.defaultSize!,
                          width: 27.5 * SizeConfig.defaultSize!,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(
                                1.5 * SizeConfig.defaultSize!),
                          ),
                        ),
                        Positioned(
                          top: 0,
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'lib/images/logo-apple.png', // 본인의 이미지 경로로 변경
                                height: 24.0,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Continue with Apple',
                                style: TextStyle(
                                  fontSize: 1.9 * SizeConfig.defaultSize!,
                                  color: Colors.black,
                                  fontFamily: 'Roboto',
                                  // fontWeight: FontWeight.w600
                                ),
                              ),
                            ],
                          ),
                        )
                      ])),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Future<void> _sendSignInViewEvent() async {
    try {
      // 이벤트 로깅
      await analytics.logEvent(
        name: 'sign_in_view',
        parameters: <String, dynamic>{},
      );
      await amplitude.logEvent(
        'sign_in_view',
        eventProperties: {},
      );
    } catch (e) {
      // 이벤트 로깅 실패 시 에러 출력
      print('Failed to log event: $e');
    }
  }

  Future<void> _sendSigninXClickEvent() async {
    try {
      // 이벤트 로깅
      await analytics.logEvent(
        name: 'sign_in_x_click',
        parameters: <String, dynamic>{},
      );
      await amplitude.logEvent(
        'sign_in_x_click',
        eventProperties: {},
      );
    } catch (e) {
      // 이벤트 로깅 실패 시 에러 출력
      print('Failed to log event: $e');
    }
  }

  static Future<void> _sendSigninGoogleClickEvent() async {
    try {
      // 이벤트 로깅
      await analytics.logEvent(
        name: 'sign_in_google_click',
        parameters: <String, dynamic>{},
      );
      await amplitude.logEvent(
        'sign_in_google_click',
        eventProperties: {},
      );
    } catch (e) {
      // 이벤트 로깅 실패 시 에러 출력
      print('Failed to log event: $e');
    }
  }

  static Future<void> _sendSigninAppleClickEvent() async {
    try {
      // 이벤트 로깅
      await analytics.logEvent(
        name: 'sign_in_apple_click',
        parameters: <String, dynamic>{},
      );

      await amplitude.logEvent(
        'sign_in_apple_click',
        eventProperties: {},
      );
    } catch (e) {
      // 이벤트 로깅 실패 시 에러 출력
      print('Failed to log event: $e');
    }
  }
}
