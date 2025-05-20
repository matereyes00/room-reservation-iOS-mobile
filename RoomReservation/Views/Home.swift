import SwiftUI

struct HomeView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var isLoggedIn: Bool
    var accessToken: String
    let onLogout: () -> Void

    @State private var rooms: [Room] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var isLoggingOut = false

    var body: some View {
        NavigationStack {
            VStack {
                Text("Welcome back!")
                    .font(.title)
                    .padding(.top)

                Button("Log Out") {
                    Task {
                        await logout()
                    }
                }
                .padding()
                .foregroundColor(.blue)

                if isLoading {
                    ProgressView("Loading rooms...")
                        .padding()
                } else if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                } else {
                    if rooms.isEmpty {
                        VStack {
                            Image(systemName: "exclamationmark.circle")
                                .resizable()
                                .frame(width: 80, height: 80)
                                .foregroundColor(.gray)
                                .padding(.bottom, 10)

                            Text("No rooms available.")
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
                        List(rooms) { room in
                            VStack(alignment: .leading) {
                                Text(room.roomName)
                                    .font(.headline)
                                Text("Capacity: \(room.roomCapacity)")
                                    .font(.subheadline)
                                if let description = room.roomDescription {
                                    Text(description)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .lineLimit(2)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
            .padding()
            .onAppear {
                loadRooms()
            }
        }
        .navigationBarBackButtonHidden(true)
        .disableBackSwipe()
    }

    private func loadRooms() {
        isLoading = true
        errorMessage = nil

        Task {
            do {
                let fetchedRooms = try await RoomsService.shared.fetchRooms()
                self.rooms = fetchedRooms
            } catch {
                self.errorMessage = "Failed to load rooms: \(error.localizedDescription)"
            }
            self.isLoading = false
        }
    }
    
    private func logout() async {
        isLoggingOut = true
        errorMessage = nil
        UserDefaults.standard.removeObject(forKey: "accessToken")
        UserDefaults.standard.removeObject(forKey: "refreshToken")
        print("Successfully logged out!")
        isLoggedIn = false
        isLoggingOut = false
        onLogout()
    }
}

struct HomeView_Previews: PreviewProvider {
    @State static var loggedIn = true

    static var previews: some View {
        HomeView(
            isLoggedIn: $loggedIn,               // Binding to the @State var
            accessToken: "dummy_access_token",  // Sample string for preview
            onLogout: { print("Logged out") }   // Simple closure for preview
        )
    }
}
