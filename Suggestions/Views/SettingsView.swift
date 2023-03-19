import SwiftUI
import Highlightr

struct SettingsView: View {
  @State var refreshRate = 1.0
  
  @State var dissalowedApps = [String]()
  @State var selectedApp = NSWorkspace.shared.runningApplications[0].localizedName ?? "Unknown app"
  @State var highlightingTheme = "Default"
  
  var body: some View {
    ScrollView {
      VStack(alignment: .leading) {
        Group {
          Text("Refresh rate")
            .font(.title3.bold())
          Text("Refresh rate defines how often Suggestions will check your search text (eg. text after §§ signs) and update results. The default is 1 (refresh every 0.1 second). The higher this number is, the smoother the results will be, but it will also be more intensive for CPU. You have to restart CodeMenu Suggestions to update refresh rate.")
          
          HStack {
            Slider(value: $refreshRate, in: 1...10, step: 1)
            Text("\(Int(refreshRate))")
          }
        }
        
        Group {
          Text("Code highlighting theme")
            .font(.title3.bold())
          Text("By default, it's either paraiso-dark or paraiso-light for current macOS apperance (dark or light).")
          
          Picker("Theme:", selection: $highlightingTheme) {
            Text("Default")
              .tag("Default")
            
            Divider()
            
            ForEach(Highlightr()!.availableThemes().sorted(), id: \.self) { theme in
              Text(theme)
                .tag(theme)
            }
          }
        }
        
        Divider()
        
        Divider()
        
        Group {
          Text("Dissalow list")
            .font(.title3.bold())
          Text("Choose apps where Suggestions should not work.")
          
          HStack {
            Picker("App:", selection: $selectedApp) {
              ForEach(NSWorkspace.shared.runningApplications, id: \.processIdentifier) { app in
                Text(app.localizedName ?? "Unknown app name")
                  .tag(app.localizedName ?? "Unknown app name")
              }
            }
            
            Button(action: {
              dissalowedApps.append(selectedApp)
            }, label: {
              Image(systemName: "plus.circle.fill")
                .foregroundColor(.green)
            })
            .buttonStyle(PlainButtonStyle())
          }
          
          if dissalowedApps.isEmpty {
            Text("No dissalowed apps")
          } else {
            ScrollView {
              ForEach(Array(dissalowedApps.enumerated()), id: \.offset) { enumeration in
                HStack(alignment: .bottom) {
                  Button(action: {
                    dissalowedApps.remove(at: enumeration.offset)
                  }, label: {
                    Image(systemName: "minus.circle.fill")
                      .foregroundColor(.red)
                  })
                  .buttonStyle(PlainButtonStyle())
                  
                  Text(enumeration.element)
                  
                  Spacer()
                }
                .frame(alignment: .leading)
                
                Divider()
              }
            }
            .padding()
            .border(.gray, width: 0.4)
            .frame(width: 400, height: 300)
            .padding(6)
          }
        }
        
        Divider()
        
        Button("Save", action: save)
        
        Spacer()
      }
      .padding()
    }
    .onAppear(perform: fillCurrentData)
  }
  
  func fillCurrentData() {
    let settings = SettingsManager.shared.settings
    
    refreshRate = settings.refreshRate
    dissalowedApps = settings.disallowlist
    highlightingTheme = settings.highlightingTheme ?? "Default"
  }
  
  func save() {
    var settings  = SettingsManager.shared.settings
    
    settings.refreshRate = refreshRate
    settings.disallowlist = dissalowedApps
    settings.highlightingTheme = highlightingTheme == "Default" ? nil : highlightingTheme
    
    SettingsManager.shared.settings = settings
  }
}
