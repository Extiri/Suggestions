//
//  Console.swift
//  Suggestions
//
//  Created by Wiktor Wójcik on 15/07/2023.
//

import Foundation

class DConsole {
  static let shared = DConsole { message in print(message) }
  
  init(_ outputHandler: @escaping (String) -> ()) {
    self.outputHandler = outputHandler
  }
  
  var outputHandler: (String) -> ()
  
  func message(_ message: String) {
    outputHandler(message)
  }
  
  func success(_ message: String) {
    self.message("[SUCCESS] \(message)")
  }
  
  func warning(_ message: String) {
    self.message("[WARNING] \(message)")
  }
  
  func error(_ message: String) {
    self.message("[ERROR] \(message)")
  }
}
