//
//  Navigation.swift
//  Authenticator
//
//  Created by Martina Reyes on 5/16/25.
//

import SwiftUI

struct MainTabView: View {
    let accessToken: String
    @Binding var isLoggedIn: Bool
    let onLogout: () -> Void

    var body: some View {
        TabView {
            NavigationStack {
                HomeView(
                    isLoggedIn: $isLoggedIn,
                    accessToken: accessToken,
                    onLogout: onLogout
                )
            }
            .tabItem {
                Label("Home", systemImage: "building.2")
            }
            
            NavigationStack {
                InventoryView(
                    isLoggedIn: $isLoggedIn,
                    accessToken: accessToken,
                    onLogout: onLogout
                )
            }
            .tabItem {
                Label("Inventory", systemImage: "shippingbox")
            }
            
            NavigationStack {
                NotificationsView(isLoggedIn: $isLoggedIn, accessToken: accessToken, onLogout: onLogout)
            }
            .tabItem {
                Label("Notification", systemImage: "bell")
            }

            NavigationStack {
                ProfileView(isLoggedIn: $isLoggedIn, accessToken: accessToken, onLogout: onLogout)
            }
            .tabItem {
                Label("Profile", systemImage: "person.crop.circle")
            }
        }
    }
}
