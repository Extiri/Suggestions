//
//  CompletionManager.swift
//  CMCompletionFeatureExperimental
//
//  Created by Wiktor Wójcik on 20/08/2021.
//

import Cocoa
import Accessibility
import Combine
import KeyboardShortcuts

extension KeyboardShortcuts.Name {
	static let selectUpwards = KeyboardShortcuts.Name("selectUpwards")
	static let selectDownwards = KeyboardShortcuts.Name("selectDownwards")
	static let useSuggestion = KeyboardShortcuts.Name("useSuggestion")
}

extension Array {
	subscript(safely index: Int) -> ArrayLiteralElement? {
		if index >= startIndex && index < endIndex { return self[index] } else { return nil }
	}
}

class DConsole {
	init(_ outputHandler: @escaping (String) -> ()) {
		self.outputHandler = outputHandler
	}
	
	var outputHandler: (String) -> ()
	
	func message(_ message: String) {
		outputHandler(message)
	}
	
	func success(_ message: String) {
		self.message("[SUCCESS] \(message)")
	}
	
	func warning(_ message: String) {
		self.message("[WARNING] \(message)")
	}
	
	func error(_ message: String) {
		self.message("[ERROR] \(message)")
	}
}

class SuggestionsTableViewDelegate: NSObject, NSTableViewDelegate {
	let suggestionsManager = SuggestionsManager.shared
	
	func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
		let text = NSTextField()
		text.stringValue = suggestionsManager.suggestions[row].title
		let cell = NSTableCellView()
		cell.addSubview(text)
		text.drawsBackground = false
		text.isBordered = false
		text.translatesAutoresizingMaskIntoConstraints = false
		cell.addConstraint(NSLayoutConstraint(item: text, attribute: .centerY, relatedBy: .equal, toItem: cell, attribute: .centerY, multiplier: 1, constant: 0))
		cell.addConstraint(NSLayoutConstraint(item: text, attribute: .left, relatedBy: .equal, toItem: cell, attribute: .left, multiplier: 1, constant: 13))
		cell.addConstraint(NSLayoutConstraint(item: text, attribute: .right, relatedBy: .equal, toItem: cell, attribute: .right, multiplier: 1, constant: -13))
		return cell
	}
	
	func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
		let rowView = NSTableRowView()
		rowView.isEmphasized = false
		return rowView
	}
}

class SuggestionsDataSource: NSObject, NSTableViewDataSource {
	let suggestionsManager = SuggestionsManager.shared
	
	func numberOfRows(in tableView: NSTableView) -> Int {
		suggestionsManager.suggestions.count
	}
}

class CompletionManager {
	static let shared = CompletionManager()
	
	var tableView: NSTableView = NSTableView()
	var scrollView: NSScrollView = NSScrollView()
	
	func reloadViews() {
		scrollView.removeFromSuperview()
		
		let dataSource = SuggestionsDataSource()
		let delegate = SuggestionsTableViewDelegate()
		
		scrollView = NSScrollView(frame: NSRect(x: 5, y: 5, width: 195, height: 495))
		
		tableView = NSTableView()
		
		tableView.bounds = scrollView.frame
		tableView.backgroundColor = .clear
		tableView.dataSource = dataSource
		tableView.delegate = delegate
		tableView.headerView = nil
		tableView.rowHeight = 20
		tableView.wantsLayer = true
		tableView.allowsMultipleSelection = false
		
		let column = NSTableColumn(identifier: .init("ColumnID"))
		column.minWidth = 200
		
		tableView.addTableColumn(column)
		
		scrollView.documentView = tableView
		scrollView.drawsBackground = false
		scrollView.backgroundColor = .clear
		scrollView.hasHorizontalScroller = false
		scrollView.hasVerticalScroller = true
		
		completionWindow.contentView?.addSubview(scrollView)
		
		tableView.selectRowIndexes([0], byExtendingSelection: false)
	}
	
