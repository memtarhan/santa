//
//  PersonsView.swift
//  Santa-iOS
//
//  Created by Mehmet Tarhan on 3.01.2025.
//

import MapKit
import SwiftUI

// MARK: This view is for Santa

// Santa will look at the person's location while getting there, in the meantime, Santa's location will be updated and sent to the server
struct PersonsLocationView: View {
    @StateObject var viewModel = PersonsLocationViewModel(webSocketConnectionFactory: DefaultWebSocketConnectionFactory())

    var present: PresentResponse

    @State private var position: MapCameraPosition = .userLocation(fallback: .automatic)

    var body: some View {
        VStack {
            Text("Santa's View")
                .font(.title.weight(.light))
                .padding()
            
            Map(position: $position) {
                if let location = viewModel.place?.location {
                    Annotation(
                        "Lucky Person",
                        coordinate: location
                    ) {
                        VStack {
                            Image("gift")
                                .resizable()
                                .padding(8)
                                .frame(width: 45, height: 45)
                        }
                    }
                    .annotationTitles(.automatic)
                }
            }
        }
        .onAppear {
            viewModel.webSocketConnectionTask?.cancel()

            viewModel.webSocketConnectionTask = Task {
                await viewModel.openAndConsumeWebSocketConnection(presentId: present.presentId)

                viewModel.handleFinalDestionation(present: present)
            }
        }
    }
}

#Preview {
    PersonsLocationView(present: PresentResponse.sample)
}
