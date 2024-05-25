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
        destination: 
          NavigationView {
            ProvidersListView()
              .frame(minWidth: 220, maxHeight: .infinity)
            CodeMenuProviderSettingsView()
        }
        .navigationViewStyle(DoubleColumnNavigationViewStyle()),
        label: { Label("Providers", systemImage: "server.rack") }
      )
      
      Spacer()
      
      Button(action: {
        NSWorkspace.shared.open(URL(string: "https://github.com/Extiri/Suggestions")!)
      }, label: {
        Label(title: {
          Text("GitHub repository")
        }, icon: {
          Image("gitHubIcon")
            .renderingMode(.template)
            .resizable()
            .frame(width: 15, height: 15, alignment: .leading)
        })
      })
      .buttonStyle(PlainButtonStyle())
    }
    .listStyle(SidebarListStyle())
    .background(Color.clear)
  }
}
