//
//  IdentifiablePlace.swift
//  Santa-iOS
//
//  Created by Mehmet Tarhan on 3.01.2025.
//

import Foundation
import CoreLocation

struct IdentifiablePlace: Identifiable {
    let id: UUID
    var location: CLLocationCoordinate2D
    init(id: UUID = UUID(), lat: Double, long: Double) {
        self.id = id
        location = CLLocationCoordinate2D(
            latitude: lat,
            longitude: long)
    }
}
