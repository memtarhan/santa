//
//  HomeView.swift
//  Santa-iOS
//
//  Created by Mehmet Tarhan on 3.01.2025.
//

import MapKit
import SwiftUI

struct HomeView: View {
    @StateObject var viewModel = HomeViewModel()

    @State var shouldAnimateSantaQuestion: Bool = false
    @State private var scale: CGFloat = 1.0

    var body: some View {
        VStack(spacing: 0) {
            VStack {
                Image("christmas-tree")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 64)

                Divider()
                    .frame(height: 5)
                    .background(Color.red.opacity(0.4))
            }

            if viewModel.shouldDisplayPresentsList {
                List {
                    Section(header: Text("List of Presents")) {
                        ForEach(viewModel.presents) { present in
                            Text(present.presentId)
                                .onTapGesture {
                                    viewModel.presentId = present.presentId
                                    viewModel.present = present
                                    viewModel.shouldDisplayPersonsMap = true
                                }
                        }
                    }
                }
                .refreshable {
                    viewModel.presents.removeAll()
                    viewModel.fetchPresents()
                }

            } else {
                Spacer()

                ZStack {
                    Image("santa")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding()
                        .opacity(shouldAnimateSantaQuestion ? 1.0 : 0.3)
                        .scaleEffect(scale)
                        .animation(.easeInOut(duration: 1), value: scale)

                    if viewModel.shouldDisplaySantaQuestion {
                        santaQuestionView
                            .padding()

                    } else if viewModel.shouldDisplayWishForPresent {
                        wishForPresentView
                            .padding()

                    } else if viewModel.shouldDisplayFollowPresent {
                        followPresentView
                            .padding()
                    }
                }

                Spacer()
            }
        }
        .popover(isPresented: $viewModel.shouldDisplayPersonsMap) {
            PersonsLocationView(present: viewModel.present ?? PresentResponse.sample)
        }
        .popover(isPresented: $viewModel.shouldDisplaySantasMap) {
            SantasLocationView(presentId: viewModel.presentId)
        }
    }

    private var followPresentView: some View {
        VStack {
            Text(viewModel.presentMessage)
                .font(.headline)
            Button {
                viewModel.shouldDisplayFollowPresent = false
                viewModel.shouldDisplaySantasMap = true
            } label: {
                Text("Follow Santa")
                    .font(.title2.weight(.medium))
                    .foregroundStyle(Color.white)
                    .padding()
                    .background(Color.red.opacity(0.5))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }

    private var wishForPresentView: some View {
        VStack {
            Button {
                let latitude = LocationsHandler.shared.lastLocation.coordinate.latitude
                let longitude = LocationsHandler.shared.lastLocation.coordinate.longitude
                viewModel.wishForPresent(latitude: latitude, longitude: longitude)

            } label: {
                Text("Wish for a Present")
                    .font(.title2.weight(.medium))
                    .foregroundStyle(Color.white)
                    .padding()
                    .background(Color.red.opacity(0.5))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }

    private var santaQuestionView: some View {
        VStack {
            VStack {
                Text("Are you Santa?")
                    .font(.title2.weight(.medium))
                VStack {
                    Button("NO") {
                        scale = 0.5
                        shouldAnimateSantaQuestion = true
                        viewModel.shouldDisplaySantaQuestion = false
                        viewModel.shouldDisplayWishForPresent = true
                        LocationsHandler.shared.startLocationUpdatesOnce()
                    }
                    .buttonStyle(.bordered)
                    .font(.title)

                    Button("YES HO HO HO") {
                        scale = 0.5
                        shouldAnimateSantaQuestion = true

                        viewModel.fetchPresents()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.red)
                    .font(.title)
                }
            }
        }
    }
}

#Preview {
    HomeView()
}
