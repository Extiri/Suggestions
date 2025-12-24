//
//  SidebarView.swift
//  Suggestions
//
//  Created by Wiktor Wójcik on 28/01/2023.
//

import SwiftUI

struct SidebarView: View {
  var body: some View {
    List {
      NavigationLink(
        destination: SettingsView(),
        label: { Label("Settings", systemImage: "gear") }
      )
      NavigationLink(
        destination: HelpView(),
        label: { Label("Help", systemImage: "questionmark.circle") }
      )
      
      NavigationLink(
        destination: ProvidersListView(),
        label: { Label("Providers", systemImage: "server.rack") }
      )
      
      Spacer()
      
      Link(destination: URL(string: "https://github.com/Extiri/Suggestions")!) {
        Label {
          Text("GitHub Repository")
        } icon: {
          Image("gitHubIcon")
            .resizable()
            .frame(width: 16, height: 16)
        }
      }
      .padding(.vertical, 8)
    }
    .listStyle(SidebarListStyle())
  }
}
