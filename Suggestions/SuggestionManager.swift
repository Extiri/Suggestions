import Foundation

class SuggestionsManager: NSObject {
  static var shared = SuggestionsManager()
  
  var searchHandler: (String) -> ([CompletionSuggestion]) = { query in
    SnippetsManager.shared.suggestions.filter { query == "" ? true : $0.fullfills(query: query) }
  }
  
  var suggestions = [CompletionSuggestion]()
  var query = ""
  var language = ""
  
  func load(forQuery query: String) {
    if query != self.query {
      self.query = query
      suggestions = searchHandler(query)
    }
  }
}

struct CompletionSuggestion {
  var title: String
  var description: String
  var code: String
  var language: String
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

extension String {
  func isOnly(_ character: Character) -> Bool {
    var result = true
    self.forEach { if $0 != character { result = false; return } }
    return result
  }
  
  func isOnlyWhitespaces() -> Bool {
    return isOnly(" ") || isEmpty
  }
}
