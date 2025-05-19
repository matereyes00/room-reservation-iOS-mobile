//
//  ManageMyReservationsView.swift
//  RoomReservation
//
//  Created by Martina Reyes on 5/19/25.
//

import SwiftUI

struct ManageMyReservationsView: View {
    @Binding var isLoggedIn: Bool
    let accessToken: String
    let onLogout: () -> Void
    
    @State private var reservations: [Reservation] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    
    @State private var searchText = ""
    @State private var isShowingAddReservation = false
    
    @State private var selectedReservation: Reservation? = nil
    @State private var isShowingEditReservation = false


    var body: some View {
        RootManageView(
            title: "Manage My Reservations",
            searchText: $searchText,
            onAdd: {
                isShowingAddReservation = true
            },
            content: { filteredReservations in
                VStack {
                    if isLoading {
                        ProgressView("Loading reservations...")
                            .padding()
                    } else if let error = errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .padding()
                    } else {
                        if filteredReservations.isEmpty {
                            VStack {
                                Image(systemName: "exclamationmark.circle")
                                    .resizable()
                                    .frame(width: 80, height: 80)
                                    .foregroundColor(.gray)
                                    .padding(.bottom, 10)

                                Text("No reservations available.")
                                    .font(.headline)
                                    .foregroundColor(.secondary)

                                Text("Please check back later or contact the admin.")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                            }
                            .padding(.top, 50)
                        } else {
                            List(filteredReservations) { reservation in
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(reservation.id)
                                            .font(.headline)
                                    }
                                    Spacer()
                                    Menu {
                                        Button("Edit", systemImage: "pencil") {
                                            editMyReservation(reservation)
                                        }
                                        Button("Delete", systemImage: "trash", role: .destructive) {
                                            deleteMyReservation(reservation)
                                        }
                                    } label: {
                                        Image(systemName: "ellipsis.circle")
                                            .font(.title3)
                                            .foregroundColor(.primary)
                                            .padding(.leading, 8)
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                            .listStyle(PlainListStyle())
                        }
                    }
                }
            },
            items: reservations
        )
        .onAppear {
            loadReservations()
        }
        // Use navigationDestination modifier instead of NavigationLink with isActive
        .navigationDestination(isPresented: $isShowingAddReservation) {
            AddReservationView(isLoggedIn: $isLoggedIn, accessToken: accessToken, onLogout: onLogout)
        }
        .navigationDestination(isPresented: $isShowingEditReservation) {
            if let reservationToEdit = selectedReservation {
                EditReservationView(
                    isLoggedIn: $isLoggedIn,
                    accessToken: accessToken,
                    onLogout: onLogout,
                    reservation: reservationToEdit // Pass the selected reservation here
                )
            }
        }
    }

    private func loadReservations() {
        isLoading = true
        errorMessage = nil
        Task {
            do {
                let fetchedReservations = try await ReservationsService.shared.fetchMyReservations()
                self.reservations = fetchedReservations
            } catch {
                self.errorMessage = "Failed to load reservations: \(error.localizedDescription)"
            }
            self.isLoading = false
        }
    }

    private func editMyReservation(_ reservation: Reservation) {
        selectedReservation = reservation
        isShowingEditReservation = true
    }

    private func deleteMyReservation(_ reservation: Reservation) {
        // TODO: Add delete confirmation and backend call
        print("Deleting reservation: \(reservation.id)")
    }
}
