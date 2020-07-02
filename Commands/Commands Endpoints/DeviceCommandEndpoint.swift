//
//  DeviceCommandEndpoint.swift
//  Action
//
//  Created by Mohammed Lazim on 5/1/19.
//  Copyright © 2019-2020 VMware, Inc.

import Foundation

/*

 Request Body:
 {
 "CommandXml" : "<command>LOCK</command>" // Can be any XML
 }
 */
struct DeviceCommandRequest: Codable {
    let xml: String

    init(for command: String) {
        self.xml = "<command>\(command)</command>"
    }

    enum CodingKeys: String, CodingKey {
        case xml = "CommandXml"
    }

}


protocol DeviceCommandEndpoint: ConsoleActionsEndpoint {
    var command: String { get }
}


extension DeviceCommandEndpoint {

    var path: String {
        return "/mdm/devices/commands?command=%@&searchBy=Udid&id=%@"
    }

    func perform(udid: String, completion: @escaping (Bool, String, String?) -> Void) {

        let command = self.command

        let path = String(format: self.path, command, udid)

        let endpointRequest = DeviceCommandRequest(for: command)

        guard let body = try? JSONEncoder().encode(endpointRequest) else {
            print("Failed to create request.")
            completion(false, "Failed to \(command) the device", "Failed to create the command request.")
            return
        }

        self.networkService.response(from: path,
                                     type: .post(body),
                                     expectedStatus: 202)
        { (response: DeviceWipeEndpointResponse?, error) in

            print("\(String(describing: response))")
            print("\(String(describing: error))")

            if let serviceError = error {
                if case NetworkServiceError.emptyData = serviceError {
                    var message = "Command queued successfully"
                    switch (command) {
                        case "SyncDevice":
                            message = "Your device will now be synced to its expected state."
                        case "ClearPasscode":
                            message = "The passcode on your device will now be cleared."
                        case "EnterpriseWipe":
                            message = "All Corporate apps and content will now be removed from your device."
                        case "DeviceWipe":
                            message = "Your device will now wiped."
                        default:
                            message = "Command queued successfully"
                    }
                    completion(true, message, nil)
                    return
                } else if case let NetworkServiceError.badStatusCode(statusCode , response: data) = serviceError, let errorData = data  {
                    do {
                        let errorResponse = try JSONDecoder().decode(DeviceWipeEndpointErrorResponse.self, from: errorData)
                        print("Error Response \n\(errorResponse)")
                        completion(false, errorResponse.message, "Failed to \(command) the device with status code: \(statusCode) and error code \(errorResponse.errorCode)")
                    } catch {
                        print("Cannot parse Error Response")
                        completion(false, "Failed to send command \(command) to the device", "Failed to parse the error response from the server. Status Code:\(statusCode)")
                    }

                    return
                }
            }

            completion(false, "Failed to \(command) the device", "Service Error : \(String(describing: error))")
        }
    }
}
