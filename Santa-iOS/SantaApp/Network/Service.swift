//
//  Service.swift
//  Santa-iOS
//
//  Created by Mehmet Tarhan on 3.01.2025.
//

import Foundation

struct LocationRequest: HTTPRequest {
    let latitude: Double
    let longitude: Double
}

struct LocationResponse: HTTPResponse {
    let latitude: Double
    let longitude: Double
}

struct CurrentLocationRequest: HTTPRequest {
    let currentLocation: LocationRequest
}

struct CurrentLocationResponse: HTTPResponse {
    let currentLocation: LocationResponse
}

struct WishForPresentRequest: HTTPRequest {
    var latitude: Double
    var longitude: Double
}

struct WishForPresentResponse: HTTPResponse {
    var message: String
    var presentId: String
}

struct PresentsRequest: HTTPRequest {
    var username: String?
}

struct PresentResponse: HTTPResponse, Identifiable {
    let presentId: String
    let finalDestination: LocationResponse

    var id: String { presentId }

    static let sample = PresentResponse(presentId: "26646", finalDestination: LocationResponse(latitude: 34.4, longitude: -122.4))
}

// MARK: - PresentsResponse

struct PresentsResponse: HTTPResponse {
    let presents: [PresentResponse]
}

class Service: HTTPService {
    func wishForPresent(latitude: Double, longitude: Double) async throws -> WishForPresentResponse {
        guard let url = Endpoints.Presents.wishForPresent() else { throw HTTPError.invalidEndpoint }

        let requestModel = WishForPresentRequest(latitude: latitude, longitude: longitude)
        let urlRequest = try requestModel.createURLRequest(withURL: url, encoder: encoder)

        let response: WishForPresentResponse = try await handleDataTask(forURLRequest: urlRequest)
        return response
    }

    func getPresents(isSanta: Bool = false) async throws -> PresentsResponse {
        guard let url = Endpoints.Presents.getPresents(isSanta: isSanta) else { throw HTTPError.invalidEndpoint }

        let response: PresentsResponse = try await handleDataTask(fromURL: url)
        return response
    }
}
