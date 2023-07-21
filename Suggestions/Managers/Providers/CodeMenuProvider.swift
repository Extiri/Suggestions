import Cocoa
import RealmSwift

extension UserDefaults {
  static var codeMenuGroup: UserDefaults {
    UserDefaults(suiteName: "group.DNFYV2TZ3T.id.extiri.CodeMenu")!
  }
}

/// This manager is responsible for getting snippets from CodeMenu.
class CodeMenuProvider {
  static var shared = CodeMenuProvider()
  var realm: Realm!
  
  private var didShowErrorMessage = false
  
  var lastCacheId = ""
  var suggestionsCache = [Suggestion]()
  var abbreviationsDictionary: [String: Suggestion] {
    suggestions.reduce([String: Suggestion]()) { result, element in
      var result = result
      
      if !element.abbreviation.isEmpty {
        result[element.abbreviation] = element
      }
      
      return result
    }
  }
  
  var suggestions: [Suggestion] {
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
  
  func parseObject(_ snippet: SCSnippet) -> Suggestion {
        Suggestion(title: snippet.title, description: snippet.desc, code: snippet.code, language: snippet.lang, abbreviation: snippet.abbreviation, placeholders: snippet.placeholders)
  }
  
  struct SCSnippet: Codable {
    var id: Int
    var title: String
    var abbreviation: String
    var code: String
    var desc: String
    var lang: String
    var placeholders: [String: Suggestion.PlaceholderAction]
  }
}