	init() {
		SuggestionsManager.shared.searchHandler = { query in
			[CompletionSuggestion(title: "Test1", description: "This is Test1", code: "print(\"Test1\")", language: "swift"),
			CompletionSuggestion(title: "Test2", description: "This is Test2", code: "print(\"Test2\")", language: "javascript"),
			CompletionSuggestion(title: "Test3", description: "This is Test3", code: "print(\"Test3\")", language: "swift")].filter { $0.fullfills(query: query, language: "") }
		}
		
		codeInteraction = CodeInteraction()
		
		let backgroundVisualEffect = NSVisualEffectView(frame: NSRect(x: 0, y: 0, width: 200, height: 500))
		backgroundVisualEffect.blendingMode = .behindWindow
		backgroundVisualEffect.material = .sidebar
		backgroundVisualEffect.state = .active
		
		let view = NSView(frame: NSRect(x: 0, y: 0, width: 200, height: 500))
		view.wantsLayer = true
		view.layer?.cornerRadius = 10.0
		
		view.addSubview(backgroundVisualEffect)
		
		let viewController = NSViewController()
		viewController.view = view
		let window = NSWindow(contentRect: NSRect(x: (NSScreen.main?.frame.width ?? 0) - 250, y: 5, width: 200, height: 500), styleMask: [.fullSizeContentView, .titled], backing: .buffered, defer: true)
		window.contentViewController = viewController
		window.isOpaque = false
		window.titleVisibility = .hidden
		window.level = .floating
		window.titlebarAppearsTransparent = true
		window.standardWindowButton(.closeButton)?.isHidden = true
		window.standardWindowButton(.miniaturizeButton)?.isHidden = true
		window.standardWindowButton(.zoomButton)?.isHidden = true
		window.isMovableByWindowBackground = true
		window.isReleasedWhenClosed = false
		
		completionWindow = window
		
		reloadViews()
		
		KeyboardShortcuts.setShortcut(.init(.v, modifiers: .option), for: .useSuggestion)
		KeyboardShortcuts.onKeyDown(for: .useSuggestion) {
			if let selectedSuggestion = SuggestionsManager.shared.suggestions[safely: self.currentlySelectedSuggestion] {
				self.codeInteraction.useCode(selectedSuggestion.code)
			}
		}
		
		KeyboardShortcuts.setShortcut(.init(.leftBracket, modifiers: .option), for: .selectDownwards)
		KeyboardShortcuts.onKeyDown(for: .selectDownwards) {
			if self.currentlySelectedSuggestion == 0 {
				self.currentlySelectedSuggestion = self.countOfSuggestions
				self.tableView.selectRowIndexes([0], byExtendingSelection: false)
			} else {
				self.currentlySelectedSuggestion -= 1
				self.tableView.selectRowIndexes([self.currentlySelectedSuggestion], byExtendingSelection: false)
			}
		}
		
		KeyboardShortcuts.setShortcut(.init(.rightBracket, modifiers: .option), for: .selectUpwards)
		KeyboardShortcuts.onKeyDown(for: .selectUpwards) {
			if self.currentlySelectedSuggestion == self.countOfSuggestions {
				self.currentlySelectedSuggestion = 0
				self.tableView.selectRowIndexes([0], byExtendingSelection: false)
			} else {
				self.currentlySelectedSuggestion += 1
				self.tableView.selectRowIndexes([self.currentlySelectedSuggestion], byExtendingSelection: false)
			}
		}
		
		if !apiIsEnabled {
			accessibilityPrompt { status in
				if status {
					openAccessiblityPreferencesPane()
				}
			}
			
			if !apiIsEnabled {
				completionFeatureAvailable = false
				console.error("Accessibility API not enabled")
			} else {
				completionFeatureAvailable = true
				startSuggestion()
				console.success("Accessibility API enabled")
			}
		} else {
			completionFeatureAvailable = true
			startSuggestion()
			console.success("Accessibility API enabled")
		}
		
		openAccessiblityPreferencesPane()
	}
	
	var timer: Timer? = nil
	
	let codeInteraction: CodeInteraction
	
	var completionWindowIsVisible = false

	var query: String = ""
	
	var currentlySelectedSuggestion: Int = 0
	var countOfSuggestions: Int {
		get {
			return tableView.numberOfRows
		}
	}
	
	func startSuggestion() {
		self.console.message("Started suggestion")
		timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
			DispatchQueue.main.async {
				let codeInfo = CodeInfo()
				
				let state = self.codeInteraction.getCodeInfo(codeInfo)
				self.console.message("didSucced: \(state)")
				
				if state {
					if !self.completionWindowIsVisible {
						self.completionWindow.makeKeyAndOrderFront(self.completionWindow)
						self.completionWindowIsVisible = true
					}
					
					if self.query != codeInfo.query {
						self.query = codeInfo.query
						SuggestionsManager.shared.load(forQuery: codeInfo.query)
						self.reloadViews()
					}
				} else {
					if self.completionWindowIsVisible {
						self.completionWindow.close()
						self.completionWindowIsVisible = false
					}
				}
			}
		}
		
		timer?.fire()
	}
	
	func checkAvailability() {
		if !apiIsEnabled {
			accessibilityPrompt { status in
				if status {
					openAccessiblityPreferencesPane()
				}
			}
			
			if !apiIsEnabled {
				completionFeatureAvailable = false
				console.error("Accessibility API not enabled")
			} else {
				completionFeatureAvailable = true
				console.success("Accessibility API enabled")
			}
		}
	}
	
	var console: DConsole = DConsole { message in print(message) }
	
	var completionFeatureAvailable = false
	
	var accessibilityPrompt: ((Bool) -> ()) -> () = { handler in handler(true) }
	
	func openAccessiblityPreferencesPane() {
		NSWorkspace.shared.open(URL(fileURLWithPath: "/System/Library/PreferencePanes/x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility.prefPane"))
	}
	
	var completionWindow: NSWindow
	
	var apiIsEnabled: Bool {
		return AXIsProcessTrustedWithOptions([kAXTrustedCheckOptionPrompt.takeUnretainedValue() as NSString: true] as CFDictionary?)
	}
}

class SuggestionsManager: NSObject {
	static var shared = SuggestionsManager()
	
	var debugSuggestions = [CompletionSuggestion]()
	var searchHandler: (String) -> ([CompletionSuggestion]) = { _ in return [] }
	
	var suggestions = [CompletionSuggestion]()
	var query = ""
	var language = ""
	
	func load(forQuery query: String) {
		if query != self.query {
			self.query = query
			suggestions = searchHandler(query)
		}
	}
}

struct CompletionSuggestion {
	var title: String
	var description: String
	var code: String
	var language: String
	
	func fullfills(query: String, language: String) -> Bool {
		if language == "" && query == "" { return true } else { if language != "" { if query != "" { return (title.lowercased().contains(query.lowercased()) || description.lowercased().contains(query.lowercased()) || code.lowercased().contains(query.lowercased())) && self.language == language } else { return self.language == language } } else { if query != "" { return title.lowercased().contains(query.lowercased()) || description.lowercased().contains(query.lowercased()) || code.lowercased().contains(query.lowercased()) } else if query == "" { return true } else { return true } } }
	}
}
