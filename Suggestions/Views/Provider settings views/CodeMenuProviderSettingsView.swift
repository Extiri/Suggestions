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
    ScrollView {
      VStack(alignment: .leading, spacing: 20) {
        GroupBox(label: Text("Status").font(.headline)) {
          Toggle("Enable CodeMenu Provider", isOn: $isEnabled)
            .padding(8)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        
        GroupBox(label: Text("Connection Details").font(.headline)) {
          VStack(alignment: .leading, spacing: 12) {
            HStack {
              Text("Port:")
                .frame(width: 80, alignment: .trailing)
              TextField("1300", text: $newPort)
                .frame(width: 80)
                .disabled(!isEnabled)
              Text("(Default: 1300)")
                .foregroundColor(.secondary)
              Spacer()
            }
            
            HStack {
              Text("Access Key:")
                .frame(width: 80, alignment: .trailing)
              SecureField("Optional", text: $newKey)
                .frame(maxWidth: 250)
                .disabled(!isEnabled)
              Spacer()
            }
            
            HStack {
              Spacer()
                .frame(width: 88)
              Text("Leave empty if the server is unprotected.")
                .font(.caption)
                .foregroundColor(.secondary)
            }
          }
          .padding(8)
          .frame(maxWidth: .infinity, alignment: .leading)
        }
        
        HStack {
          Spacer()
          Button("Save Connection Settings") {
            save()
          }
          .disabled(!isEnabled)
          Spacer()
        }
      }
      .padding()
      .frame(maxWidth: .infinity, alignment: .topLeading)
    }
    .onAppear {
      newKey = key
      newPort = String(port)
    }
  }
  
  func save() {
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
}
