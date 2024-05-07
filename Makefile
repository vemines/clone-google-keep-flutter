.PHONY: generate assets, localize, hive adapters

# Rebuild and generate all
regen:
	flutter clean
	flutter pub get
	flutter packages pub run build_runner build --delete-conflicting-outputs
	fluttergen -c pubspec.yaml
	flutter pub run intl_utils:generate
	flutter pub run flutter_launcher_icons
	dart run flutter_native_splash:create 

# Generate colors, assets
genAssets:
	fluttergen -c pubspec.yaml

# Generate localizations
localize:
	flutter pub run intl_utils:generate

icon:
	flutter pub run flutter_launcher_icons

genKeyStore:
	keytool -genkey -v -keystore %USERPROFILE%\.android\debug.keystore -storepass android -alias androiddebugkey -keypass android -keyalg RSA -keysize 2048 -validity 10000 -dname "CN=Android Debug,O=Android,C=US"
# Add sha1 and sha256 to your app in project settings, then download google-service.json and place in android/app/ folder
viewKeyStore:
	keytool -list -v -keystore %USERPROFILE%\.android\debug.keystore -storepass android