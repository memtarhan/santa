//
//  PersonsViewModel.swift
//  Santa-iOS
//
//  Created by Mehmet Tarhan on 3.01.2025.
//

import Foundation
import MapKit

class PersonsLocationViewModel: NSObject, CLLocationManagerDelegate, ObservableObject {
    @Published var webSocketConnectionTask: Task<Void, Never>? = nil

    private var connection: WebSocketConnection<CurrentLocationResponse, CurrentLocationRequest>?

    private let webSocketConnectionFactory: WebSocketConnectionFactory

    @Published var place: IdentifiablePlace?

    var present: PresentResponse?

    init(webSocketConnectionFactory: WebSocketConnectionFactory) {
        self.webSocketConnectionFactory = webSocketConnectionFactory
        super.init()

        Task {
            do {
                let updates = try await LocationsHandler.shared.receiveLocationUpdates()
                for try await update in updates {
                    if let loc = update.location {
                        self.save(latitude: loc.coordinate.latitude, longitude: loc.coordinate.longitude)
                    }
                }
            } catch {
                print("Could not start location updates")
            }
        }
    }

    func openAndConsumeWebSocketConnection(presentId: String) async {
        let url = URL(string: "ws://localhost:8000/presents/\(presentId)?is_santa=True")!

        // Close any existing WebSocketConnection
        if let connection {
            connection.close()
        }

        let connection: WebSocketConnection<CurrentLocationResponse, CurrentLocationRequest> = webSocketConnectionFactory.open(url: url)

        self.connection = connection
    }

    func handleFinalDestionation(present: PresentResponse) {
        self.present = present
        place = IdentifiablePlace(lat: present.finalDestination.latitude, long: present.finalDestination.longitude)
    }

    func save(latitude: Double, longitude: Double) {
        let location = CurrentLocationRequest(currentLocation: LocationRequest(latitude: latitude, longitude: longitude))
        guard let connection else {
            return // assertionFailure("Expected Connection to exist")
        }

        Task {
            do {
                try await connection.send(location)
                print("didSave location: \(location)")

            } catch {
                print("Error saving location:", error)
            }
        }
    }
}
