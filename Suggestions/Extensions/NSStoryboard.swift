//
//  NSStoryboard.swift
//  Suggestions
//
//  Created by Wiktor Wójcik on 15/07/2023.
//

import Cocoa

extension NSStoryboard {
  subscript(_ identifier: String) -> Any {
    return instantiateController(withIdentifier: identifier)
  }
}


