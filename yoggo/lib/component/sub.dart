// import 'dart:async';
// import 'package:firebase_analytics/firebase_analytics.dart';
// import 'package:flutter/gestures.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:http/http.dart' as http;
// import 'package:flutter/material.dart';
// import 'package:in_app_purchase/in_app_purchase.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:yoggo/component/sign.dart';
// import 'package:yoggo/component/rec_info.dart';
// import 'package:yoggo/component/sign_and.dart';
// import 'package:yoggo/size_config.dart';
// import 'dart:io' show Platform;

// import 'globalCubit/user/user_cubit.dart';
// import 'package:amplitude_flutter/amplitude.dart';
// import 'package:purchases_flutter/purchases_flutter.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';

// class Purchase extends StatefulWidget {
//   const Purchase({super.key});

//   @override
//   _PurchaseState createState() => _PurchaseState();
// }

// class AppData {
//   static final AppData _appData = AppData._internal();

//   bool entitlementIsActive = false;
//   String appUserID = '';

//   factory AppData() {
//     return _appData;
//   }
//   AppData._internal();
// }

// class _PurchaseState extends State<Purchase> {
//   final InAppPurchase _inAppPurchase = InAppPurchase.instance;
//   List<ProductDetails> view = [];
//   late String token;
//   Future fetch() async {
//     final bool available = await InAppPurchase.instance.isAvailable();
//     if (available) {
//       // 제품 정보를 로드
//       const Set<String> ids = <String>{'product1'};
//       ProductDetailsResponse res =
//           await InAppPurchase.instance.queryProductDetails(ids);
//       view = res.productDetails;

//       _inAppPurchase.purchaseStream.listen((List<PurchaseDetails> event) {
//         PurchaseDetails e = event[0];
//         print(
//             "📌 EVENT $e - ${e.status} - ${e.productID} - ${e.pendingCompletePurchase}");

//         /// 구매 여부 pendingCompletePurchase - 승인 true / 취소 false
//         if (e.pendingCompletePurchase) {
//           if (!mounted) return;
//           _inAppPurchase.completePurchase(e);
//           if (e.status == PurchaseStatus.error) return;
//           if (e.status == PurchaseStatus.canceled) return;
//           if (e.status == PurchaseStatus.purchased ||
//               e.status == PurchaseStatus.restored) {
//             successPurchase();
//             _sendSubSuccessEvent();
//             UserCubit().fetchUser();
//             amplitude.setUserProperties({'subscribe': true});
//             Navigator.of(context)
//                 .push(MaterialPageRoute(builder: (context) => const RecInfo()));
//           }
//         }
//       });
//     }
//     if (!mounted) return;
//     setState(() {});
//   }

//   @override
//   void initState() {
//     Future(fetch);
//     super.initState();
//     getToken();
//     _sendSubViewEvent();

//     // TODO: Add initialization code
//   }

//   Future<void> getToken() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     setState(() {
//       token = prefs.getString('token')!;
//     });
//   }

//   Future<void> successPurchase() async {
//     await getToken();
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.setBool('purchase', true);
//     var url = Uri.parse('${dotenv.get("API_SERVER")}user/successPurchase');
//     var response = await http.post(
//       url,
//       headers: {
//         'Content-Type': 'application/json',
//         'Authorization': 'Bearer $token',
//       },
//     );
//     if (response.statusCode == 200) {
//       // _sendSubSuccessEvent();
//       print('정보 등록 완료');
//     } else {
//       _sendSubFailEvent(response.statusCode);
//       throw Exception('Failed to start inference');
//     }
//   }

//   Future<void> startPurchase() async {
//     try {
//       Offerings? offerings = await Purchases.getOfferings();
//       if (offerings.current != null) {
//         var myProductList = offerings.current!.availablePackages;
//         CustomerInfo customerInfo =
//             await Purchases.purchasePackage(myProductList[0]);
//         EntitlementInfo? entitlement = customerInfo.entitlements.all['pro'];
//         final appData = AppData();
//         appData.entitlementIsActive = entitlement?.isActive ?? false;
//         if (entitlement!.isActive) {
//           successPurchase();
//         }
//         successPurchase();
//         // Display packages for sale
//       }
//     } catch (e) {
//       // optional error handling
//     }

