import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {

  private var methodChannel: FlutterMethodChannel?
  private var eventChannel: FlutterEventChannel?

  private let linkStreamHandler = LinkStreamHandler()

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    let controller = window.rootViewController as! FlutterViewController
    methodChannel = FlutterMethodChannel(name: "suedemoapp.deeplink/channel", binaryMessenger: controller.binaryMessenger)
    eventChannel = FlutterEventChannel(name: "suedemoapp.deeplink/events", binaryMessenger: controller.binaryMessenger)

    GeneratedPluginRegistrant.register(with: self)
    eventChannel?.setStreamHandler(linkStreamHandler)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  override func application(_ application: UIApplication,
                 continue userActivity: NSUserActivity,
                 restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool
    {
        // Get URL components from the incoming user activity.
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
            let incomingURL = userActivity.webpageURL,
            let components = NSURLComponents(url: incomingURL, resolvingAgainstBaseURL: true) else {
            return false
        }

        methodChannel?.setMethodCallHandler({ (call: FlutterMethodCall, result: FlutterResult) in
          guard call.method == "initialLink" else {
            result(FlutterMethodNotImplemented)
            return
          }
        })


//        eventChannel?.setStreamHandler(linkStreamHandler)
        return linkStreamHandler.handleLink(incomingURL.absoluteString)

        // Check for specific URL components that you need.
//        guard let params = components.queryItems else {
//            return false
//        }
//        if let code = params.first(where: { $0.name == "code" } )?.value,
//            let state = params.first(where: { $0.name == "state" })?.value {
//
//            print("code = \(code)")
//            print("state = \(state)")
//            return true
//
//        } else {
//            print("Either album name or photo index missing")
//            return false
//        }
    }
}

class LinkStreamHandler:NSObject, FlutterStreamHandler {

  var eventSink: FlutterEventSink?

  // links will be added to this queue until the sink is ready to process them
  var queuedLinks = [String]()

  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    self.eventSink = events
    queuedLinks.forEach({ events($0) })
    queuedLinks.removeAll()
    return nil
  }

  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    self.eventSink = nil
    return nil
  }

  func handleLink(_ link: String) -> Bool {
    guard let eventSink = eventSink else {
      queuedLinks.append(link)
      return false
    }
    eventSink(link)
    return true
  }
}
