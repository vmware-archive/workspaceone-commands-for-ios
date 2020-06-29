//
//  Actions.swift
//  Action
//
//  Created by Mohammed Lazim on 7/13/19.
//  Updated by Paul Evans on 5/12/20.
//  Copyright © 2020 VMware, Inc. All rights reserved.

import Foundation

enum Actions {
    case wipe
    case clearPasscode
    case enterpriseWipe
    case deviceSync

    func actionEndpoint(service: NetworkService) -> ConsoleActionsEndpoint? {
        switch self {

        case .wipe:
            return DeviceWipeEndpoint(service: service)

        case .clearPasscode:
            return DeviceClearPasscodeEndpoint(service: service)

        case .enterpriseWipe:
            return DeviceEnterpriseWipeEndpoint(service: service)

        case .deviceSync:
            return DeviceSyncEndpoint(service: service)

        }
    }

    func actionInfo() -> ActionCellInfo {
        switch self {
        case .wipe: return .wipe
        case .clearPasscode: return .clearPasscode
        case .enterpriseWipe: return .enterpriseWipe
        case .deviceSync: return .deviceSync
        }
    }
    
    func confirmationMessage() -> String {
        switch self {
        case .wipe: return "Are you sure you want to perform a Device Wipe?  This will factory reset this device and delete all saved data."
        case .clearPasscode: return "Are you sure you want to clear passcode on this device? This will remove any passcode and biometric information from this device."
        case .enterpriseWipe: return "Are you sure you want to perform an Enterprise Wipe?  This will remove all managed data and apps from your device."
        case .deviceSync: return "Are you sure you want to perform a Device Sync? This will perform a sync with the management server to verify the desired state and take remediation actions if necessary."
        }
    }
}
