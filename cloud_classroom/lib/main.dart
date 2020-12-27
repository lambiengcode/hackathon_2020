import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:get/get_navigation/src/routes/transitions_type.dart';
import 'package:provider/provider.dart';
import 'package:whoru/src/app.dart';
import 'package:whoru/src/models/user.dart';
import 'package:whoru/src/services/auth.dart';
import 'package:whoru/src/utils/constants.dart';

void main() {
  // For play billing library 2.0 on Android, it is mandatory to call
  // [enablePendingPurchases](https://developer.android.com/reference/com/android/billingclient/api/BillingClient.Builder.html#enablependingpurchases)
  // as part of initializing the app.

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamProvider<User>.value(
      value: AuthService().user,
      child: ThemeProvider(
        initTheme: kLightTheme,
        child: Builder(
          builder: (context) {
            return GetMaterialApp(
              title: 'Cloud School',
              theme: ThemeProvider.of(context),
              debugShowCheckedModeBanner: false,
              initialRoute: '/root',
              defaultTransition: Transition.native,
              locale: Locale('vi', 'VN'),
              getPages: [
                GetPage(name: '/root', page: () => App()),
              ],
            );
          },
        ),
      ),
    );
  }
}
