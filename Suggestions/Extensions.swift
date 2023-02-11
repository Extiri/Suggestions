//
//  Extensions.swift
//  Suggestions
//
//  Created by Wiktor Wójcik on 11/02/2023.
//

import Foundation

extension String {
  func fullfills(regexPattern: String) throws -> Bool {
    let regex = try NSRegularExpression(pattern: regexPattern)
    let numberOfMatches = regex.numberOfMatches(in: self, range: NSRange(self.startIndex..., in: self))
    return numberOfMatches != 0
  }

  func groups(for regexPattern: String) throws -> [[String]] {
    let regex = try NSRegularExpression(pattern: regexPattern)
    let matches = regex.matches(in: self, range: NSRange(self.startIndex..., in: self))

    return matches.map { match in
      return (0..<match.numberOfRanges).map {
        let rangeBounds = match.range(at: $0)
        guard let range = Range(rangeBounds, in: self) else {
          return ""
        }
        return String(self[range])
      }
    }
  }
}

extension Date {
  //https://nsdateformatter.com/
  func formatted(using format: String) -> String {
    let formatter = DateFormatter()
    
    formatter.locale = .current
    formatter.dateFormat = format
    
    return formatter.string(from: self)
  }
  
  func localizedFormatted(using format: String) -> String {
    let formatter = DateFormatter()
    
    formatter.locale = .current
    formatter.setLocalizedDateFormatFromTemplate(format)
    
    return formatter.string(from: self)
  }
}
