import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:amplitude_flutter/amplitude.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yoggo/Repositories/Repository.dart';
import 'package:yoggo/component/home/view/home.dart';
import 'package:yoggo/component/home/viewModel/home_screen_cubit.dart';
import 'package:yoggo/firebase_options.dart';
import 'package:yoggo/models/anonymous.dart';
import 'package:yoggo/size_config.dart';
import 'component/globalCubit/user/user_cubit.dart';
import 'component/globalCubit/user/user_state.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'dart:io' show Platform;
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';

import 'package:appsflyer_sdk/appsflyer_sdk.dart';

Future<void> initPlatformState() async {
  await Purchases.setLogLevel(
      LogLevel.debug); // Purchases.setDebugLogsEnabled(true);

  PurchasesConfiguration? configuration;

  if (Platform.isAndroid) {
    configuration = PurchasesConfiguration('goog_wxdljqWvkKNlMpVlNSZjKnqVtQc');
  } else if (Platform.isIOS) {
    configuration = PurchasesConfiguration('appl_wPyySWQHJfhExnkjSTliaVxgpMx');
  }
  await Purchases.configure(configuration!); // Anonymous App User IDs
}

void main() async {
  // Amplitude Event 수집을 위해서 꼭 개발 모드(dev)인지 릴리즈 모드(rel)인지 설정하고 앱을 실행하도록 해요
  // 디폴트 값은 dev입니다

  String mode = 'dev';
  //String mode = 'rel';

  // 사용자 Cubit을 초기화합니다.
  await dotenv.load(fileName: ".env");
  WidgetsFlutterBinding
      .ensureInitialized(); // ensureInitialized()를 호출하여 바인딩 초기화
  AppsFlyerOptions appsFlyerOptions = AppsFlyerOptions(
      afDevKey: dotenv.get("AF_devKey"),
      showDebug: true,
      timeToWaitForATTUserAuthorization: 50, // for iOS 14.5
      disableAdvertisingIdentifier: false, // Optional field
      disableCollectASA: false); // Optional field

  AppsflyerSdk appsflyerSdk = AppsflyerSdk(appsFlyerOptions);
  appsflyerSdk.initSdk(
      registerConversionDataCallback: true,
      registerOnAppOpenAttributionCallback: true,
      registerOnDeepLinkingCallback: true);
//Remove this method to stop OneSignal Debugging

  //OneSignal.shared.setLogLevel(OSLogLevel.verbose, OSLogLevel.none);
  // Platform.isAndroid
  //     ? OneSignal.shared.setAppId(dotenv.get("ONESIGNAL_android"))
  //     : OneSignal.shared.setAppId(dotenv.get("ONESIGNAL_ios"));
  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
  Platform.isAndroid
      ? OneSignal.initialize(dotenv.get("ONESIGNAL_android"))
      : OneSignal.initialize(dotenv.get("ONESIGNAL_ios"));
  // OneSignal.shared.setAppId('2d42b96d-78df-43fe-b6d1-3899c3684ac5'); //ios

// The promptForPushNotificationsWithUserResponse function will show the iOS or Android push notification prompt. We recommend removing the following code and instead using an In-App Message to prompt for notification permission
  // OneSignal.shared.promptUserForPushNotificationPermission().then((accepted) {
  //   print("Accepted permission: $accepted");
  // });
  // OneSignal.Notifications.requestPermission(true);

  // await OneSignal.User.getDeviceState().then(
  //       (value) => {
  //         print('::::: one signal :::: ${value!.userId}'),
  //       },
  //     );
  // final Amplitude amplitude = Amplitude.getInstance();
  final Amplitude amplitude = Amplitude.getInstance();

  String amplitudeApi = mode == 'rel'
      ? dotenv.get("AMPLITUDE_API_rel")
      : dotenv.get("AMPLITUDE_API_dev");

  print(amplitudeApi);

  // Initialize SDK
  await amplitude.init(amplitudeApi);

  await amplitude.logEvent('startup');
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  FirebaseRemoteConfig remoteConfig = FirebaseRemoteConfig.instance;
  print('🤖token ${await FirebaseMessaging.instance.getToken()}');
  await remoteConfig.setConfigSettings(RemoteConfigSettings(
    fetchTimeout: const Duration(minutes: 10),
    minimumFetchInterval: const Duration(hours: 1),
  ));
  //var result = await remoteConfig.fetchAndActivate();
  //print('🍎📚: ${remoteConfig.getString('is_loading_text_enabled')}');
  final userCubit = UserCubit();
  final dataRepository = DataRepository();
  final dataCubit = DataCubit(dataRepository);

  initPlatformState();

  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  SystemChrome.setPreferredOrientations(
          [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight])
      .then((_) {
    runApp(
      EasyLocalization(
        supportedLocales: const [Locale('ko', 'KR')], //Locale('en', 'US'),
        path: 'assets/locales',
        fallbackLocale: const Locale('en', 'US'),
        // startLocale: const Locale('en', 'US'), // 초기 로캘 설정 (선택 사항)

        child: MultiBlocProvider(
          providers: [
            BlocProvider<UserCubit>.value(value: userCubit),
            RepositoryProvider(create: (context) => dataRepository),
            BlocProvider<DataCubit>.value(value: dataCubit),
            // Add more Cubits here if needed
          ],
          child: const App(),
        ),
      ),
    );
  });
}

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);
  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static FirebaseRemoteConfig remoteConfig = FirebaseRemoteConfig.instance;
  static FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: analytics);

  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  Future<void>? anonymousLoginFuture;
  String? userToken;
  String? token;
  bool? hasToken;
  static FirebaseRemoteConfig remoteConfig = FirebaseRemoteConfig.instance;

  @override
  void initState() {
    super.initState();
    // WidgetsBinding.instance.addPostFrameCallback((_) => initPlugin());

    context.read<UserCubit>().fetchUser();
    getToken();
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack);

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.white.withOpacity(0), // 투명한 배경 색상으로 설정
    ));
    AudioPlayer().setAudioContext(const AudioContext(
      iOS: AudioContextIOS(
        category: AVAudioSessionCategory.playback,
        options: [
          AVAudioSessionOptions.mixWithOthers,
          //AVAudioSessionOptions.defaultToSpeaker,  Unable to set this, will result in forced use of the speaker, the headset is invalid
        ],
      ),
    ));
  }

  // Future<void> initPlugin() async {
  //   final TrackingStatus status =
  //       await AppTrackingTransparency.trackingAuthorizationStatus;
  //   if (status == TrackingStatus.notDetermined) {
  //     await Future.delayed((const Duration(milliseconds: 200)));
  //     final TrackingStatus status =
  //         await AppTrackingTransparency.requestTrackingAuthorization();
  //     //await ATTrackingManager.requestTrackingAuthorization();
  //   }
  //   final uuid = await AppTrackingTransparency.getAdvertisingIdentifier();
  //   print("UUID: $uuid");
  // }

  Future<void> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userToken = prefs.getString('token');
      hasToken = prefs.getBool('hasToken');
    });
    if (userToken != null && token == null) {
      var url = Uri.parse('${dotenv.get("API_SERVER")}user/id');
      var response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $userToken'
        },
      );
      if (response.statusCode == 200) {
        print(userToken);
        print('hello');
        token = userToken;
        return;
      } else {
        print('hi');
        print(userToken);
        anonymousLogin();
      }
    }
  }

  Future<void> anonymousLogin() async {
    try {
      final userCredential = await FirebaseAuth.instance.signInAnonymously();
      print("Signed in with temporary account.");
      AnonymousUserModel user = AnonymousUserModel(
        anonymousId: userCredential.user!.uid,
      );

      var url = Uri.parse('${dotenv.get("API_SERVER")}auth/anonymousLogin/v2');
      var response = await http.post(url,
          headers: {'Content-Type': 'application/json'},
          body: json.encode(user.toJson()));
      if (response.statusCode == 200 || response.statusCode == 201) {
        // 로그인 성공
        var responseData = json.decode(response.body);
        token = responseData['token'];
        var purchase = responseData['purchase'];
        var record = responseData['record'];
        var username = responseData['username'];
        var point = responseData['point'];
        var prefs = await SharedPreferences.getInstance();

        await prefs.setString('token', token!);
        await prefs.setBool('record', record);
        await prefs.setString('username', username);
        await prefs.setBool('hasToken', true);

        print(responseData['token']);
        await prefs.setBool('purchase', true);
        var url = Uri.parse('${dotenv.get("API_SERVER")}user/successPurchase');
        var response2 = await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );
        if (response2.statusCode == 200) {
          // _sendSubSuccessEvent();
          print('구독 성공 완료');
        } else {
          throw Exception('Failed to start inference');
        }

        UserCubit userCubit = context.read<UserCubit>();

        await userCubit.fetchUser();

        final state = userCubit.state;
        if (state.isDataFetched) {
          OneSignal.login(state.userId.toString());

          //OneSignal.shared.setExternalUserId(state.userId.toString());
          Amplitude.getInstance().setUserId(state.userId.toString());
          Amplitude.getInstance().setUserProperties({
            'point': point,
            'subscribe': purchase,
            'record': record,
          });

          LogInResult result = await Purchases.logIn(state.userId.toString());
        }
      } else {
        // 로그인 실패
        print('로그인 실패. 상태 코드: ${response.statusCode}');
      }
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "operation-not-allowed":
          print("Anonymous auth hasn't been enabled for this project.");
          break;
        default:
          print(e);
          print("Unknown error.");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaleFactor: 1.0), // 텍스트 스케일 팩터를 1로 설정
          child: child!,
        );
      },
      home: BlocBuilder<UserCubit, UserState>(
        builder: (context, state) {
          //if (!state.isDataFetched) {
          //isDataFetched = true --> 데이터 불러왔단 뜻
          //return const SplashScreen(); //token이 없는 경우
          //} else {

          if (state.isDataFetched) {
            OneSignal.login(state.userId.toString());
            //OneSignal.shared.setExternalUserId(state.userId.toString());
            Amplitude.getInstance().setUserProperties(
                {'subscribe': state.purchase, 'record': state.record});
            // 여기서 User Property 다시 한번 설정해주기 ~~
          }
          if (token != null && hasToken == true) {
            return HomeScreen(
              abTest: remoteConfig,
            );
          } else {
            anonymousLoginFuture ??= anonymousLogin();
            return FutureBuilder(
              future: anonymousLoginFuture,
              builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return HomeScreen(abTest: remoteConfig);
                } else {
                  return Container(
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('lib/images/bkground.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Center(
                      child: LoadingAnimationWidget.fourRotatingDots(
                        color: const Color.fromARGB(255, 255, 169, 26),
                        size: 100, //SizeConfig.defaultSize! * 10,
                      ),
                    ),
                  );
                }
              },
            );
          } // token이 있는 경우
          //}
        },
      ),
    );
  }
}
