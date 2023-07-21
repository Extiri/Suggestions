//
//  Array.swift
//  Suggestions
//
//  Created by Wiktor Wójcik on 15/07/2023.
//

import Foundation

extension Array {
  subscript(safely index: Int) -> ArrayLiteralElement? {
    if index >= startIndex && index < endIndex { return self[index] } else { return nil }
  }
}
