//
//  HomeViewModel.swift
//  Santa-iOS
//
//  Created by Mehmet Tarhan on 3.01.2025.
//

import Foundation

@MainActor
class HomeViewModel: ObservableObject {
    @Published var shouldDisplaySantaQuestion: Bool = true
    @Published var shouldDisplayWishForPresent: Bool = false
    @Published var shouldDisplayFollowPresent: Bool = false
    @Published var shouldDisplaySantasMap: Bool = false
    @Published var shouldDisplayPresentsList: Bool = false
    @Published var shouldDisplayPersonsMap: Bool = false

    var presentId: String = ""
    var present: PresentResponse?

    @Published var presentMessage: String = ""

    @Published var presents: [PresentResponse] = []

    private let service = Service()

    func wishForPresent(latitude: Double, longitude: Double) {
        shouldDisplayWishForPresent = false
        Task {
            let response = try! await service.wishForPresent(latitude: latitude, longitude: longitude)
            presentId = response.presentId
            presentMessage = response.message
            shouldDisplayFollowPresent = true
        }
    }

    func fetchPresents() {
        Task {
            presents = try! await service.getPresents(isSanta: true).presents
            shouldDisplaySantaQuestion = false
            shouldDisplayPresentsList = true
        }
    }
}
