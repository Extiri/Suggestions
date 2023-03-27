//
//  PlaceholderSettingView.swift
//  CodeMenu
//
//  Created by Wiktor Wójcik on 09/02/2023.
//

import SwiftUI

class Placeholders: ObservableObject {
  init(placeholders: [String : String]) {
    self.placeholders = placeholders
  }
  
  @Published var placeholders: [String: String]
}

struct PlaceholderSettingView: View {
  @StateObject var placeholders: Placeholders
  
    var body: some View {
      ScrollView {
        VStack {
          ForEach(Array(placeholders.placeholders.keys), id: \.self) { key in
            HStack {
              Text(key)
              TextField(key, text: .init(get: { placeholders.placeholders[key, default: ""] }, set: { placeholders.placeholders[key] = $0 }))
            }
            .padding(5)
          }
        }
      }
    }
}
