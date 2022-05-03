import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:guess_bulgaria/configs/env_config.dart';
import 'package:guess_bulgaria/pages/main_page.dart';
import 'package:guess_bulgaria/services/audio_service.dart';
import 'package:guess_bulgaria/storage/user_data.dart';
import 'package:guess_bulgaria/themes/light_theme.dart';
import 'package:wakelock/wakelock.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  EnvConfig.setupEnvConfig();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  await UserData().setupUserData();
  Wakelock.enable();
  loadLicenses();
  AudioService();
  runApp(const App());
}

void loadLicenses() {
  const licenses = {
    'AmaticSC-OFL': 'google_fonts',
    'Roboto-OFL': 'google_fonts',
    'Mulish-OFL': 'google_fonts'
  };
  for (var entry in licenses.entries) {
    LicenseRegistry.addLicense(() async* {
      final license = await rootBundle.loadString('licenses/${entry.key}.txt');
      yield LicenseEntryWithLineBreaks([entry.value], license);
    });
  }
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Guess Bulgaria',
        theme: LightTheme.getTheme(),
        home: const MainPage(),
        initialRoute: '/');
  }
}
