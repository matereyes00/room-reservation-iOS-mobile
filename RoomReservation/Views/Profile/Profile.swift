//
//  Profile.swift
//  RoomReservation
//
//  Created by Martina Reyes on 5/16/25.
//

import SwiftUI

struct ProfileView: View {
    @Binding var isLoggedIn: Bool
    let accessToken: String
    let onLogout: () -> Void

    @State private var errorMessage: String? = nil
    @State private var user: User? = nil
    @State private var isLoading = true

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                if isLoading {
                    ProgressView("Loading profile...")
                } else if let user = user {
                    Text("Welcome, \(user.name)")
                        .font(.title)

                    Text("Email: \(user.email)")
                        .foregroundColor(.gray)

                    Button(action: {}) {
                        Text("Edit Profile")
                            .padding()
                            .foregroundColor(.white)
                            .background(.black)
                            .cornerRadius(10)
                    }

                    Button(action: { onLogout() }) {
                        Text("Logout")
                            .padding()
                            .foregroundColor(.black)
                            .border(.black)
                    }

                } else if let errorMessage = errorMessage {
                    Text("Error: \(errorMessage)")
                        .foregroundColor(.red)

                    Button("Retry") {
                        Task {
                            await loadProfile()
                        }
                    }
                }
            }
            .padding()
            .onAppear {
                Task {
                    await loadProfile()
                }
            }
            .navigationBarBackButtonHidden(true)
            .disableBackSwipe()
        }
    }

    func loadProfile() async {
        do {
            isLoading = true
            let user = try await ProfileService.shared.fetchProfile()
            print("[USER] \(user)")
            self.user = user
            self.errorMessage = nil
        } catch {
            self.errorMessage = error.localizedDescription
            self.user = nil
        }
        isLoading = false
    }
}
