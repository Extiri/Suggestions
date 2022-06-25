//
//  SuggestionsManager.swift
//  CodeMenu
//
//  Created by Wiktor Wójcik on 20/09/2021.
//

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
		
		init() {
			isAvailable = false
			disallowlist = []
			realmFilePath = ""
			refreshRate = 0.1
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
		
		url = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first!
		url.appendPathComponent("Containers/id.thedev.marcin.CodeMenu/Data/Library/")
		url.appendPathComponent("suggestions.cmsettings")
		
		load()
	}
}
