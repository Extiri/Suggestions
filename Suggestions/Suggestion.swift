//
//  Suggestion.swift
//  Suggestions
//
//  Created by Wiktor Wójcik on 15/07/2023.
//

import Foundation

typealias PlaceholdersDictionary = [String: Suggestion.PlaceholderAction]

struct Suggestion {
  var title: String
  var description: String
  var code: String
  var language: String
  var abbreviation: String
  var placeholders: [String: PlaceholderAction]
  
  enum PlaceholderAction: Codable, Equatable {
    case Shell(String)
    case None
    
    var isAutoFilled: Bool {
      self != .None
    }
  }
  
  func fullfills(query: String) -> Bool {
    if query.isOnlyWhitespaces() {
      return true
    } else {
      return title.lowercased().contains(query.lowercased()) || description.lowercased().contains(query.lowercased()) || code.lowercased().contains(query.lowercased())
    }
  }
}
