// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );
//   runApp(MaterialApp(home: Scaffold(body: MainApp())));
// }

// class MainApp extends StatefulWidget {
//   @override
//   _MainAppState createState() => _MainAppState();
// }

// class _MainAppState extends State<MainApp> {
//   bool isDarkMode = false;

//   void _saveDarkMode(bool value) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     prefs.setBool('isDarkMode', value);
//   }

//   void _readDarkMode() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     bool isDarkMode = prefs.getBool('isDarkMode') ?? false;
//     setState(() {
//       this.isDarkMode = isDarkMode;
//     });
//   }

//   @override
//   void initState() {
//     super.initState();
//     _readLoginStatus();
//   }

//   @override
//   Widget build(BuildContext context) {
//     ThemeData themeData = isDarkMode ? ThemeData.dark() : ThemeData.light();

//     return MaterialApp(
//       // localizationsDelegates: [
//       //   AppLocalizations.delegate,
//       //   GlobalMaterialLocalizations.delegate,
//       //   GlobalWidgetsLocalizations.delegate,
//       // ],
//       // supportedLocales: [
//       //   Locale('en', ''),
//       //   Locale('vi', ''),
//       // ],
//       // locale: _locale,
//       scaffoldMessengerKey: GlobalKey<ScaffoldMessengerState>(),
//       theme: themeData,
//       home: Scaffold(
//         key: _scaffoldKey,
//         resizeToAvoidBottomInset: false, //Thêm dòng này

//         body: SafeArea(),
//       ),
//     );
//   }
// }
