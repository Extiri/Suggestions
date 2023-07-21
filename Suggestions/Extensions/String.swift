//
//  String.swift
//  Suggestions
//
//  Created by Wiktor Wójcik on 15/07/2023.
//

import Foundation

extension String {
  func truncate(longerThan max: Int) -> String {
    if self.count > max {
      let beforeMax = self.prefix(max - 3)
      return beforeMax + "..."
    } else {
      return self
    }
  }
  
  func isOnly(_ character: Character) -> Bool {
    var result = true
    self.forEach { if $0 != character { result = false; return } }
    return result
  }
  
  func isOnlyWhitespaces() -> Bool {
    return isOnly(" ") || isEmpty
  }
}
