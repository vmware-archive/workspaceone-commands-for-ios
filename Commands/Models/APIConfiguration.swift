//
//  APIConfiguration.swift
//  Action
//
//  Created by Mohammed Lazim on 7/13/19.
//  Copyright © 2020 VMware, Inc. All rights reserved.

import Foundation

struct APIConfiguration {
    enum AuthenticationType {
        case credentials(username: String, password: String)
    }

    let hostname: String
    let tenant: String

    let username: String
    let password: String
}

extension APIConfiguration {
    init?(configuration: [AppConfig.Key: AppConfig.Value]) {
        guard let hostValue = configuration[.apiHostname], case let AppConfig.Value.string(host) = hostValue else {
            return nil
        }

        guard let tenantValue = configuration[.apiKey], case let AppConfig.Value.string(tenant) = tenantValue else {
            return nil
        }

        guard let usernameValue = configuration[.apiUsername], case let AppConfig.Value.string(username) = usernameValue else {
            return nil
        }

        guard let passwordValue = configuration[.apiPassword], case let AppConfig.Value.string(password) = passwordValue else {
            return nil
        }

        self.hostname = host
        self.tenant = tenant
        self.username = username
        self.password = password
    }
}
