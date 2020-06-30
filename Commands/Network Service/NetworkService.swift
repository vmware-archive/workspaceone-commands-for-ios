//
//  NetworkService.swift
//  Action
//
//  Created by Mohammed Lazim on 2/17/19.
//  Copyright © 2020 VMware, Inc. All rights reserved.

import Foundation

enum RequestHeaderKeys: String {
    case tenantCode = "aw-tenant-code"
    case authorization = "Authorization"
    case contentType = "Content-Type"
    case accept = "Accept"
}

extension URLRequest {
    mutating func addHeader(key: RequestHeaderKeys, value: String) {
        self.addValue(value, forHTTPHeaderField: key.rawValue)
    }
}

enum RequestType {
    case get
    case post(Data)
}

enum NetworkServiceError: Error {
    case wrongUrlFormat
    case missingRequiredAuthorization
    case unknownUrlResponse(URLResponse?)
    case urlError(Error)
    case emptyData
    case badStatusCode(Int, response: Data?)
    case responseParsing(Error)
}

class NetworkService {

    private let host: String
    private let authorizer: AuthorizationProvider
    private let session: URLSession

    init(host: String, authorizer: AuthorizationProvider) {
        self.host = host
        self.authorizer = authorizer
        self.session = URLSession(configuration: .default)
    }

    func response<ResponseType: Decodable>(from path: String, type: RequestType = .get, expectedStatus: Int = 200, completion: @escaping (ResponseType?, NetworkServiceError?) -> Void) {

        let urlString = host + path
        guard let url = URL(string: urlString) else {
            completion(nil, NetworkServiceError.wrongUrlFormat)
            return
        }

        var request = URLRequest(url: url)

        // Add required Authorization
        guard let tenantCode = authorizer.tenantCode, let authorization = authorizer.authorization else {
            completion(nil, NetworkServiceError.missingRequiredAuthorization)
            return
        }

        // Add required headers
        request.addHeader(key: .tenantCode, value: tenantCode)
        request.addHeader(key: .authorization, value: authorization)
        request.addHeader(key: .accept, value: "application/json")
        request.addHeader(key: .contentType, value: "application/json")

        if case let RequestType.post(body) = type {
            request.httpMethod = "POST"
            request.httpBody = body
        } else {
            request.httpMethod = "GET"
        }


        print("Sending Request: \(request)")

        let task = self.session.dataTask(with: request) { (data, response, error) in
            print("Response: \n\(data?.count ?? 0) \n\(String(describing: response))\n\(String(describing: error))")

            if let networkError = error {
                completion(nil, NetworkServiceError.urlError(networkError))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                completion(nil, NetworkServiceError.unknownUrlResponse(response))
                return
            }

            print("Status Code: \(httpResponse.statusCode)")

            guard httpResponse.statusCode == expectedStatus else {
                completion(nil, NetworkServiceError.badStatusCode(httpResponse.statusCode, response: data))
                return
            }

            guard let responseData = data, responseData.count > 0 else {
                completion(nil, NetworkServiceError.emptyData)
                return
            }

            do {
                let responseObject = try JSONDecoder().decode(ResponseType.self, from: responseData)
                completion(responseObject, nil)
            } catch let parsingError {
                completion(nil, NetworkServiceError.responseParsing(parsingError))
            }
        }
        task.resume()

    }
}
