import Cocoa
import Defaults

/// This manager is responsible for getting snippets from CodeMenu.
class CodeMenuProvider {
  static var shared = CodeMenuProvider()
  
  private var didShowErrorMessage = false
  
  var lastCacheDate: Date = Date.init(timeIntervalSince1970: 0)
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
  
  var port: Int {
    Defaults[.codeMenuProviderPort]
  }
  
  var key: String? {
    Defaults[.codeMenuProviderKey] != "" ? Defaults[.codeMenuProviderKey] : nil
  }
  
  var isDownloading = false
  
  var suggestions: [Suggestion] {
    do {
      if -1 * lastCacheDate.timeIntervalSinceNow > 60 && !isDownloading {
        isDownloading = true
        let url = URL(string: "http://localhost:\(port)/v1/snippets" + (key != nil ? "?key=\(key!)" : ""))!
        let urlRequest = URLRequest(url: url)
        let task = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
          self.isDownloading = false
          self.lastCacheDate = NSDate.now
          
          if let error {
            print(error.localizedDescription)
            if !self.didShowErrorMessage {
              showAlert(message: "Failed to retrieve snippets", informative: "Failed to retrieve snippets from CodeMenu. Server might be disabled or the key might be wrong.")
            }
            self.didShowErrorMessage = true
            return
          }
          
          guard let data = data else { if !self.didShowErrorMessage { showAlert(message: "Failed to retrieve snippets", informative: "No data returned by CodeMenu.") }; return }

          if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
             if !self.didShowErrorMessage {
               showAlert(message: "Failed to retrieve snippets", informative: "Server returned status code \(httpResponse.statusCode). Check your key and port.")
             }
             self.didShowErrorMessage = true
             return
          }

          do {
            let snippets = try JSONDecoder().decode([SCSnippet].self, from: data)
            self.suggestionsCache = snippets.map { self.parseObject($0) }
            self.didShowErrorMessage = false
          } catch {
            print(error.localizedDescription)
            if !self.didShowErrorMessage {
              showAlert(message: "Failed to retrieve snippets", informative: "Most likely version of CodeMenu which you are using isn't supported or it isn't installed or the port is wrong.")
            }
            self.didShowErrorMessage = true
          }
          
          self.lastCacheDate = NSDate.now
        }
        
        task.resume()
      }
      
      return suggestionsCache
    }
  }
  
  func parseObject(_ snippet: SCSnippet) -> Suggestion {
        Suggestion(title: snippet.title, description: snippet.description, code: snippet.code, language: snippet.language, abbreviation: snippet.abbreviation, placeholders: snippet.placeholders)
  }
  
  struct SCSnippet: Codable {
    var id: String
    var title: String
    var abbreviation: String
    var code: String
    var description: String
    var language: String
    var placeholders: [String: Suggestion.PlaceholderAction]
  }
}
