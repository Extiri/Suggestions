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
    let suggestion = suggestionsManager.suggestions[row]

    let truncatedDescription = suggestion.description.truncate(longerThan: 90)
    
    let attributedString = NSMutableAttributedString(string: suggestion.title + "\n" + truncatedDescription)
    
    let titleRange = NSRange(location: 0, length: suggestion.title.count)
    let boldFont = NSFont.boldSystemFont(ofSize: NSFont.systemFontSize)
    attributedString.addAttribute(.font, value: boldFont, range: titleRange)
    
    let descriptionRange = NSRange(location: suggestion.title.count, length: truncatedDescription.count + 1)
    let grayColor = NSColor.gray
    attributedString.addAttribute(.foregroundColor, value: grayColor, range: descriptionRange)
    
    return attributedString
  }
  
  func numberOfRows(in tableView: NSTableView) -> Int {
    return suggestionsManager.suggestions.count
  }
}
