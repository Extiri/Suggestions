//
//  SuggestionsTableViewDelegate.swift
//  Suggestions
//
//  Created by Wiktor Wójcik on 15/07/2023.
//

import Cocoa

class SuggestionsTableViewDelegate: NSObject, NSTableViewDelegate {
  let suggestionsManager = SuggestionsManager.shared
}

class SuggestionsDataSource: NSObject, NSTableViewDataSource {
  let suggestionsManager = SuggestionsManager.shared
  
  func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
    return suggestionsManager.suggestions[row].title + "\n\n" + suggestionsManager.suggestions[row].description.truncate(longerThan: 90)
  }
  
  func numberOfRows(in tableView: NSTableView) -> Int {
    return suggestionsManager.suggestions.count
  }
}
