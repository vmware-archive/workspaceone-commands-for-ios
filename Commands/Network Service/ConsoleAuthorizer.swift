//
//  ConsoleAuthorizer.swift
//  Action
//
//  Created by Mohammed Lazim on 7/13/19.
//  Copyright © 2020 VMware, Inc. All rights reserved.

import Foundation

protocol AuthorizationProvider {
    var tenantCode: String? { get }
    var username: String? { get }
    var password: String? { get }

    var authorization: String? { get }
}

extension AuthorizationProvider {
    var authorization: String? {
        guard let username = self.username, let password = self.password else {
            return nil
        }

        let credentials = username + ":" + password
        guard let base64Credentials = credentials.base64Encoded() else {
            return nil
        }

        return "Basic " + base64Credentials
    }
}

struct ConsoleAuthorizer: AuthorizationProvider {
    var apiConfiguration: APIConfiguration?

    var tenantCode: String? {
        return apiConfiguration?.tenant
    }

    var username: String? {
        return apiConfiguration?.username
    }

    var password: String? {
        return apiConfiguration?.password
    }
}
