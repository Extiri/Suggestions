//
//  PlaceholdersManager.swift
//  Suggestions
//
//  Created by Wiktor Wójcik on 11/02/2023.
//

import SwiftUI

class Placeholders: ObservableObject {
  init(placeholders: [String : String]) {
    self.placeholders = placeholders
  }
  
  @Published var placeholders: [String: String]
}

class PlaceholdersManager {
  /// Placholders are denoted using @__name__@ syntax. Name can be only made of lowercase and uppercase latin letters.
  static let placeholderPattern = "@__([a-zA-Z]+)__@"
  static let placeholderQueryPattern = "@([a-zA-Z]+)=#\"([^#\"]+)\"#"
  static var specialPlaceholders = ["date", "time"]

  public static func setPlaceholders(code: String, values: [String: String] = [:]) -> String {
    var code = code
    
    code = code.replacingOccurrences(of: "@__date__@", with: Date().localizedFormatted(using: "dd/MM/yyyy"))
    code = code.replacingOccurrences(of: "@__time__@", with: Date().formatted(using: "H:mm"))
    
    for (key, value) in values {
      code = code.replacingOccurrences(of: "@__\(key)__@", with: value)
    }
    
    return code
  }
  
  static func parseAndSetPlaceholders(query: String, code: String, placeholders: PlaceholdersDictionary) -> String {
    var values = try! query.groups(for: placeholderQueryPattern).map { Array($0.dropFirst(1)) }.reduce([String: String]()) { dict, element in
      var dict = dict
      dict[element[0]] = element[1]
      return dict
    }
    
    for placeholder in placeholders {
      if placeholder.value.isAutoFilled {
        switch placeholder.value {
          case .Shell(let script):
            do {
              values[placeholder.key] = try shell(script)
            } catch {
              showAlert(message: "Error while running script for key \"\(placeholder.key)\"", informative: "Script: \(script). Error: \(error.localizedDescription)")
            }
          default: break
        }
      }
    }
    
    return PlaceholdersManager.setPlaceholders(code: code, values: values)
  }

  static func getPlaceholders(code: String) -> [String] {
    // Try can be forced, because this pattern is always valid.
    Array(Set(try! code.groups(for: placeholderPattern).map { $0[1] })).sorted()
  }
  
  static func createPlaceholdersQuery(code: String, placeholders: PlaceholdersDictionary) -> String {
    // The sequnce for a placeholder argument is @name=#"value"#
    return placeholders.filter { !specialPlaceholders.contains($0.key) || !$0.value.isAutoFilled }.map { "@\($0.key)=#\"\"#" }.joined(separator: " ")
  }
  
  static func hasPlaceholdersToFill(placeholders: PlaceholdersDictionary) -> Bool {
    for (_, placeholder) in placeholders {
      if !placeholder.isAutoFilled {
        return true
      }
    }
    
    return placeholders.count > 2
  }
  
  static func getPlaceholdersDictionary(code: String) -> [String: String] {
    Array(Set(try! code.groups(for: placeholderPattern).map { $0[1] })).sorted().reduce([String: String]()) { dict, placeholder in
      var dict = dict
      dict[placeholder] = ""
      return dict
    }
  }
  
  public static func getDictionary(code: String, placeholders: PlaceholdersDictionary) -> [String: String]? {
    let placeholdersList = Placeholders(placeholders: placeholders.filter { !Self.specialPlaceholders.contains($0.key) }.reduce([String: String]()) { dict, placeholder in
      var dict = dict
      dict[placeholder.key] = ""
      return dict
    })
    
    for (key, value) in placeholdersList.placeholders {
      if placeholders[key]?.isAutoFilled ?? false {
        switch placeholders[key]! {
          case .Shell(let command):
            do {
              placeholdersList.placeholders[key] = try shell(command)
            } catch {
              showAlert(message: "Error running \"\(key)\"", informative: error.localizedDescription)
              Debug.log(error)
              return nil
            }
          case .None:
            // All others are ignored, because they are not auto-filled.
            return nil
        }
      }
    }
    
    return placeholdersList.placeholders
  }
  
  static func askForPlaceholderSetting(title: String, code: String, placeholdersToFill: [String: Suggestion.PlaceholderAction]) -> String? {
    let msg = NSAlert()
    
    msg.addButton(withTitle: "Done")
    msg.addButton(withTitle: "Cancel")
    msg.messageText = title
    msg.informativeText = "Fill in placeholder values."
    
    let placeholders = Placeholders(placeholders: placeholdersToFill.filter { !Self.specialPlaceholders.contains($0.key) }.reduce([String: String]()) { dict, placeholder in
      var dict = dict
      dict[placeholder.key] = ""
      return dict
    })
    
    let view = NSHostingView(rootView: PlaceholderSettingView(placeholders: placeholders, specialPlaceholders: placeholdersToFill))
    view.frame = NSRect(x: 0, y: 0, width: 300, height: view.fittingSize.height)
    
    msg.accessoryView = view
    
    let response: NSApplication.ModalResponse = msg.runModal()
    
    if response == NSApplication.ModalResponse.alertFirstButtonReturn {
      for (key, value) in placeholders.placeholders {
        if placeholdersToFill[key]?.isAutoFilled ?? false {
          switch placeholdersToFill[key]! {
            case .Shell(let command):
              do {
                placeholders.placeholders[key] = try shell(command)
              } catch {
                showAlert(message: "Error running \"\(key)\"", informative: error.localizedDescription)
                Debug.log(error)
                return nil
              }
            case .None:
              // All others are ignored, because they are not auto-filled.
              return nil
          }
        }
      }
      
      return PlaceholdersManager.setPlaceholders(code: code, values: placeholders.placeholders)
    } else {
      return nil
    }
  }
  
  struct PlaceholderSettingView: View {
    @StateObject var placeholders: Placeholders
    var specialPlaceholders: [String: Suggestion.PlaceholderAction]
    @State var widestNameWidth: CGFloat = 1
    
    var body: some View {
      ScrollView {
        VStack {
          ForEach(Array(placeholders.placeholders.keys), id: \.self) { key in
            HStack {
              Text(key)
              
              if PlaceholdersManager.specialPlaceholders.contains(key) {
                Text(key.capitalized)
              } else {
                switch specialPlaceholders[key] {
                  case .None:
                    TextField(key, text: .init(get: { placeholders.placeholders[key, default: ""] }, set: { placeholders.placeholders[key] = $0 }))
                  case .Shell(_):
                    Text("Shell")
                      .frame(maxWidth: .infinity)
                  case .none:
                    TextField(key, text: .init(get: { placeholders.placeholders[key, default: ""] }, set: { placeholders.placeholders[key] = $0 }))
                }
              }
            }
            .padding(5)
          }
        }
      }
    }
  }

}

func shell(_ command: String) throws -> String {
  let task = Process()
  let pipe = Pipe()
  
  task.standardOutput = pipe
  task.standardError = pipe
  task.arguments = ["-c", command]
  task.executableURL = URL(fileURLWithPath: "/bin/zsh")
  task.standardInput = nil
  
  try task.run()
  
  let data = pipe.fileHandleForReading.readDataToEndOfFile()
  let output = String(data: data, encoding: .utf8)!
  
  return output
}
