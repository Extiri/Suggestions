//
//  SnippetsManager.swift
//  CodeMenuSuggestions
//
//  Created by Wiktor Wójcik on 26/08/2021.
//

import Cocoa

class SnippetsManager {
	static var shared = SnippetsManager()
	var suggestions = [CompletionSuggestion]()
	
	var url: URL {
		FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first!.appendingPathComponent("Containers/id.thedev.wiktor.CodeMenu/Data/Documents/snippets.cmsnippets")
	}
	
	func parseObject(_ cardObject: CardObject) -> [CompletionSuggestion] {
		cardObject.snippets.map { CompletionSuggestion(title: $0.title, description: $0.desc, code: $0.code, language: $0.lang) }
	}
	
	init() {
		if let data = FileManager.default.contents(atPath: url.path) {
			do {
				let objects = try JSONDecoder().decode([CardObject].self, from: data)
				for object in objects {
					suggestions.append(contentsOf: parseObject(object))
				}
			} catch {
				print(error.localizedDescription)
			}
		} else {
			if !FileManager.default.fileExists(atPath: url.path) {
				let alert = NSAlert()
				alert.messageText = "CodeMenu Suggestions requires that CodeMenu is installed on this macOS."
				alert.addButton(withTitle: "Quit app")
				alert.addButton(withTitle: "Learn more")
				let response = alert.runModal()
				if response == .alertSecondButtonReturn {
					NSWorkspace.shared.open(URL(string: "https://codemenu.herokuapp.com/")!)
				} else {
					exit(1)
				}
			}
		}
	}
}