//     // const Set<String> products = {'product1'};
//     // final ProductDetailsResponse response =
//     //     await InAppPurchase.instance.queryProductDetails(products);
//     // if (response.notFoundIDs.isNotEmpty) {
//     //   print('제품이 없어요');
//     //   return;
//     // }

//     // final ProductDetails productDetails = response.productDetails.first;

//     // final PurchaseParam purchaseParam = PurchaseParam(
//     //   productDetails: productDetails,
//     // );
//     // try {
//     //   final bool success = await InAppPurchase.instance.buyNonConsumable(
//     //     purchaseParam: purchaseParam,
//     //   );
//     // } catch (error) {
//     //   // 결제 실패
//     //   print('결제 실패했어요');
//     // }
//   }

//   @override
//   void dispose() {
//     // TODO: Add cleanup code
//     //_subscription.cancel();
//     super.dispose();
//   }

//   static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
//   final Amplitude amplitude = Amplitude.getInstance();

//   @override
//   Widget build(BuildContext context) {
//     final userCubit = context.watch<UserCubit>();
//     final userState = userCubit.state;
//     SizeConfig().init(context);
//     return Scaffold(
//         body: Container(
//       decoration: const BoxDecoration(
//         image: DecorationImage(
//           image: AssetImage('lib/images/bkground.png'),
//           fit: BoxFit.cover,
//         ),
//       ),
//       child: SafeArea(
//         bottom: false,
//         top: false,
//         child: Column(children: [
//           //Expanded(
//           //flex: 7,
//           //child:
//           SizedBox(height: SizeConfig.defaultSize! * 2),
//           Stack(
//             alignment: Alignment.center,
//             children: [
//               Column(children: [
//                 const SizedBox(height: 10),
//                 SizedBox(
//                   height: 50,
//                   //   color: Colors.red,
//                   child: Row(
//                     crossAxisAlignment: CrossAxisAlignment.end,
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Text(
//                         'NOW, Read ',
//                         style: TextStyle(
//                           fontFamily: 'Molengo',
//                           fontSize: SizeConfig.defaultSize! * 2.8,
//                         ),
//                       ),
//                       Platform.isAndroid
//                           ? Container(
//                               //color: Colors.red,
//                               child: Text(
//                                 'LOVEL',
//                                 style: TextStyle(
//                                   fontFamily: 'Modak',
//                                   fontSize: SizeConfig.defaultSize! * 4.8,
//                                 ),
//                               ),
//                             )
//                           : Text(
//                               'LOVEL',
//                               style: TextStyle(
//                                 fontFamily: 'Modak',
//                                 fontSize: SizeConfig.defaultSize! * 4.8,
//                               ),
//                             ),
//                       Text(
//                         ' with your own voice.',
//                         style: TextStyle(
//                           fontFamily: 'Molengo',
//                           fontSize: SizeConfig.defaultSize! * 2.8,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ]),
//               Positioned(
//                 left: 2 * SizeConfig.defaultSize!,
//                 child: IconButton(
//                   icon: Icon(Icons.clear, size: 3 * SizeConfig.defaultSize!),
//                   onPressed: () {
//                     Navigator.of(context).pop();
//                   },
//                 ),
//               ),
//               // ios 앱 심사를 위한 restore 버튼
//               Platform.isIOS
//                   ? Positioned(
//                       // top: -0.1 * SizeConfig.defaultSize!,
//                       top: 0,
//                       right: 3 * SizeConfig.defaultSize!,
//                       child: GestureDetector(
//                           onTap: () async {
//                             try {
//                               if (userState.login == false) {
//                                 Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                       builder: (context) => Platform.isIOS
//                                           ? const Login()
//                                           : const LoginAnd()), //HomeScreen()),
//                                 );
//                               } else {
//                                 CustomerInfo customerInfo =
//                                     await Purchases.restorePurchases();
//                                 EntitlementInfo? entitlement =
//                                     customerInfo.entitlements.all['pro'];
//                                 if (entitlement != null) {
//                                   if (entitlement.isActive) {
//                                     successPurchase();
//                                   }
//                                 }
//                               }

//                               // ... check restored purchaserInfo to see if entitlement is now active
//                             } on PlatformException {
//                               // Error restoring purchases
//                             }
//                           },
//                           child: Container(
//                             width: 15 * SizeConfig.defaultSize!,
//                             height: 3 * SizeConfig.defaultSize!,
//                             decoration: BoxDecoration(
//                                 color: const Color.fromARGB(128, 255, 255, 255),
//                                 borderRadius: BorderRadius.all(Radius.circular(
//                                     SizeConfig.defaultSize! * 1))),
//                             child: Center(
//                                 child: Text(
//                               'Already Purchase?',
//                               style: TextStyle(
//                                   fontFamily: 'Molengo',
//                                   fontSize: SizeConfig.defaultSize! * 1.5),
//                             )),
//                           )),
//                     )
//                   : Container(),
//               // ios 앱 심사를 위한 restore 버튼
//             ],
//           ),
//           SizedBox(height: SizeConfig.defaultSize! * 1.5),
//           //),
//           Container(
//             // color: Colors.yellow,
//             //width: 72 * SizeConfig.defaultSize!,
//             //height: 29.4 * SizeConfig.defaultSize!,
//             //decoration: BoxDecoration(
//             //color: const Color.fromARGB(128, 255, 255, 255),
//             //borderRadius: BorderRadius.all(
//             //Radius.circular(SizeConfig.defaultSize! * 3))),
//             // child:
//             //Padding(
//             //padding: const EdgeInsets.symmetric(horizontal: 0),
//             child: Column(
//               //mainAxisAlignment: MainAxisAlignment.end,
//               children: [
//                 Text(
//                   "Just hearing your voice activates children's brains.\nRead all upcoming books to your child with your own voice.",
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                       fontFamily: 'Molengo',
//                       fontSize: SizeConfig.defaultSize! * 1.6,
//                       color: const Color.fromARGB(255, 104, 104, 104)),
//                 ),
//                 SizedBox(
//                   height: Platform.isAndroid
//                       ? SizeConfig.defaultSize! * 1
//                       : SizeConfig.defaultSize! * 1.5,
//                 ),
//                 Stack(children: [
//                   // 다른 위젯들...
//                   Align(
//                       alignment: Alignment.topCenter,
//                       // right: SizeConfig.defaultSize! * 12,
//                       // top: SizeConfig.defaultSize! * 1.4,
//                       child: GestureDetector(
//                           onTap: () async {
//                             // 버튼 클릭 시 동작
//                             _sendSubPayClickEvent();
//                             userState.login
//                                 ? await startPurchase()
//                                 : Navigator.push(
//                                     context,
//                                     MaterialPageRoute(
//                                         builder: (context) => Platform.isIOS
//                                             ? const Login()
//                                             : const LoginAnd()), //HomeScreen()),
//                                   );
//                             //await startPurchase();
//                           },
//                           child: SizedBox(
//                             width: 31.1 * SizeConfig.defaultSize!,
//                             height: 13 * SizeConfig.defaultSize!,
//                             child: Container(
//                               decoration: BoxDecoration(
//                                   color:
//                                       const Color.fromARGB(255, 255, 255, 255)
//                                           .withOpacity(0.4),
//                                   borderRadius: BorderRadius.circular(
//                                       SizeConfig.defaultSize! * 1.5),
//                                   border: Border.all(
//                                     width: SizeConfig.defaultSize! * 0.25,
//                                     color:
//                                         const Color.fromARGB(255, 255, 167, 26),
//                                   )),
//                               child: Stack(
//                                 children: [
//                                   Container(
//                                     height: SizeConfig.defaultSize! * 4,
//                                     decoration: BoxDecoration(
//                                       color: const Color.fromARGB(
//                                           255, 255, 167, 26),
//                                       borderRadius: BorderRadius.circular(
//                                           SizeConfig.defaultSize! * 1.15),
//                                     ),
//                                   ),
//                                   Padding(
//                                     padding: EdgeInsets.only(
//                                         top: SizeConfig.defaultSize! * 0.4),
//                                     child: Align(
//                                       alignment: Alignment.topCenter,
//                                       child: Text(
//                                         '70% OFF',
//                                         style: TextStyle(
//                                             fontFamily: 'Molengo',
//                                             fontSize:
//                                                 SizeConfig.defaultSize! * 2.3),
//                                       ),
//                                     ),
//                                   ),
//                                   Align(
//                                     alignment: Alignment.center,
//                                     child: Column(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.center,
//                                       children: [
//                                         SizedBox(
//                                           height: SizeConfig.defaultSize! * 2.5,
//                                         ),
//                                         Row(
//                                           mainAxisAlignment:
//                                               MainAxisAlignment.center,
//                                           children: [
//                                             Text(
//                                               '\$5.99',
//                                               textAlign: TextAlign.center,
//                                               style: TextStyle(
//                                                 color: Colors.black,
//                                                 fontSize:
//                                                     4 * SizeConfig.defaultSize!,
//                                                 fontFamily: 'Molengo',
//                                               ),
//                                             ),
//                                             Padding(
//                                               padding: EdgeInsets.only(
//                                                   top: SizeConfig.defaultSize! *
//                                                       1.8),
//                                               child: Text(
//                                                 '가격-단위',
//                                                 //  textAlign: TextAlign.start,
//                                                 style: TextStyle(
//                                                   color: Colors.black,
//                                                   fontSize: 2.3 *
//                                                       SizeConfig.defaultSize!,
//                                                   fontFamily: 'Molengo',
//                                                 ),
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                         Text(
//                                           '\$19.99',
//                                           style: TextStyle(
//                                               color: const Color.fromARGB(
//                                                   136, 0, 0, 0),
//                                               fontFamily: 'Molengo',
//                                               decoration:
//                                                   TextDecoration.lineThrough,
//                                               fontSize: 1.9 *
//                                                   SizeConfig.defaultSize!),
//                                         )
//                                       ],
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           )))
//                 ]),
//                 SizedBox(
//                   height: Platform.isAndroid
//                       ? 2.2 * SizeConfig.defaultSize!
//                       : SizeConfig.defaultSize!,
//                 ),
//                 Stack(children: [
//                   // 다른 위젯들...
//                   Align(
//                       alignment: Alignment.topCenter,
//                       // right: SizeConfig.defaultSize! * 12,
//                       // top: SizeConfig.defaultSize! * 1.4,
//                       child: GestureDetector(
//                           onTap: () async {
//                             // 버튼 클릭 시 동작
//                             _sendSubPayClickEvent();
//                             userState.login
//                                 ? await startPurchase()
//                                 : Navigator.push(
//                                     context,
//                                     MaterialPageRoute(
//                                         builder: (context) => Platform.isIOS
//                                             ? const Login()
//                                             : const LoginAnd()), //HomeScreen()),
//                                   );
//                             //await startPurchase();
//                           },
//                           child: SizedBox(
//                             width: 37 * SizeConfig.defaultSize!,
//                             height: 4.5 * SizeConfig.defaultSize!,
//                             child: Container(
//                               decoration: BoxDecoration(
//                                 color: const Color.fromARGB(227, 251, 82, 60),
//                                 borderRadius: BorderRadius.circular(30),
//                                 boxShadow: [
//                                   BoxShadow(
//                                     color: Colors.black.withOpacity(0.2),
//                                     offset: const Offset(0, 3),
//                                     blurRadius: 6,
//                                     spreadRadius: 0,
//                                   ),
//                                 ],
//                               ),
//                               child: Stack(
//                                 children: [
//                                   Positioned(
//                                     right: 1 * SizeConfig.defaultSize!,
//                                     top: 0.75 * SizeConfig.defaultSize!,
//                                     child: Icon(
//                                       Icons.chevron_right,
//                                       color: Colors.white,
//                                       size: SizeConfig.defaultSize! * 3,
//                                     ),
//                                   ),
//                                   Center(
//                                     child: Text(
//                                       'Start 7-days FREE Trial',
//                                       textAlign: TextAlign.center,
//                                       style: TextStyle(
//                                         color: Colors.white,
//                                         fontSize: 2.3 * SizeConfig.defaultSize!,
//                                         fontFamily: 'Molengo',
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           )))
//                 ]),
//                 const SizedBox(
//                   height: 10,
//                 ),
//                 SizedBox(
//                     width: 61 * SizeConfig.defaultSize!,
//                     height: Platform.isAndroid
//                         ? SizeConfig.defaultSize! * 2.5
//                         : SizeConfig.defaultSize! * 5.5,
//                     child: Platform.isAndroid
//                         ? Text(
//                             "After free trial, LOVEL monthly subscription is \$5.99.",
//                             style: TextStyle(
//                               fontFamily: 'Molengo',
//                               fontSize: SizeConfig.defaultSize! * 1.5,
//                               color: Colors.black,
//                             ),
//                             textAlign: TextAlign.center,
//                           )
//                         : Column(children: [
//                             Center(
//                                 child: Text(
//                                     "Subscription Terms: After free trial, LOVEL monthly subscription is \$5.99, automatically renews unless turned off in Account Settings at least 24h before current period ends. Payment is charged ",
//                                     style: TextStyle(
//                                         fontSize: 1.5 * SizeConfig.defaultSize!,
//                                         fontFamily: 'Molengo'))),
//                             RichText(
//                                 text: TextSpan(children: [
//                               TextSpan(
//                                   style: TextStyle(
//                                       fontSize: 1.5 * SizeConfig.defaultSize!,
//                                       fontFamily: 'Molengo',
//                                       color: Colors.black),
//                                   text:
//                                       "to your iTunes account. By tapping Continue, you agree to our "),
//                               TextSpan(
//                                   text: "구독-약관",
//                                   style: TextStyle(
//                                     fontSize: 1.5 * SizeConfig.defaultSize!,
//                                     fontFamily: 'Molengo',
//                                     color: Colors.black,
//                                     decoration: TextDecoration.underline,
//                                   ),
//                                   recognizer: TapGestureRecognizer()
//                                     ..onTap = () {
//                                       launch(
//                                           'http://www.apple.com/legal/itunes/appstore/dev/stdeula');
//                                     }),
//                               TextSpan(
//                                 text: " and ",
//                                 style: TextStyle(
//                                     fontSize: 1.5 * SizeConfig.defaultSize!,
//                                     fontFamily: 'Molengo',
//                                     color: Colors.black),
//                               ),
//                               TextSpan(
//                                   text: "구독-개인정보처리방침.",
//                                   style: TextStyle(
//                                     fontSize: 1.5 * SizeConfig.defaultSize!,
//                                     fontFamily: 'Molengo',
//                                     color: Colors.black,
//                                     decoration: TextDecoration.underline,
//                                   ),
//                                   recognizer: TapGestureRecognizer()
//                                     ..onTap = () {
//                                       launch(
//                                           'https://doc-hosting.flycricket.io/lovel-privacy-policy/f8c6f57c-dd5f-4b67-8859-bc4afe251396/privacy');
//                                     })
//                             ]))
//                           ]))
//               ],
//             ),
//             //),
//           ) //),
//         ]),
//       ),
//     ));
//   }

