import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:guess_bulgaria/configs/env_config.dart';
import 'package:guess_bulgaria/pages/main_page.dart';
import 'package:guess_bulgaria/themes/light_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  EnvConfig.setupEnvConfig();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  // UserData().setupUserId();
  runApp(const App());
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Guess Bulgaria',
      theme: LightTheme.getTheme(),
      home: const MainPage(),
    );
  }
}
