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
        bridgeLogger.info(
            "getReminderState called. appGroup=\(ReminderStateStore.appGroupID, privacy: .public) usingAppGroup=\(ReminderStateStore.shared.isUsingAppGroup)"
        )
        let store = ReminderStateStore.shared
        let on = store.isReminderOn
        var result: [String: Any] = ["on": on]

        if let text = store.reminderText {
            result["text"] = text
        }

        if let date = store.reminderDate {
            result["date"] = ISO8601DateFormatter().string(from: date)
        }

        bridgeLogger.info("getReminderState returning on=\(on) text=\(store.reminderText ?? "nil") date=\(store.reminderDate?.description ?? "nil")")
        call.resolve(result)
    }

    @objc func setReminderState(_ call: CAPPluginCall) {
        let on = call.getBool("on") ?? false
        bridgeLogger.info("setReminderState called with on=\(on)")
        ReminderStateStore.shared.setReminderOn(on, caller: "ReminderBridgePlugin.setReminderState")
        call.resolve()
    }
}
