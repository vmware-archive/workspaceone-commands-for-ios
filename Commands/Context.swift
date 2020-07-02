//
//  Context.swift
//  Action
//
//  Created by Mohammed Lazim on 7/8/19.
//  Updated by Paul Evans on 5/12/20.
//  Copyright © 2019-2020 VMware, Inc.

import Foundation

protocol Context {
    var deviceIdentifier: String? { get }
    var supportedActions: [Actions] { get }
    var troubleshootingEnabled: Bool? { get }
    var backgroundImageURL: String? { get }
}


class ApplicationContext: Context {
    var configuration: AppConfig?

    var deviceIdentifier: String? {
        return self.configuration?.deviceIdentifier
    }

    var supportedActions: [Actions] {
        return self.configuration?.supportedActions ?? [Actions]()
    }
    
    var troubleshootingEnabled: Bool? {
        return self.configuration?.troubleshootingEnabled
    }
    
    var backgroundImageURL: String? {
        return self.configuration?.backgroundImageURL
    }

    static let shared: ApplicationContext = ApplicationContext()
}

enum ContextSetupStatus {
    case success
    case missingConfigInfo
    case missingDeviceIdentifier
    case missingAPIInfo
    case noSupportedActions

    func errorDescription() -> String {
        switch self {
        case .missingConfigInfo:
            return "Failed to get configurations.\n Please contact your administrator."

        case .missingDeviceIdentifier:
            return "Failed to get device info.\n Please contact your administrator."

        case .missingAPIInfo:
            return "Failed to get server details.\n Please contact your administrator."

        case .noSupportedActions:
            return "No actions found.\n Please contact your administrator."
        default:
            return ""
        }
    }
}

protocol ApplicationContextSetupProvider {
    var context: ApplicationContext { get set}

    func setup(with configuration: [String: Any]) -> ContextSetupStatus
}


extension ApplicationContextSetupProvider {
    func setup(with configuration: [String: Any]) -> ContextSetupStatus {

        print("[ContextSetup] Available configuration: \(configuration)")

        let applicationConfigurations = AppConfig(configuration)
        guard applicationConfigurations.apiConfiguration != nil  else {
            print("[ContextSetup] ❗️ API information not available")
            return .missingAPIInfo
        }

        guard applicationConfigurations.deviceIdentifier != nil else {
            print("[ContextSetup] ❗️ Device Identifier not available")
            return .missingDeviceIdentifier
        }

        guard applicationConfigurations.supportedActions.count > 0 else {
            print("[ContextSetup] ❗️ No supported actions found")
            return .noSupportedActions
        }


        self.context.configuration = applicationConfigurations

        print("[ContextSetup] Context setup complete")
        return .success
    }
}


protocol UserDefaultsContextSetupProvider: ApplicationContextSetupProvider {
    var store: UserDefaults { get }
    var configurationKey: String { get }

    func setup()-> ContextSetupStatus
}

extension UserDefaultsContextSetupProvider {

    func setup() -> ContextSetupStatus {
        guard let config = self.store.object(forKey: self.configurationKey) as? [String : Any] else {
            print("[ContextSetup] ❗️ No configurations available for \(self.configurationKey)")
            return .missingConfigInfo
        }

        return self.setup(with: config)
    }
}


struct ManagedConfigurationContextSetupProvider: UserDefaultsContextSetupProvider {
    var context: ApplicationContext

    init(context: ApplicationContext) {
        self.context = context
    }

    var store: UserDefaults {
        return .standard
    }

    var configurationKey: String {
        return "com.apple.configuration.managed"
    }
}

