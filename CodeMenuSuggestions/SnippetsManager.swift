//
//  SnippetsManager.swift
//  CodeMenuSuggestions
//
//  Created by Wiktor Wójcik on 26/08/2021.
//

import Cocoa
import RealmSwift

class SnippetsManager {
	static var shared = SnippetsManager()
	var suggestions = [CompletionSuggestion]()
	
	func parseObject(_ snippet: Snippet) -> CompletionSuggestion {
		CompletionSuggestion(title: snippet.title, description: snippet.desc, code: snippet.code, language: snippet.lang)
	}
	
	init() {
		Realm.Configuration.defaultConfiguration.schemaVersion = 4
		
		do {
			let realm = try Realm(fileURL: URL(fileURLWithPath: SettingsManager.shared.settings.realmFilePath))
			
			suggestions = Array(realm.objects(SnippetsList.self).first!.snippets).map { parseObject($0) }
		} catch {
			NSLog("\(error)")
			
			let alert = NSAlert()
			
			alert.messageText = "Failed to start."
			alert.informativeText = "Probably you haven't installed CodeMenu which is required."
			
			alert.runModal()
		}
	}
}
