//
//  SantasLocationViewModel.swift
//  Santa-iOS
//
//  Created by Mehmet Tarhan on 3.01.2025.
//

import Foundation
import MapKit

@MainActor
class SantasLocationViewModel: ObservableObject {
    @Published var webSocketConnectionTask: Task<Void, Never>? = nil

    private var connection: WebSocketConnection<CurrentLocationResponse, CurrentLocationRequest>?

    private let webSocketConnectionFactory = DefaultWebSocketConnectionFactory()

  
    @Published var place: IdentifiablePlace?

    func openAndConsumeWebSocketConnection(presentId: String) async {
        let url = URL(string: "ws://localhost:8000/presents/\(presentId)?is_santa=False")!

        // Close any existing WebSocketConnection
        if let connection {
            connection.close()
        }

        let connection: WebSocketConnection<CurrentLocationResponse, CurrentLocationRequest> = webSocketConnectionFactory.open(url: url)

        self.connection = connection

        do {
            for try await response in connection.receive() {
                print("didReceive new location: \(response.currentLocation)")
                place = IdentifiablePlace(lat: response.currentLocation.latitude, long: response.currentLocation.longitude)
            }

            print("IncomingMessage stream ended")
        } catch {
            print("Error receiving messages:", error)
        }
    }
}
