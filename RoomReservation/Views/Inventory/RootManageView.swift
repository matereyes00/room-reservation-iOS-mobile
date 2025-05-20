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
    let onAdd: (() -> Void)?

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
    
    // ✅ Custom initializer with default value for onAdd
       init(
           title: String,
           searchText: Binding<String>,
           items: [Item],
           onAdd: (() -> Void)? = nil,
           content: @escaping ([Item]) -> Content
       ) {
           self.title = title
           self._searchText = searchText
           self.items = items
           self.onAdd = onAdd
           self.content = content
       }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.largeTitle)
                .bold()
                .padding(.top)

            Divider()

            if let onAdd = onAdd {
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
            }

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
