//
//  AddRoom.swift
//  RoomReservation
//
//  Created by Martina Reyes on 5/16/25.
//

import SwiftUI

struct EditRoomView: View {
    @Binding var isLoggedIn: Bool
    let accessToken: String
    let onLogout: () -> Void
    var room: Room
    var onSave: (Room) -> Void
    
    @State private var errorMessage: String? = nil
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var roomName: String
    @State private var roomCapacity: Int
    @State private var roomDescription: String

    init(isLoggedIn: Binding<Bool>, accessToken: String, onLogout: @escaping () -> Void, room: Room, onSave: @escaping (Room) -> Void) {
        self._isLoggedIn = isLoggedIn
        self.accessToken = accessToken
        self.onLogout = onLogout
        self.room = room
        self.onSave = onSave
        _roomName = State(initialValue: room.roomName)
        _roomCapacity = State(initialValue: room.roomCapacity)
        _roomDescription = State(initialValue: room.roomDescription ?? "")
    }


    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Edit Room")
                    .font(.title)
                
                Form {
                    TextField("Room Name", text: $roomName)
                        .autocapitalization(.none)
                    TextField("Room Description", text: $roomDescription)
                        .autocapitalization(.none)
                    TextField("Room Capacity", value: $roomCapacity, formatter: NumberFormatter())
                        .autocapitalization(.none)
                        .keyboardType(.numberPad)
                    Button("Save") {
                        RoomHooks.saveEditedRoom(
                            room: room,
                            roomName: roomName,
                            roomCapacity: roomCapacity,
                            roomDescription: roomDescription,
                            dismiss: {
                                let updatedRoom = Room(
                                    id: room.id,
                                    roomName: roomName,
                                    roomCapacity: roomCapacity,
                                    roomDescription: roomDescription,
                                    roomStatus: room.roomStatus
                                )
                                onSave(updatedRoom)
                            },
                            setError: { msg in errorMessage = msg }
                        )

                    }

                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .padding()
            .navigationBarBackButtonHidden(true)
            .disableBackSwipe()
        }
    }
}

