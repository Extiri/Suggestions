//
//  Array.swift
//  Suggestions
//
//  Created by Wiktor Wójcik on 15/07/2023.
//

import Foundation

extension Array {
  subscript(safely index: Int) -> Element? {
    if index < self.endIndex && index >= 0  {
      return self[index]
    } else {
      return nil
    }
  }
}
