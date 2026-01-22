import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


import 'business_logic/design_bloc/design_bloc.dart';
import 'business_logic/device_bloc/device_bloc.dart';
import 'business_logic/template_bloc/template_bloc.dart';
import 'data/repositories/device_repository.dart';
import 'data/repositories/design_repository.dart';
import 'data/repositories/template_repository.dart';
import 'data/services/api_service.dart';
import 'presentation/screens/main_screen.dart';
import 'core/theme/app_theme.dart';

void main() {
  runApp(const ThunderCutApp());
}

class ThunderCutApp extends StatelessWidget {
  const ThunderCutApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize services
    final apiService = ApiService(baseUrl: 'http://127.0.0.1:3000');
    
    // Initialize repositories
    final deviceRepository = DeviceRepository(apiService);
    final designRepository = DesignRepository(apiService);
    final templateRepository = TemplateRepository(apiService);

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: deviceRepository),
        RepositoryProvider.value(value: designRepository),
        RepositoryProvider.value(value: templateRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => DeviceBloc(deviceRepository)..add(const LoadDevicesEvent()),
          ),
          BlocProvider(
            create: (context) => DesignBloc(designRepository),
          ),
          BlocProvider(
            create: (context) => TemplateBloc(templateRepository)
              ..add(const LoadTemplatesEvent())
              ..add(const LoadMetadataEvent()),
          ),
        ],
        child: MaterialApp(
          title: 'ThunderCut',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.light,
          home: const MainScreen(),
        ),
      ),
    );
  }
}
