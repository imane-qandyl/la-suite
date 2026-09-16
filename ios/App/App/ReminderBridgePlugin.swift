import Capacitor
import os

private let bridgeLogger = Logger(
    subsystem: Bundle.main.bundleIdentifier ?? "com.lasuite.app",
    category: "ReminderBridgePlugin"
)

@objc(ReminderBridgePlugin)
public class ReminderBridgePlugin: CAPPlugin, CAPBridgedPlugin {
    public let identifier = "ReminderBridgePlugin"
    public let jsName = "ReminderBridge"
    public let pluginMethods: [CAPPluginMethod] = [
        CAPPluginMethod(name: "getReminderState", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "setReminderState", returnType: CAPPluginReturnPromise),
    ]

    @objc func getReminderState(_ call: CAPPluginCall) {
        let store = ReminderStateStore.shared
        let on = store.isReminderOn
        let items = store.reminders

        // Serialize each ReminderItem as a plain [String: String] dictionary
        // so Capacitor can bridge it to JS without a custom type.
        let remindersPayload: [[String: String]] = items.map { item in
            ["id": item.id, "text": item.text, "date": item.date]
        }

        let result: [String: Any] = [
            "on": on,
            "reminders": remindersPayload,
        ]

        // [DEBUG] Log the exact payload going to JS
        bridgeLogger.info(
            "[BRIDGE] getReminderState on=\(on) count=\(items.count) usingAppGroup=\(store.isUsingAppGroup) payload=\(String(describing: result), privacy: .public)"
        )
        print("[BRIDGE] getReminderState on=\(on) count=\(items.count)")
        for (i, item) in items.enumerated() {
            print("[BRIDGE] reminders[\(i)] id=\(item.id) text=\(item.text)")
        }

        call.resolve(result)
    }

    @objc func setReminderState(_ call: CAPPluginCall) {
        let on = call.getBool("on") ?? false
        bridgeLogger.info("setReminderState called with on=\(on)")
        ReminderStateStore.shared.setReminderOn(on, caller: "ReminderBridgePlugin.setReminderState")
        call.resolve()
    }
}
