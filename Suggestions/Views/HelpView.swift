import SwiftUI

struct HelpView: View {
  var body: some View {
    List {
      Section {
        VStack(alignment: .leading, spacing: 8) {
          Text("Enter \(SettingsManager.shared.settings.callsign)\(SettingsManager.shared.settings.callsign) on any line to show suggestions.")
          Text("Type your query after the signs. The window updates automatically.")
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
      } header: {
        Label("Showing Suggestions", systemImage: "sparkles")
          .font(.headline)
      }
      
      Section {
        VStack(alignment: .leading, spacing: 8) {
          HStack {
            KeyboardKey("⌥")
            Text("+")
            KeyboardKey("[")
            Text("/")
            KeyboardKey("]")
            Spacer()
            Text("Navigate Up/Down")
          }
          
          HStack {
            KeyboardKey("⌥")
            Text("+")
            KeyboardKey("V")
            Spacer()
            Text("Insert Snippet")
          }
          
          Text("For placeholders (@name=#\"\"#), fill values and press ⌥ + V again.")
            .font(.caption)
            .foregroundColor(.secondary)
            .padding(.top, 4)
        }
        .padding(.vertical, 4)
      } header: {
        Label("Navigation & Selection", systemImage: "keyboard")
          .font(.headline)
      }
      
      Section {
        VStack(alignment: .leading, spacing: 8) {
          Text("Set an abbreviation in CodeMenu, then type:")
          HStack {
            Text(SettingsManager.shared.settings.callsign)
              .font(.system(.body, design: .monospaced))
              .bold()
            Text("+")
            Text("abbreviation")
              .font(.system(.body, design: .monospaced))
              .italic()
          }
          Text("The code will appear automatically.")
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
      } header: {
        Label("Abbreviations", systemImage: "textformat.abc")
          .font(.headline)
      }
    }
    .listStyle(SidebarListStyle())
  }
}

struct KeyboardKey: View {
  let key: String
  
  init(_ key: String) {
    self.key = key
  }
  
  var body: some View {
    Text(key)
      .font(.system(.caption, design: .monospaced))
      .bold()
      .padding(.horizontal, 6)
      .padding(.vertical, 2)
      .background(Color.secondary.opacity(0.2))
      .cornerRadius(4)
      .overlay(
        RoundedRectangle(cornerRadius: 4)
          .stroke(Color.secondary.opacity(0.4), lineWidth: 1)
      )
  }
}
