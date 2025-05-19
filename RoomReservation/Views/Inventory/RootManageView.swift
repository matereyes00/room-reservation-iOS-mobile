//
//  RootView.swift
//  Authenticator
//
//  Created by Martina Reyes on 5/16/25.
//

import SwiftUI

struct RootManageView<Item: Identifiable, Content: View>: View {
    let title: String
    @Binding var searchText: String
    let onAdd: () -> Void
    let content: ([Item]) -> Content
    let items: [Item]

    var filteredItems: [Item] {
        if searchText.isEmpty {
            return items
        } else {
            // This filtering is generic; you can customize by passing a filter closure if needed.
            // Or let the caller filter before passing items.
            // For now, assume Item conforms to a protocol with `name` property or you pass filteredItems directly.
            return items
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.largeTitle)
                .bold()
                .padding(.top)

            Divider()

            HStack {
                Button(action: onAdd) {
                    Text("Add")
                        .padding(8)
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(8)
                }
                Spacer()
            }
            .padding(.horizontal)

            content(filteredItems)
                .padding(.horizontal)
        }
        .padding()
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .automatic), prompt: "Search")
    }
}


//struct RootManageView_Previews: PreviewProvider {
//    static var previews: some View {
//        RootManageView(title: "Preview Title") {
//            Text("This is the preview content.")
//        }
//    }
//}
