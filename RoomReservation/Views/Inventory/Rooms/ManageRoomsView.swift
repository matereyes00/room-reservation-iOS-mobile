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
    @State private var selectedRoomToEdit: Room? = nil
    @State private var isShowingEditRoom = false


    var body: some View {
        RootManageView(
            title: "Manage Rooms",
            searchText: $searchText,
            items: rooms,
            onAdd: {
                isShowingAddRoom = true
            },
            content: { filteredRooms in
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
                                    HStack {
                                        Text("\(room.roomStatus.rawValue)")
                                            .font(.subheadline)
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
            }
        )
        .onAppear {
            loadRooms()
        }
        // Use navigationDestination modifier instead of NavigationLink with isActive
        .navigationDestination(isPresented: $isShowingAddRoom) {
            AddRoomView(
                isLoggedIn: $isLoggedIn,
                accessToken: accessToken,
                onLogout: onLogout
            )
        }
        .navigationDestination(isPresented: $isShowingEditRoom) {
            if let roomToEdit = selectedRoomToEdit {
                EditRoomView(
                    isLoggedIn: $isLoggedIn,
                    accessToken: accessToken,
                    onLogout: onLogout,
                    room: roomToEdit,
                    onSave: { updatedRoom in
                        if let index = rooms.firstIndex(where: { $0.id == updatedRoom.id }) {
                            rooms[index] = updatedRoom
                        }
                        isShowingEditRoom = false
                    }
                )
            }
        }
    }

    private func loadRooms() {
        isLoading = true
        errorMessage = nil
        Task {
            do {
                let fetchedRooms = try await RoomHooks.loadRooms()
                self.rooms = fetchedRooms
            } catch {
                self.errorMessage = "Failed to load rooms: \(error.localizedDescription)"
            }
            self.isLoading = false
        }
    }

    private func editRoom(_ room: Room) {
        self.selectedRoomToEdit = room
        self.isShowingEditRoom = true
    }
    
    private func deleteRoom(_ room: Room) {
        RoomHooks.deleteRoom(
            room,
            onSuccess: { updatedRooms in
                self.rooms = updatedRooms
            },
            onError: { error in
                self.errorMessage = error
            },
            currentRooms: self.rooms
        )
    }

    
}
