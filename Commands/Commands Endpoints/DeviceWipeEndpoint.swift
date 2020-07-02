//
//  DeviceWipeEndpoint.swift
//  Action
//
//  Created by Mohammed Lazim on 2/17/19.
//  Updated by Paul Evans on 5/12/20.
//  Copyright © 2019-2020 VMware, Inc.

import Foundation

protocol ConsoleActionsEndpoint {
    var networkService: NetworkService { get }
    var path: String { get }

    /// (success: Bool, userMessage: String, detailedMessage: String)
    func perform(udid: String, completion: @escaping (Bool, String, String?) -> Void)
}
/*
 Request Body:
 {
    "BulkValues": {
        "Value": [
            "{{UDID}}"
        ]
    }
 }
 */
struct DeviceWipeEndpointRequest: Codable {
    struct BulkValuesContainer: Codable {
        enum CodingKeys: String, CodingKey {
            case value = "Value"
        }
        let value: [String]
    }

    enum CodingKeys: String, CodingKey {
        case bulkValue = "BulkValues"
    }

    let bulkValue: BulkValuesContainer

    init(with singleValue: String) {
        self.bulkValue = BulkValuesContainer(value: [singleValue])
    }
}

/*
 Response Body

 SUCCESS:
 {
    "TotalItems": 1,
    "AcceptedItems": 1,
    "FailedItems": 0
 }

 FAILURE WITH MULTIPLE UDID (WONT HAPPEN IN OUR CASE):
 Status Code: 200
 {
    "TotalItems": 2,
    "AcceptedItems": 1,
    "FailedItems": 1,
    "Faults": {
        "Fault": [
            {
                "ErrorCode": 404,
                "ItemValue": "4d2002bffa6c6bdd5b8fc868e6ae70158c0d1724",
                "Message": "Device Not Found"
            }
        ]
    }
 }

 FAILURE WITH SINGLE UDID:
 Status Code: 404
 {
    "errorCode": 404,
    "message": "Devices provided in the input could not be found or not enrolled or user does not have access.",
    "activityId": "7e74ca07-50a3-48da-ba07-79e3c77c6ed2"
 }
 */
struct DeviceWipeEndpointResponse: Codable {

    struct FaultContainer: Codable {
        struct Fault: Codable {
            enum CodingKeys: String, CodingKey {
                case errorCode = "ErrorCode"
                case value = "ItemValue"
                case message = "Message"
            }

            let errorCode: Int
            let value: String
            let message: String
        }

        enum CodingKeys: String, CodingKey {
            case faults = "Fault"
        }

        let faults: [Fault]
    }



    enum CodingKeys: String, CodingKey {
        case totalItems = "TotalItems"
        case acceptedItems = "AcceptedItems"
        case failedItems = "FailedItems"
        case faults = "Faults"
    }
    
    let totalItems: Int
    let acceptedItems: Int
    let failedItems: Int
    let faults: FaultContainer?
}


struct DeviceWipeEndpointErrorResponse: Codable {
    // 1013: Wrong Tenant (Tenant code <> does not identify an Organization Group.)
    // 1005: Wrong Credentials, Empty Password (An error occurred while validating remote service client credentials or user not found : <>)
    // Bad Request 500: when empty username
    // 
    // 1022: Your account has been locked. Please reset the password to unlock your account or contact your IT Administrator.
    let errorCode: Int
    let message: String
}

/// MDM (Mobile Device Management) REST API V1
///

class DeviceWipeEndpoint: DeviceCommandEndpoint {
    var command: String = "DeviceWipe"

    var networkService: NetworkService

    init(service: NetworkService) {
        self.networkService = service
    }
}



/// POST /devices/commands
/// [Lock, EnterpriseWipe, DeviceWipe, DeviceQuery, ClearPasscode, SyncDevice, StopAirPlay, ScheduleOsUpdate, CustomMdmCommand, InstallPackagedMacOSXAgent, SoftReset, Shutdown, EnterpriseReset, SyncSensors, OsUpdateStatus, RotateFileVaultKey]

