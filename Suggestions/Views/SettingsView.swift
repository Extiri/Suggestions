import SwiftUI
import Highlightr

struct SettingsView: View {
  @State var refreshRate = 1.0
  
  @State var dissalowedApps = [String]()
  @State var selectedApp = NSWorkspace.shared.runningApplications.first(where: { $0.activationPolicy == .regular })?.localizedName ?? "Unknown app"
  @State var highlightingTheme = "Default"
  @State var callsign: String = SettingsManager.shared.settings.callsign
  
  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 20) {
        GroupBox(label: Text("General").font(.headline)) {
          VStack(alignment: .leading, spacing: 12) {
            HStack {
              Text("Refresh Rate:")
                .frame(width: 100, alignment: .trailing)
              Slider(value: $refreshRate, in: 1...10, step: 1)
              Text("\(Int(refreshRate))")
                .frame(width: 30)
              Text("(every \(String(format: "%.1f", 1.0/refreshRate))s)")
                .foregroundColor(.secondary)
            }
            
            HStack {
              Spacer()
                .frame(width: 108)
              Text("Higher values are smoother but use more CPU.")
                .font(.caption)
                .foregroundColor(.secondary)
            }
            
            Divider()
            
            HStack {
              Text("Callsign:")
                .frame(width: 100, alignment: .trailing)
              TextField("", text: $callsign)
                .frame(width: 40)
                .multilineTextAlignment(.center)
                .onChange(of: callsign) { changedCallsign in
                  if changedCallsign.count > 1 {
                    callsign = String(changedCallsign[changedCallsign.startIndex])
                  }
                }
              
              if callsign != "§" {
                Button("Reset") {
                  callsign = "§"
                }
              }
              Spacer()
            }
            
            HStack {
              Spacer()
                .frame(width: 108)
              Text("The character used to invoke Suggestions (e.g. §§).")
                .font(.caption)
                .foregroundColor(.secondary)
            }
          }
          .padding(8)
        }
        
        GroupBox(label: Text("Appearance").font(.headline)) {
          VStack(alignment: .leading, spacing: 12) {
            HStack {
              Text("Theme:")
                .frame(width: 100, alignment: .trailing)
              Picker("", selection: $highlightingTheme) {
                Text("Default").tag("Default")
                Divider()
                ForEach(Highlightr()!.availableThemes().sorted(), id: \.self) { theme in
                  Text(theme).tag(theme)
                }
              }
              .labelsHidden()
              .frame(maxWidth: 250)
              Spacer()
            }
          }
          .padding(8)
        }
        
        GroupBox(label: Text("Disallowed Apps").font(.headline)) {
          VStack(alignment: .leading, spacing: 12) {
            HStack {
              Text("Add App:")
                .frame(width: 100, alignment: .trailing)
              Picker("", selection: $selectedApp) {
                ForEach(NSWorkspace.shared.runningApplications.filter { $0.activationPolicy == .regular }, id: \.processIdentifier) { app in
                  Text(app.localizedName ?? "Unknown").tag(app.localizedName ?? "Unknown")
                }
              }
              .labelsHidden()
              .frame(maxWidth: 250)
              
              Button(action: {
                if !dissalowedApps.contains(selectedApp) {
                  dissalowedApps.append(selectedApp)
                }
              }) {
                Image(systemName: "plus")
              }
            }
            
            if dissalowedApps.isEmpty {
              Text("No disallowed apps")
                .foregroundColor(.secondary)
                .italic()
                .frame(maxWidth: .infinity, alignment: .center)
                .padding()
            } else {
              List {
                ForEach(Array(dissalowedApps.enumerated()), id: \.offset) { index, appName in
                  HStack {
                    Text(appName)
                    Spacer()
                    Button(action: {
                      dissalowedApps.remove(at: index)
                    }) {
                      Image(systemName: "trash")
                        .foregroundColor(.red)
                    }
                    .buttonStyle(PlainButtonStyle())
                  }
                }
              }
              .frame(height: 150)
              .border(Color.secondary.opacity(0.2))
            }
          }
          .padding(8)
        }
        
        HStack {
          Spacer()
          Button("Save Settings", action: save)
            .controlSize(.large)
          Spacer()
        }
      }
      .padding()
    }
    .onAppear(perform: fillCurrentData)
  }
  
  func fillCurrentData() {
    let settings = SettingsManager.shared.settings
    
    callsign = settings.callsign
    refreshRate = settings.refreshRate
    dissalowedApps = settings.disallowlist
    highlightingTheme = settings.highlightingTheme ?? "Default"
  }
  
  func save() {
    var settings  = SettingsManager.shared.settings
    
    settings.callsign = callsign
    settings.refreshRate = refreshRate
    settings.disallowlist = dissalowedApps
    settings.highlightingTheme = highlightingTheme == "Default" ? nil : highlightingTheme
    
    SettingsManager.shared.settings = settings
  }
}
