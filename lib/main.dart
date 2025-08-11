import 'package:flutter/material.dart';
import 'package:fullcomm_billing/views/billing_view/new_billing_screen.dart';
import 'package:fullcomm_billing/views/credentials/login_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fullcomm_billing/data/project_data.dart';
import 'package:fullcomm_billing/res/colors.dart';
import 'package:fullcomm_billing/view_models/billing_provider.dart';
import 'package:fullcomm_billing/view_models/credentials_provider.dart';
import 'package:fullcomm_billing/view_models/customer_provider.dart';
import 'package:fullcomm_billing/views/orders/order_detail_page.dart';
import 'package:fullcomm_billing/views/splash_screen.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isLoginScreen = prefs.getBool('seen') ?? false;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserDataProvider()),
        ChangeNotifierProvider(create: (_) => CustomersProvider()),
        ChangeNotifierProvider(create: (_) => BillingProvider()),
      ],
      child:  MyApp(isLoginScreen: isLoginScreen,),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool isLoginScreen;
  const MyApp({super.key, required this.isLoginScreen});

  @override
  Widget build(BuildContext context) {
    return OKToast(
      child: MaterialApp(
        title: '${ProjectData.title} BillEase',
        routes: {
          '/search': (context) => const OrderDetailPage(),
        },
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
          textTheme: GoogleFonts.latoTextTheme(),
          useMaterial3: true,
        ),
        useInheritedMediaQuery: true,
        debugShowCheckedModeBanner: false,
        home: isLoginScreen?NewBillingScreen():LoginScreen(),
      ),
    );
  }
}
