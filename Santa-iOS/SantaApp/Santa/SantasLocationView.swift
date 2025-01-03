//
//  SantasLocationView.swift
//  Santa-iOS
//
//  Created by Mehmet Tarhan on 3.01.2025.
//

import MapKit
import SwiftUI

// MARK: - This view is for Person

// Person will look at the Santa's location and live movements to see when he will get there
struct SantasLocationView: View {
    @StateObject var viewModel = SantasLocationViewModel()

    var presentId: String

    @State private var position: MapCameraPosition = .userLocation(fallback: .automatic)

    var body: some View {
        VStack {
            Text("Lucky Person's View")
                .font(.title.weight(.light))
                .padding()

            Map(position: $position) {
                if let location = viewModel.place?.location {
                    Annotation(
                        "Santa",
                        coordinate: location
                    ) {
                        VStack {
                            Image("santa")
                                .resizable()
                                .padding(8)
                                .frame(width: 64, height: 64)
                                .background(Color.red.opacity(0.3))
                                .clipShape(Circle())
                        }
                    }
                    .annotationTitles(.automatic)
                }
            }
        }
        .onAppear {
            viewModel.webSocketConnectionTask?.cancel()

            viewModel.webSocketConnectionTask = Task {
                await viewModel.openAndConsumeWebSocketConnection(presentId: presentId)
            }
        }
    }
}

#Preview {
    SantasLocationView(presentId: "26646")
}
