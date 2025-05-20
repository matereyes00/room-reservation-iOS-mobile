//
//  ManageRoomsView.swift
//  RoomReservation
//
//  Created by Martina Reyes on 5/19/25.
//

import SwiftUI

struct ManageRoomsView: View {
    @Binding var isLoggedIn: Bool
    let accessToken: String
    let onLogout: () -> Void
    let userRole: Role
    
    @State private var rooms: [Room] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    
    @State private var searchText = ""
    @State private var isShowingAddRoom = false


    var body: some View {
        RootManageView(
            title: "Manage Rooms",
            searchText: $searchText,
            onAdd: {
                isShowingAddRoom = true
            },
            content: { filteredRooms in
                // Here you receive filtered rooms to display.
                VStack {
                    if isLoading {
                        ProgressView("Loading rooms...")
                            .padding()
                    } else if let error = errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .padding()
                    } else {
                        if filteredRooms.isEmpty {
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
                            List(filteredRooms) { room in
                                HStack {
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
                                    Spacer()
                                    Menu {
                                        Button("Edit", systemImage: "pencil") {
                                            editRoom(room)
                                        }
                                        Button("Delete", systemImage: "trash", role: .destructive) {
                                            deleteRoom(room)
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
            items: rooms
        )
        .onAppear {
            loadRooms()
        }
        // Use navigationDestination modifier instead of NavigationLink with isActive
        .navigationDestination(isPresented: $isShowingAddRoom) {
            AddRoomView(isLoggedIn: $isLoggedIn, accessToken: accessToken, onLogout: onLogout)
        }
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

    private func editRoom(_ room: Room) {
        // TODO: Show edit sheet or navigate to edit screen
        print("Editing room: \(room.roomName)")
    }

    private func deleteRoom(_ room: Room) {
        // TODO: Add delete confirmation and backend call
        print("Deleting room: \(room.roomName)")
    }
}


#if DEBUG
extension ManageRoomsView {
    init(
        mockRooms: [Room],
        isLoggedIn: Binding<Bool> = .constant(true),
        accessToken: String = "",
        onLogout: @escaping () -> Void = {}
    ) {
        self._isLoggedIn = isLoggedIn
        self.accessToken = accessToken
        self.onLogout = onLogout
        self.userRole = .admin
        _rooms = State(initialValue: mockRooms)
    }
}


struct ManageRoomsView_Previews: PreviewProvider {
    static let sampleRooms: [Room] = [
        Room(
            id: UUID().uuidString,
            roomName: "Board Room",
            roomCapacity: 20,
            roomDescription: "Large meeting space with projector",
            roomStatus: .inactive
        ),
        Room(
            id: UUID().uuidString,
            roomName: "Design Studio",
            roomCapacity: 12,
            roomDescription: "Creative space with whiteboards",
            roomStatus: .active
        ),
        Room(
            id: UUID().uuidString,
            roomName: "Phone Booth",
            roomCapacity: 2,
            roomDescription: "Quiet space for calls",
            roomStatus: .active
        )
    ]

    static var previews: some View {
        NavigationStack {
            ManageRoomsView(mockRooms: sampleRooms)
        }
    }
}
#endif

