import Foundation

class Debug {
  static func log(_ error: Error) {
    NSLog(error.localizedDescription)
  }
  
  static func log(_ message: String) {
    NSLog(message)
  }
  
  static func log<T: CustomStringConvertible>(_ object: T) {
    NSLog(object.description)
  }
}

@objc
class Settings: NSObject {
  @objc
  static func isAllowed(_ name: String) -> Bool {
    return !SettingsManager.shared.settings.disallowlist.contains(name)
  }
}

class SettingsManager {
  static var shared = SettingsManager()
  
  struct Settings: Codable, CustomStringConvertible {
    var description: String {
      get {
        var properties: [String] = []
        
        let mirror = Mirror(reflecting: self)
        
        for (key, value) in mirror.children {
          if key != "description" {
            if let key = key {
              properties.append("\(key): \(value)")
            }
          }
        }
        
        return properties.joined(separator: "; ")
      }
    }
    
    var isAvailable: Bool
    var realmFilePath: String
    var disallowlist: [String]
    var refreshRate: Double
    var highlightingTheme: String?
    
    init() {
      isAvailable = false
      disallowlist = []
      realmFilePath = ""
      refreshRate = 0.1
      highlightingTheme = nil
    }
  }
  
  private var url: URL
  
  private var settingsCache: Settings
  
  var settings: Settings {
    get {
      load()
      return settingsCache
    }
    
    set {
      settingsCache = newValue
      save()
    }
  }
  
  func URL() -> URL {
    return url
  }
  
  private var data: Data = Data()
  
  func save() {
    Debug.log("Suggestions setttings URL: \(url)")
    
    do {
      let data = try JSONEncoder().encode(settingsCache)
      try data.write(to: url)
    } catch {
      Debug.log(error)
    }
  }
  
  private func load() {
    let newData = FileManager.default.contents(atPath: url.path) ?? Data()
    if newData == data {
      return
    }
    
    do {
      data = newData
      settingsCache = try JSONDecoder().decode(Settings.self, from: data)
      print(settingsCache.realmFilePath)
    } catch {
      settingsCache = Settings()
      Debug.log(error)
    }
  }
  
  init() {
    settingsCache = Settings()
    url = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
    url.appendPathComponent("suggestions.json")
    
    if UserDefaults.standard.integer(forKey: "previouslyRunBuild") < 2 {
      UserDefaults.standard.setValue(Int(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "0")!, forKey: "previouslyRunBuild")
      
      var oldUrl = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first!
      oldUrl.appendPathComponent("Containers/id.thedev.marcin.CodeMenu/Data/Library/")
      oldUrl.appendPathComponent("suggestions.cmsettings")
      
      do {
        try FileManager.default.copyItem(at: oldUrl, to: url)
      } catch {
        showAlert(message: "Failed to migrate old settings.", informative: error.localizedDescription)
      }
    }
    
    load()
  }
}
