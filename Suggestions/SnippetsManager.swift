import Cocoa
import RealmSwift

class SnippetsManager {
  static var shared = SnippetsManager()
  var realm: Realm!
  var suggestions = [CompletionSuggestion]()
  var token: NotificationToken!
  
  func parseObject(_ snippet: Snippet) -> CompletionSuggestion {
    CompletionSuggestion(title: snippet.title, description: snippet.desc, code: snippet.code, language: snippet.lang)
  }
  
  init() {
    Realm.Configuration.defaultConfiguration.schemaVersion = 5
    Realm.Configuration.defaultConfiguration.readOnly = true
    
    do {
      realm = try Realm(fileURL: URL(fileURLWithPath: SettingsManager.shared.settings.realmFilePath))
      suggestions = Array(realm.objects(Snippets.self).first!.snippets).map { parseObject($0) }

    } catch {
      print("\(error)")
      
      let alert = NSAlert()
      
      alert.messageText = "Failed to start."
      alert.informativeText = "Probably you haven't installed CodeMenu, which is required, or CodeMenu Suggestions is out of date."
      
      alert.runModal()
      
      exit(1)
    }
  }
}
