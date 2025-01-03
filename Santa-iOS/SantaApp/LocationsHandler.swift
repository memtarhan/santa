//
//  LocationManager.swift
//  Santa-iOS
//
//  Created by Mehmet Tarhan on 3.01.2025.
//

import MapKit

@MainActor
class LocationsHandler: ObservableObject {
    static let shared = LocationsHandler()

    @Published var lastUpdate: CLLocationUpdate? = nil
    @Published var lastLocation = CLLocation()

    func startLocationUpdatesOnce() {
        print("Starting location updates")

        Task {
            do {
                let updates = CLLocationUpdate.liveUpdates(.default)
                for try await update in updates {
                    self.lastUpdate = update
                    if let loc = update.location {
                        self.lastLocation = loc
                        print("Location: \(self.lastLocation)")
                        break
                    }
                }
            } catch {
                print("Could not start location updates")
            }
        }
    }

    func startLocationUpdates() {
        print("Starting location updates")

        Task {
            do {
                let updates = CLLocationUpdate.liveUpdates(.automotiveNavigation)
                for try await update in updates {
                    self.lastUpdate = update
                    if let loc = update.location {
                        self.lastLocation = loc
                        print("Location: \(self.lastLocation)")
                    }
                }
            } catch {
                print("Could not start location updates")
            }
        }
    }

    func receiveLocationUpdates() async throws -> CLLocationUpdate.Updates {
        CLLocationUpdate.liveUpdates(.automotiveNavigation)
    }
}
