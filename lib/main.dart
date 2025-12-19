import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:safe_train/modelos/AddUser_provider.dart';
import 'package:safe_train/modelos/cars_open_provider.dart';
import 'package:safe_train/modelos/cars_tender_provider.dart';
import 'package:safe_train/modelos/change_notifier_provider.dart';
import 'package:safe_train/modelos/distritos_provider.dart';
import 'package:safe_train/modelos/estaciones_provider.dart';
import 'package:safe_train/modelos/excel_download_provider.dart';
import 'package:safe_train/modelos/export_consist_provider.dart';
import 'package:safe_train/modelos/historico_validacion_trenes_provider.dart';
import 'package:safe_train/modelos/indicadores_tren_provider.dart';
import 'package:safe_train/modelos/itinerario_provider.dart';
import 'package:safe_train/modelos/login_provider.dart';
import 'package:safe_train/modelos/ofrecimiento_tren_provider.dart';
import 'package:safe_train/modelos/rechazos_observaciones_data_provider.dart';
import 'package:safe_train/modelos/rechazos_tren_provider.dart';
import 'package:safe_train/modelos/region_division_estacion_provider.dart';
import 'package:safe_train/modelos/regla_incumplida_provider.dart';
import 'package:safe_train/modelos/reglas_incumplidas_tren.dart';
import 'package:safe_train/modelos/stcc_provider.dart';
import 'package:safe_train/modelos/tablas_tren_provider.dart';
import 'package:safe_train/modelos/train_offered_provider.dart';
import 'package:safe_train/modelos/user_provider.dart';
import 'package:safe_train/modelos/validacion_reglas_provider.dart';
import 'package:safe_train/pages/ffccpage/select_ffcc_page.dart';
import 'package:safe_train/pages/home/home_page.dart';
import 'package:safe_train/pages/login/login_page.dart';


void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => LoginProvider()),
        ChangeNotifierProvider(create: (context) => UserProvider()),
        ChangeNotifierProvider(create: (context) => UsersProvider()),
        ChangeNotifierProvider(create: (create) => AdduserProvider()),
        ChangeNotifierProvider(create: (context) => RoleProvider()),
        ChangeNotifierProvider(create: (context) => SelectionNotifier()),
        ChangeNotifierProvider(create: (context) => ButtonStateNotifier()),
        ChangeNotifierProvider(create: (context) => TrainSelectionProvider()),
        ChangeNotifierProvider(create: (context) => TrainModel()),
        ChangeNotifierProvider(create: (context) => SelectedRowModel()),
        ChangeNotifierProvider(create: (context) => TenderProvider()),
        ChangeNotifierProvider(create: (context) => DateProvider()),
        ChangeNotifierProvider(create: (context) => TablesTrainsProvider()),
        ChangeNotifierProvider(create: (context) => CarsOpenProvider()),
        ChangeNotifierProvider(create: (context) => ShowDistrictsProvider()),
        ChangeNotifierProvider(create: (context) => OfferedTrainProvider()),
        ChangeNotifierProvider(create: (context) => STCCProvider()),
        ChangeNotifierProvider(create: (context) => FfccProvider()),
        ChangeNotifierProvider(create: (context) => ValidacionReglasProvider()),
        ChangeNotifierProvider(create: (context) => OfrecimientoTrenProvider()),
        ChangeNotifierProvider(create: (context) => EstacionesProvider()),
        ChangeNotifierProvider(
            create: (context) => HistorialValidacionesProvider()),
        ChangeNotifierProvider(create: (context) => ReglaIncumplidaProvider()),
        ChangeNotifierProvider(create: (context) => ItinerarioProvider()),
        ChangeNotifierProvider(create: (context) => IndicatorTrainProvider()),
        ChangeNotifierProvider(
            create: (context) => ReglasIncumplidasTrenProvider()),
        ChangeNotifierProvider(create: (context) => ExcelDownloadProvider()),
        ChangeNotifierProvider(create: (context) => ExportConsistProvider()),
        ChangeNotifierProvider(create: (context) => AutorizadoProvider()),
        ChangeNotifierProvider(create: (context) => RechazosProvider()),
        ChangeNotifierProvider(create: (context) => MotivosRechazo()),
        ChangeNotifierProvider(create: (context) => IdTren()),
        ChangeNotifierProvider(create: (context) => MotRechazoObs()),
        ChangeNotifierProvider(
            create: (context) => RechazosObservacionesData()),
        ChangeNotifierProvider(create: (context) => RegionProvider()),
        ChangeNotifierProvider(
            create: (context) => RegionDivisionEstacionProvider())
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      supportedLocales: const[
        Locale('es', 'ES'),
      ],

      localizationsDelegates: const[
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      locale: const Locale('es', 'ES'),  

      builder: (context, child) => ResponsiveBreakpoints.builder(
        child: child!, 
        breakpoints: [
          const Breakpoint(start: 0, end: 1920, name: 'LAPTOP'),
          const Breakpoint(start: 1921, end: double.infinity, name: 'MONITOR'),
        ],
      ),
      initialRoute: '/ffcc',
      routes: {
        '/ffcc': (context) => const SelectFFCC(),
        '/login': (context) => const Login(),
        '/home': (context) => const Home(),
      },
    );
  }
}
