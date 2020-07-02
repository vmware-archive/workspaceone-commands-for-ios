//
//  DeviceQueryEndpoint.swift
//  Action
//
//  Created by Mohammed Lazim on 5/1/19.
//  Copyright © 2019-2020 VMware, Inc.

import Foundation

class DeviceSyncEndpoint: DeviceCommandEndpoint {
    var command: String = "SyncDevice"

    var networkService: NetworkService

    init(service: NetworkService) {
        self.networkService = service
    }
}
