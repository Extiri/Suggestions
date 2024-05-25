//
//  ProvidersView.swift
//  Suggestions
//
//  Created by Wiktor Wójcik on 24/05/2024.
//

import SwiftUI

struct Provider: Identifiable {
  let id: String
  let icon: NSImage
  let name: String
}

struct ProviderPreview: View {
  let provider: Provider
  
  var body: some View {
    HStack(alignment: .center) {
      Image(nsImage: provider.icon)
        .resizable()
        .padding(2)
        .frame(width: 40, height: 40)
      
      
      Text(provider.name)
        .font(.title3.bold())
    }
    .frame(height: 50)
    .padding([.leading, .trailing], 5)
  }
}

struct ProvidersListView: View {
  @State var providers: [Provider] = [.init(id: "codemenu", icon: NSImage(named: "CodeMenu_icon")!, name: "CodeMenu")]
  @State var selected = 0
  
  var body: some View {
    // For unknown reasons, when I replace VStack with List, everything dissapears, so for the time being, I'm reinventing the wheel.
    VStack(alignment: .leading) {
      Spacer()
        .frame(height: 5)
      
      NavigationLink(destination: {
        switch providers[0].id {
        case "codemenu":
          CodeMenuProviderSettingsView()
        default:
          EmptyView()
        }
      }, label: {
        ProviderPreview(provider: providers[0])
          .frame(maxWidth: .infinity)
      })
      .buttonStyle(PlainButtonStyle())
      .background(
        RoundedRectangle(cornerRadius: 8)
          .foregroundColor(selected == 0 ? Color.accentColor : Color.clear)
      )
      .padding([.leading, .trailing], 5)
      
      Divider()
      
      Spacer()
        .frame(maxHeight: .infinity)
    }
    .frame(maxHeight: .infinity)
  }
}
