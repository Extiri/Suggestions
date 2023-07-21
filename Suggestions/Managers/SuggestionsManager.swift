import Foundation

/// This manager is responsible for storing suggestions for current query.
class SuggestionsManager: NSObject {
  static var shared = SuggestionsManager()
  
  var searchHandler: (String) -> ([Suggestion]) = { query in
    CodeMenuProvider.shared.suggestions.filter { query == "" ? true : $0.fullfills(query: query) }
  }
  
  var suggestions = [Suggestion]()
  var query = ""
  var language = ""
  
  func load(forQuery query: String) {
    if query != self.query {
      self.query = query
      suggestions = searchHandler(query)
    }
  }
}
