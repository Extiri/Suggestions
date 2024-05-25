//
//  CodeMenuProviderSettingsView.swift
//  Suggestions
//
//  Created by Wiktor Wójcik on 24/05/2024.
//

import SwiftUI
import Defaults

struct CodeMenuProviderSettingsView: View {
  @Default(.codeMenuProviderIsEnabled) var isEnabled
  @Default(.codeMenuProviderKey) var key
  @Default(.codeMenuProviderPort) var port
  
  @State var newPort: String = "1300"
  @State var newKey = ""
  
  var body: some View {
    VStack(alignment: .leading) {
      Toggle(isOn: $isEnabled) {
        Text("Enable CodeMenu provider")
      }
      .toggleStyle(.checkbox)
      .padding(.bottom, 10)
      
      Group {
        Text("Port")
          .font(.title3.bold())
        Text("Enter the port set in CodeMenu.")
        TextField("Port", text: $newPort)
          .disabled(!isEnabled)
      }
      .padding(.bottom, 10)
      
      Divider()
      
      Group {
        Text("Access key")
          .font(.title3.bold())
        Text("Enter the access key set in CodeMenu. If the server is unprotected, leave the field empty.")
        TextField("Access key (if none, leave empty)", text: $newKey)
          .disabled(!isEnabled)
      }
      .padding(.bottom, 10)
      
      Divider()
      
      Button("Save") {
        if newPort.contains(where: { !"0123456789".contains($0) }) {
          showAlert(message: "Invalid port", informative: "Port must be made of numbers only.")
          return
        }
        
        if newPort.isEmpty {
          showAlert(message: "Invalid port", informative: "Port must not be empty.")
          return
        }
        
        key = newKey
        port = Int(newPort)!
      }
      .disabled(!isEnabled)
      .onAppear {
        newKey = key
        newPort = String(port)
      }
      
      Spacer()
    }
    .padding()
  }
}
