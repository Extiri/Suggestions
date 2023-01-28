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
    }
    .listStyle(SidebarListStyle())
    .background(Color.clear)
  }
}
