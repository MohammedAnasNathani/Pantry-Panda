import 'dart:io';

void main() async {
  print('🚑 FIXING PANTRY PANDA...');

  // 1. CREATE ASSETS FOLDERS
  final dirs = [
    'assets/images',
    'assets/icons',
    'assets/animations',
  ];

  for (var path in dirs) {
    final dir = Directory(path);
    if (!dir.existsSync()) {
      print('📂 Creating $path...');
      dir.createSync(recursive: true);
    } else {
      print('✅ $path already exists.');
    }
  }

  // 2. OVERWRITE PUBSPEC.YAML (With Stable Versions)
  final pubspecContent = '''
name: pantry_panda_v2
description: Turn Leftovers into Luxury.
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.2.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter

  # UI & Animations
  flutter_animate: ^4.5.0
  google_fonts: ^6.1.0
  glass_kit: ^3.0.0
  lottie: ^3.1.0
  confetti: ^0.7.0
  font_awesome_flutter: ^10.6.0
  
  # Logic
  provider: ^6.1.1
  shared_preferences: ^2.2.2
  intl: ^0.19.0
  uuid: ^4.3.3
  
  # Firebase (Stable Versions)
  firebase_core: ^2.24.2
  firebase_auth: ^4.16.0
  cloud_firestore: ^4.14.0
  google_sign_in: ^6.2.1  # <--- DOWNGRADED TO FIX YOUR ERROR
  
  # AI & Camera
  google_generative_ai: ^0.4.0
  camera: ^0.10.5+9
  image_picker: ^1.0.7
  
  # Monetization
  google_mobile_ads: ^5.0.0

  # Extras
  flutter_tts: ^3.8.3
  vibration: ^1.8.4
  home_widget: ^0.3.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0

flutter:
  uses-material-design: true
  assets:
    - assets/images/
    - assets/icons/
    - assets/animations/
''';

  File('pubspec.yaml').writeAsStringSync(pubspecContent);
  print('✅ pubspec.yaml fixed (Downgraded Google Sign In).');

  print('🚀 DONE. Now follow Step 2 manually!');
}