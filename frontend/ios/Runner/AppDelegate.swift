import UIKit
import Flutter
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Google Maps key is provided via Info.plist (GMSApiKey -> $(GMS_API_KEY)).
    if let rawValue = Bundle.main.object(forInfoDictionaryKey: "GMSApiKey") as? String {
      let mapsApiKey = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
      if !mapsApiKey.isEmpty && !mapsApiKey.hasPrefix("$(") {
        GMSServices.provideAPIKey(mapsApiKey)
      }
    }

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
