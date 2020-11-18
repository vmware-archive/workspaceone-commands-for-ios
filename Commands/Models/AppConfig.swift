//
//  AppConfig.swift
//  Action
//
//  Created by Mohammed Lazim on 2/10/19.
//  Updated by Paul Evans on 5/12/20.
//  Copyright © 2019-2020 VMware, Inc.

import Foundation

class AppConfig {

    enum Key: String, CustomDebugStringConvertible {
        case apiHostname = "API_HOSTNAME"
        case apiKey = "API_KEY"
        case apiUsername = "API_USERNAME"
        case apiPassword = "API_PASSWORD"
        case deviceIdentifier = "DEVICE_UID"

        case backgroundImage = "BACKGROUND_IMAGE"
        case troubleshootingEnabled = "ENABLE_TROUBLESHOOTING"
        case actionWipe = "ACTION_WIPE"
        case actionClearPasscode = "ACTION_CLEARPASSCODE"
        case actionSync = "ACTION_SYNC"
        case actionEnterpriseWipe = "ACTION_ENTERPRISEWIPE"

        var debugDescription: String {
            return self.rawValue
        }
    }

    enum Value: CustomDebugStringConvertible {
        case string(String)
        case boolean(Bool)

        var debugDescription: String {
            switch self {
            case .string(let value): return value
            case .boolean(let value): return String(value)
            }
        }

        static func parseString(from value: Any) -> Value? {
            if let stringValue = value as? String {
                return Value.string(stringValue)
            }

            return nil
        }

        static func parseBool(from value: Any) -> Value? {
            if let boolValue = value as? Bool {
                return Value.boolean(boolValue)
            } else if let intValue = value as? Int {
                return Value.boolean(intValue != 0)
            }
            return nil
        }
    }

    private var configs: [Key: Value]

    public var apiConfiguration: APIConfiguration?
    public var deviceIdentifier: String?
    public var supportedActions = [Actions]()
    public var troubleshootingEnabled: Bool?
    public var backgroundImageURL: String?

    init(_ info: [String: Any]) {

        self.configs = [Key: Value]()

        /// Loop via each of the elements in the info map
        /// to parse each of the item we need.
        for (item, value) in info {
            var val: Value?
            if let key = Key(rawValue: item) {
                switch key{

                case .apiHostname, .apiKey, .apiUsername, .apiPassword, .deviceIdentifier, .backgroundImage:
                    val = Value.parseString(from: value)

                case .troubleshootingEnabled, .actionWipe, .actionClearPasscode, .actionSync, .actionEnterpriseWipe:
                    val = Value.parseBool(from: value)
                }


                if let parsedValue = val {
                    configs[key] = parsedValue
                }
            }
        }

        self.apiConfiguration = APIConfiguration(configuration: configs)

        print("\n\nAPI Configuration:\n" + String(describing: self.apiConfiguration))

        guard let udidValue = configs[.deviceIdentifier], case let AppConfig.Value.string(deviceUDID) = udidValue else {
            return
        }
        self.deviceIdentifier = deviceUDID

        print("\n\nDevice Identifier:\n" + String(describing: self.deviceIdentifier))
        
        self.backgroundImageURL = getBackgroundURL()
        
        self.troubleshootingEnabled = checkTroubleshootingEnabled()

        self.setupSupportedActions()
    }
    
    func checkTroubleshootingEnabled() -> Bool {
        guard let troubleshootingValue = configs[.troubleshootingEnabled] else {
            return false
        }
        guard case let AppConfig.Value.boolean(tsEnabled) = troubleshootingValue else {
            return false
        }
        return tsEnabled
    }
    
    func getBackgroundURL() -> String {
        guard let imageURL = configs[.backgroundImage], case let AppConfig.Value.string(backgroundImageURL) = imageURL else {
            return ""
        }
        return backgroundImageURL
    }

    /// Use `forceEnableAllActions` argument for testing purpose
    func setupSupportedActions(forceEnableAllActions: Bool = false) {

        guard forceEnableAllActions == false else {
            self.supportedActions.append(.wipe)
            self.supportedActions.append(.clearPasscode)
            self.supportedActions.append(.enterpriseWipe)
            self.supportedActions.append(.deviceSync)

            return
        }
        
        func isActionEnabled(actionKey: Key) -> Bool {

            guard let actionValue = configs[actionKey] else {
                return false
            }

            guard case let AppConfig.Value.boolean(actionEnabled) = actionValue else {
                return false
            }

            return actionEnabled
        }

        if isActionEnabled(actionKey: .actionWipe) {
            self.supportedActions.append(.wipe)
        }

        if isActionEnabled(actionKey: .actionClearPasscode) {
            self.supportedActions.append(.clearPasscode)
        }

        if isActionEnabled(actionKey: .actionSync) {
            self.supportedActions.append(.deviceSync)
        }
        
        if isActionEnabled(actionKey: .actionEnterpriseWipe) {
            self.supportedActions.append(.enterpriseWipe)
        }
    }

    static func dictionaryRepresentation(apiConfig: APIConfiguration, deviceID: String, supportedActions: [Actions]) -> [String: Any] {
        var map = [String: Any]()
        map[Key.apiHostname.rawValue] = apiConfig.hostname
        map[Key.apiKey.rawValue] = apiConfig.tenant
        map[Key.apiUsername.rawValue] = apiConfig.username
        map[Key.apiPassword.rawValue] = apiConfig.password

        map[Key.deviceIdentifier.rawValue] = deviceID

        map[Key.troubleshootingEnabled.rawValue] = 1

        supportedActions.compactMap { $0.configurationKey }.forEach { map[$0] = 1 }

        return map
    }
}
