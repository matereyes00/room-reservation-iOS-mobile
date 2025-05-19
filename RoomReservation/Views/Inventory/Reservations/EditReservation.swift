//
//  AddRoom.swift
//  RoomReservation
//
//  Created by Martina Reyes on 5/16/25.
//

import SwiftUI

struct EditReservationView: View {
    @Binding var isLoggedIn: Bool
    let accessToken: String
    let onLogout: () -> Void
    let reservation: Reservation // 👈 ADD THIS LINE
    
    @State private var errorMessage: String? = nil
    @Environment(\.dismiss) private var dismiss

    // Form State
    @State private var numberOfParticipants: Int = 1
    @State private var bookingStatus: ReservationStatus = .pending
    @State private var isRoomBeingUsed: RoomStatus = .active
    
    @State private var startBookingDate: Date = Date()
    @State private var endBookingDate: Date = Date()
    
    @State private var bookingTimeStart: Date = Date()
    @State private var bookingTimeEnd: Date = Date()
    
    @State private var selectedUser: User?
    @State private var selectedRoom: Room?

    
    @State private var users: [User] = []
    @State private var rooms: [Room] = []


    var body: some View {
        NavigationStack {
            Form {
                Section {
                    DatePicker("Start Date", selection: $startBookingDate, displayedComponents: .date)
                    DatePicker("End Date", selection: $endBookingDate, displayedComponents: .date)
                } header: {
                    Text("Booking Dates")
                }

                Section {
                    DatePicker("Start Time", selection: $bookingTimeStart, displayedComponents: .hourAndMinute)
                    DatePicker("End Time", selection: $bookingTimeEnd, displayedComponents: .hourAndMinute)
                } header: {
                    Text("Booking Times")
                }

                Section {
                    Stepper(value: $numberOfParticipants, in: 1...100) {
                        Text("Participants: \(numberOfParticipants)")
                    }
                    
                    Picker("Room Status", selection: $isRoomBeingUsed) {
                        ForEach(RoomStatus.allCases, id: \.self) { status in
                            Text(status.rawValue).tag(status)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    Picker("Reservation Status", selection: $bookingStatus) {
                        ForEach(ReservationStatus.allCases, id: \.self) { status in
                            Text(status.rawValue).tag(status)
                        }
                    }
                } header: {
                    Text("Details")
                }
                
                Section {
                    Picker("Room", selection: $selectedRoom) {
                        ForEach(rooms, id: \.id) { room in
                            Text(room.roomName).tag(room as Room?)
                        }
                    }
                } header: {
                    Text("Room")
                }
                
                Section {
                    Picker("User", selection: $selectedUser) {
                        ForEach(users, id: \.id) { user in
                            Text(user.name).tag(user as User?)
                        }
                    }
                } header: {
                    Text("User")
                }


                Section {
                    Button("Save") {
                        let reservation = Reservation(
                            id: UUID().uuidString,
                            startBookingDate: startBookingDate,
                            endBookingDate: endBookingDate,
                            bookingTimeStart: bookingTimeStart,
                            bookingTimeEnd: bookingTimeEnd,
                            isRoomBeingUsed: isRoomBeingUsed,
                            bookingStatus: bookingStatus,
                            numberOfParticipants: numberOfParticipants,
                            room: selectedRoom,
                            user: selectedUser,
                            createdAt: Date(),
                            updatedAt: Date()
                        )
                        print("Reservation to save: \(reservation)")
                    }

                    Button("Cancel") {
                        dismiss()
                    }
                }
            }

            .navigationTitle("Edit Reservation")
            .navigationBarBackButtonHidden(true)
            .disableBackSwipe()
        }
        .task {
            do {
                users = try await UsersService.shared.fetchAllUsers()
                rooms = try await RoomsService.shared.fetchRooms()

                if let firstUser = users.first {
                    selectedUser = firstUser
                }
                if let firstRoom = rooms.first {
                    selectedRoom = firstRoom
                }
            } catch {
                print("Error fetching data")
            }
        }

    }
}

struct EditReservationView_Previews: PreviewProvider {
    @State static var loggedIn = true

    static var previews: some View {
        AddReservationView(
            isLoggedIn: $loggedIn,
            accessToken: "dummy_access_token",
            onLogout: { print("Logged out") }
        )
    }
}
