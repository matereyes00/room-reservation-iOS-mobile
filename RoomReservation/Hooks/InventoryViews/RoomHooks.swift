//
//  RoomHooks.swift
//  RoomReservation
//
//  Created by Martina Reyes on 5/22/25.
//

import Foundation
import SwiftUI

struct RoomHooks {
    static func saveAddedRoom(
        roomName: String,
        roomCapacity: Int,
        roomDescription: String,
        dismiss: @escaping () -> Void,
        setError: @escaping (String?) -> Void
    ) {
        Task {
            do{
                let room = try await RoomsService.shared.addRoom(
                    roomName: roomName,
                    roomCapacity: roomCapacity,
                    roomDescription: roomDescription
                )
                print("Room \(room.roomName) Added Successfully")
                DispatchQueue.main.async {
                    dismiss()  // ✅ safe UI update
                }
            } catch {
                setError("Failed to add room: \(error.localizedDescription)")
            }
        }
    }
    
    static func loadRooms() async throws -> [Room] {
        try await RoomsService.shared.fetchRooms()
    }
    
    static func saveEditedRoom(
        room: Room,
        roomName: String,
        roomCapacity: Int,
        roomDescription: String,
        dismiss: @escaping () -> Void,
        setError: @escaping (String?) -> Void
    ) {
        Task {
            do {
                let updatedRoom = EditRoom(
                    roomName: roomName,
                    roomCapacity: roomCapacity,
                    roomDescription: roomDescription
                )

                let roomResponse = try await RoomsService.shared.editRoom(
                    roomId: room.id,
                    updatedRoom: updatedRoom
                )

                print("Room \(roomResponse.roomName) updated successfully.")

                DispatchQueue.main.async {
                    dismiss()
                }
            } catch {
                DispatchQueue.main.async {
                    setError("Failed to update room: \(error.localizedDescription)")
                }
            }
        }
    }
    
    static func deleteRoom(
        _ room: Room,
        onSuccess: @escaping ([Room]) -> Void,
        onError: @escaping (String) -> Void,
        currentRooms: [Room]
    ) {
        Task {
            do {
                try await RoomsService.shared.deleteRoom(roomId: room.id)
                let updatedRooms = currentRooms.filter { $0.id != room.id }
                DispatchQueue.main.async {
                    onSuccess(updatedRooms)
                }
            } catch {
                DispatchQueue.main.async {
                    onError("Failed to delete room: \(error.localizedDescription)")
                }
            }
        }
    }
}
