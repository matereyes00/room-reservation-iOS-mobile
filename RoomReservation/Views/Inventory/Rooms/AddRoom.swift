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
    @State private var roomStatus: RoomStatus = .active
    
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Add Room")
                    .font(.title)
                
                Form {
                    TextField("Room Name", text: $roomName)
                    TextField("Room Description", text: $roomDescription)
                    TextField("Room Capacity", value: $roomCapacity, formatter: NumberFormatter())
                        .keyboardType(.numberPad)
                    Picker("Room Status", selection: $roomStatus) {
                        Text("Active").tag(RoomStatus.active)
                        Text("Inactive").tag(RoomStatus.inactive)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                
                    Button("Save") {
                        print("Do something")
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
struct AddRoomView_Previews: PreviewProvider {
    @State static var loggedIn = true

    static var previews: some View {
        AddRoomView(
            isLoggedIn: $loggedIn,               // Binding to the @State var
            accessToken: "dummy_access_token",  // Sample string for preview
            onLogout: { print("Logged out") }   // Simple closure for preview
        )
    }
}
