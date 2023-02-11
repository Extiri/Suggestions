//
//  PlaceholdersManager.swift
//  Suggestions
//
//  Created by Wiktor Wójcik on 11/02/2023.
//

import SwiftUI

class PlaceholdersManager {
  /// Placholders are denoted using @__name__@ syntax. Name can be only made of lowercase and uppercase latin letters.
  static let placeholderPattern = "@__([a-zA-Z]+)__@"
  static let placeholderQueryPattern = "@([a-zA-Z]+)=#\"([^#\"]+)\"#"
  static var specialPlaceholders = ["date", "time"]

  static func setSpecialPlaceholders(code: String) -> String {
    var code = code
    
    code = code.replacingOccurrences(of: "@__date__@", with: Date().localizedFormatted(using: "dd/MM/yyyy"))
    code = code.replacingOccurrences(of: "@__time__@", with: Date().formatted(using: "H:mm"))
    
    return code
  }
  
  static func parseAndSetPlaceholders(query: String, code: String) -> String {
    let values = try! query.groups(for: placeholderQueryPattern).map { Array($0.dropFirst(1)) }.reduce([String: String]()) { dict, element in
      var dict = dict
      dict[element[0]] = element[1]
      return dict
    }
    
    return PlaceholdersManager.setPlaceholders(code: code, values: values)
  }

  static func getPlaceholders(code: String) -> [String] {
    // Try can be forced, because this pattern is always valid.
    Array(Set(try! code.groups(for: placeholderPattern).map { $0[1] })).sorted()
  }
  
  static func createPlaceholdersQuery(code: String) -> String {
    let placeholders = getPlaceholders(code: code)
    // The sequnce for a placeholder argument is @name=#"value"#
    return placeholders.filter { !specialPlaceholders.contains($0) }.map { "@\($0)=#\"\"#" }.joined(separator: " ")
  }
  
  static func hasPlaceholders(code: String) -> Bool {
    return !(try! code.groups(for: placeholderPattern).map { $0[1] }.filter { !specialPlaceholders.contains($0) }.isEmpty)
  }
  
  static func getPlaceholdersDictionary(code: String) -> [String: String] {
    Array(Set(try! code.groups(for: placeholderPattern).map { $0[1] })).sorted().reduce([String: String]()) { dict, placeholder in
      var dict = dict
      dict[placeholder] = ""
      return dict
    }
  }
  
  static func setPlaceholders(code: String, values: [String: String]) -> String {
    var code = setSpecialPlaceholders(code: code)
    
    for (key, value) in values {
      code = code.replacingOccurrences(of: "@__\(key)__@", with: value)
    }
    
    return code
  }
}
