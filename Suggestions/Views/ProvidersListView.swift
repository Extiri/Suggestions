//
//  ProvidersView.swift
//  Suggestions
//
//  Created by Wiktor Wójcik on 24/05/2024.
//

import SwiftUI

struct Provider: Identifiable, Hashable {
  let id: String
  let icon: NSImage
  let name: String
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
  
  static func == (lhs: Provider, rhs: Provider) -> Bool {
    lhs.id == rhs.id
  }
}

struct ProvidersListView: View {
  @State var providers: [Provider] = [.init(id: "codemenu", icon: NSImage(named: "CodeMenu_icon")!, name: "CodeMenu")]
  @State var selection: String? = "codemenu"
  
  var body: some View {
    HSplitView {
      List(selection: $selection) {
        ForEach(providers) { provider in
          HStack {
            Image(nsImage: provider.icon)
              .resizable()
              .frame(width: 24, height: 24)
            Text(provider.name)
              .font(.headline)
          }
          .padding(.vertical, 4)
          .tag(provider.id)
        }
      }
      .listStyle(SidebarListStyle())
      .frame(minWidth: 200, maxWidth: 300)
      
      if let selection, let provider = providers.first(where: { $0.id == selection }) {
        destination(for: provider)
          .frame(maxWidth: .infinity, maxHeight: .infinity)
      } else {
        Text("Select a provider")
          .frame(maxWidth: .infinity, maxHeight: .infinity)
      }
    }
  }
  
  @ViewBuilder
  func destination(for provider: Provider) -> some View {
    switch provider.id {
    case "codemenu":
      CodeMenuProviderSettingsView()
    default:
      Text("Unknown Provider")
    }
  }
}
