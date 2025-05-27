//
//  AddRoom.swift
//  RoomReservation
//
//  Created by Martina Reyes on 5/16/25.
//

import SwiftUI

struct AddRoomView: View {
    @Binding var isLoggedIn: Bool
    let accessToken: String
    let onLogout: () -> Void
    @State private var errorMessage: String? = nil

    @State private var roomName: String = ""
    @State private var roomCapacity: Int = 0
    @State private var roomDescription: String = ""
    
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Add Room")
                    .font(.title)
                
                Form {
                    TextField("Room Name", text: $roomName)
                        .autocapitalization(.none)
                    TextField("Room Description", text: $roomDescription)
                        .autocapitalization(.none)
                    TextField("Room Capacity", value: $roomCapacity, formatter: NumberFormatter())
                        .autocapitalization(.none)
                        .keyboardType(.numberPad)
//                    Picker("Room Status", selection: $roomStatus) {
//                        Text("Active").tag(RoomStatus.active)
//                        Text("Inactive").tag(RoomStatus.inactive)
//                    }
//                    .pickerStyle(SegmentedPickerStyle())
//                
                    Button("Save") {
                        RoomHooks.saveAddedRoom(
                                roomName: roomName,
                                roomCapacity: roomCapacity,
                                roomDescription: roomDescription,
                                dismiss: { dismiss() },
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