//   Future<void> _sendSubViewEvent() async {
//     try {
//       // 이벤트 로깅
//       await analytics.logEvent(
//         name: 'sub_view',
//         parameters: <String, dynamic>{},
//       );
//       await amplitude.logEvent('sub_view', eventProperties: {});
//     } catch (e) {
//       // 이벤트 로깅 실패 시 에러 출력
//       print('Failed to log event: $e');
//     }
//   }

//   Future<void> _sendSubPayClickEvent() async {
//     try {
//       // 이벤트 로깅
//       await analytics.logEvent(
//         name: 'sub_pay_click',
//         parameters: <String, dynamic>{},
//       );
//       await amplitude.logEvent(
//         'sub_pay_click',
//         eventProperties: {},
//       );
//     } catch (e) {
//       // 이벤트 로깅 실패 시 에러 출력
//       print('Failed to log event: $e');
//     }
//   }

//   Future<void> _sendSubSuccessEvent() async {
//     try {
//       // 이벤트 로깅
//       await analytics.logEvent(
//         name: 'sub_success',
//         parameters: <String, dynamic>{},
//       );
//       await amplitude.logEvent('sub_success', eventProperties: {});
//     } catch (e) {
//       // 이벤트 로깅 실패 시 에러 출력
//       print('Failed to log event: $e');
//     }
//   }

//   Future<void> _sendSubFailEvent(response) async {
//     try {
//       // 이벤트 로깅
//       await analytics.logEvent(
//         name: 'sub_fail',
//         parameters: <String, dynamic>{'response': response},
//       );
//       await amplitude
//           .logEvent('sub_fail', eventProperties: {'response': response});
//     } catch (e) {
//       // 이벤트 로깅 실패 시 에러 출력
//       print('Failed to log event: $e');
//     }
//   }
// }
