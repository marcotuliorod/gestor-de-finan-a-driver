import Cocoa
import FlutterMacOS

@main
class AppDelegate: FlutterAppDelegate {
  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }

  override func application(_ application: NSApplication, open urls: [URL]) {
    // Forward deep link URLs to Flutter plugins (Supabase OAuth redirect via app_links)
    super.application(application, open: urls)
  }
}
