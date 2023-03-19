import Cocoa
import RealmSwift

extension UserDefaults {
  static var codeMenuGroup: UserDefaults {
    UserDefaults(suiteName: "group.DNFYV2TZ3T.id.extiri.CodeMenu")!
  }
}

class SnippetsManager {
  static var shared = SnippetsManager()
  var realm: Realm!
  
  var didShowErrorMessage = false
  
  var lastCacheId = ""
  var suggestionsCache = [CompletionSuggestion]()
  var abbreviationsDictionary: [String: CompletionSuggestion] {
    suggestions.reduce([String: CompletionSuggestion]()) { result, element in
      var result = result
      
      if !element.abbreviation.isEmpty {
        result[element.abbreviation] = element
      }
      
      return result
    }
  }
  
  var suggestions: [CompletionSuggestion] {
    do {
      guard lastCacheId != UserDefaults.codeMenuGroup.string(forKey: "snippetsId") ?? "" else { return suggestionsCache }
      lastCacheId = UserDefaults.codeMenuGroup.string(forKey: "snippetsId") ?? ""
      
      guard let data = UserDefaults.codeMenuGroup.data(forKey: "snippets") else { return [] }
      
      let snippets = try JSONDecoder().decode([SCSnippet].self, from: data)
      suggestionsCache = snippets.map { parseObject($0) }
      return suggestionsCache
    } catch {
      if !didShowErrorMessage {
        showAlert(message: "Invalid snippets format", informative: "Most likely version of CodeMenu which you are using isn't supported or it isn't installed.")
        didShowErrorMessage = true
      }
      
      return []
    }
  }
  
  func parseObject(_ snippet: SCSnippet) -> CompletionSuggestion {
        CompletionSuggestion(title: snippet.title, description: snippet.desc, code: snippet.code, language: snippet.lang, abbreviation: snippet.abbreviation, placeholders: snippet.placeholders)
  }
  
  struct SCSnippet: Codable {
    var id: Int
    var title: String
    var abbreviation: String
    var code: String
    var desc: String
    var lang: String
    var placeholders: [String: CompletionSuggestion.PlaceholderAction]
  }

  
  init() {
    
  }
}
