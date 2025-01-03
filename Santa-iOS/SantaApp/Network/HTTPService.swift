//
//  HTTPService.swift
//  Santa-iOS
//
//  Created by Mehmet Tarhan on 3.01.2025.
//

import Foundation

let baseURL = "http://127.0.0.1:8000"

struct Endpoints {
    struct Presents {
        static func wishForPresent() -> URL? {
            URL(string: "\(baseURL)/presents")
        }

        static func getPresents(isSanta: Bool = false) -> URL? {
            URL(string: "\(baseURL)/presents?is_santa=\(isSanta)")
        }
    }
}

enum HTTPError: Error {
    case failed
    case invalidEndpoint
    case invalidData
}

protocol HTTPResponse: Decodable { }

protocol HTTPRequest: Encodable {
    func createURLRequest(withURL url: URL, encoder: JSONEncoder, httpMethod: String) throws -> URLRequest
    func httpBody(withEncoder encoder: JSONEncoder) throws -> Data
}

extension HTTPRequest {
    func createURLRequest(withURL url: URL, encoder: JSONEncoder, httpMethod: String = "POST") throws -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        let httpBody = try encoder.encode(self)
        request.httpBody = httpBody

        return request
    }

    func httpBody(withEncoder encoder: JSONEncoder) throws -> Data {
        try encoder.encode(self)
    }
}

protocol HTTPService {
    func handleDataTask<T: HTTPResponse>(fromURL url: URL) async throws -> T
    func handleDataTask<T: HTTPResponse>(forURLRequest urlRequest: URLRequest) async throws -> T
}

extension HTTPService {
    var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        return decoder
    }

    var encoder: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        encoder.keyEncodingStrategy = .convertToSnakeCase

        return encoder
    }

    private var urlSession: URLSession {
        URLSession.shared
    }

    func handleDataTask<T: HTTPResponse>(fromURL url: URL) async throws -> T {
        let (data, _) = try await urlSession.data(from: url)
        data.printPrettied()
        return try decoder.decode(T.self, from: data)
    }

    func handleDataTask<T: HTTPResponse>(forURLRequest urlRequest: URLRequest) async throws -> T {
        let (data, _) = try await urlSession.data(for: urlRequest)
        data.printPrettied()
        return try decoder.decode(T.self, from: data)
    }
}
