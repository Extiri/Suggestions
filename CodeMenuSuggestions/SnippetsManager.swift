//
//  SnippetsManager.swift
//  CodeMenuSuggestions
//
//  Created by Wiktor Wójcik on 26/08/2021.
//

import Cocoa
import RealmSwift

// This will be replaced with a XPC call.
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
		
		do {
			realm = try Realm(fileURL: URL(fileURLWithPath: SettingsManager.shared.settings.realmFilePath))
			suggestions = Array(realm.objects(Snippets.self).first!.snippets).map { parseObject($0) }
			
			token = realm.observe { notification, realm in
				self.suggestions = Array(realm.objects(Snippets.self).first!.snippets).map { self.parseObject($0) }
			}
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
