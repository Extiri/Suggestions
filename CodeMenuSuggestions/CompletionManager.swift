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
import Highlightr

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

extension String {
	func truncate(longerThan max: Int) -> String {
		if self.count > max {
			let beforeMax = self.prefix(max - 3)
			return beforeMax + "..."
		} else {
			return self
		}
	}
}

class DConsole {
	static let shared = DConsole { message in print(message) }
	
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
}

class SuggestionsDataSource: NSObject, NSTableViewDataSource {
	let suggestionsManager = SuggestionsManager.shared
	
	func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
		return suggestionsManager.suggestions[row].title + "\n\n" + suggestionsManager.suggestions[row].description.truncate(longerThan: 90)
	}
	
	func numberOfRows(in tableView: NSTableView) -> Int {
		return suggestionsManager.suggestions.count
	}
}

class CompletionManager {
	static let shared = CompletionManager()
	
	var tableView: NSTableView = NSTableView()
	var scrollView: NSScrollView = NSScrollView()
	
	let detailsView: NSScrollView
	
	var detailsText: String {
		get {
			return (detailsView.documentView as! NSTextView).string
		}
		
		set {
			(detailsView.documentView as! NSTextView).string = newValue
		}
	}
	
	let dataSource = SuggestionsDataSource()
	let delegate = SuggestionsTableViewDelegate()

	func updateDetails() {
		let textView = detailsView.documentView as! NSTextView
		
		if let suggestion = SuggestionsManager.shared.suggestions[safely: tableView.selectedRow] {
			detailsText = ""
			
			detailsText += suggestion.description
			
			detailsText += "\n\n"
			
			let highlighter = Highlightr()!
			
			if NSAppearance.current.name == .darkAqua {
				highlighter.setTheme(to: "paraiso-dark")
			} else {
				highlighter.setTheme(to: "paraiso-light")
			}
			
			detailsText += "\n"
			
			textView.textStorage!.append(highlighter.highlight(suggestion.code) ?? NSAttributedString(string: ""))
		} else {
			detailsText = "Start typing so suggestions will appear."
		}
	}
	
	func createList() {
		scrollView = NSScrollView(frame: NSRect(x: 5, y: 5, width: 245, height: 210))
		
		tableView = NSTableView()
		
		tableView.bounds = scrollView.frame
		tableView.backgroundColor = .clear
		tableView.dataSource = dataSource
		tableView.delegate = delegate
		tableView.headerView = nil
		tableView.rowHeight = 50
		tableView.wantsLayer = true
		tableView.intercellSpacing = NSSize(width: 0, height: 10)
		tableView.gridStyleMask = .solidHorizontalGridLineMask
		tableView.allowsMultipleSelection = false
		
		let column = NSTableColumn(identifier: .init("ColumnID"))
		column.minWidth = 200
		
		tableView.addTableColumn(column)
		
		scrollView.documentView = tableView
		scrollView.drawsBackground = false
		scrollView.backgroundColor = .clear
		scrollView.hasHorizontalScroller = false
		scrollView.hasVerticalScroller = true
		
		updateDetails()
		
		completionWindow.contentView?.addSubview(scrollView)
	}
	
	func reloadList() {
		tableView.reloadData()
		
		tableView.selectRowIndexes([0], byExtendingSelection: false)
		tableView.scrollRowToVisible(0)
		
		updateDetails()
	}
	
	init() {
		#if DEBUG
		SuggestionsManager.shared.searchHandler = { query in
			var result = [CompletionSuggestion]()
			[CompletionSuggestion(title: "Test1", description: "This is Test1", code: "print(\"Test1\")", language: "swift"),
			 CompletionSuggestion(title: "Test2", description: "This is Test2", code: "console.log(\"Test2\")", language: "javascript"),
			 CompletionSuggestion(title: "Test3", description: "This is Test3", code: "NSLog(\"Test3\")", language: "swift")].forEach { if $0.fullfills(query: query) { result.append($0)} }
			
			return result
		}
		
		#else
		SuggestionsManager.shared.searchHandler = { query in
			SnippetsManager.shared.suggestions.filter { $0.fullfills(query: query) }
		}
		#endif
		
		codeInteraction = CodeInteraction()
		
		detailsView = NSTextView.scrollableTextView()
		detailsView.frame = NSRect(x: 263, y: 5, width: 245, height: 198)
		detailsView.drawsBackground = false
		
		(detailsView.documentView as! NSTextView).string = "This snippet is a example."
		(detailsView.documentView as! NSTextView).drawsBackground = false
		
		let backgroundVisualEffect = NSVisualEffectView(frame: NSRect(x: 0, y: 0, width: 500, height: 200))
		backgroundVisualEffect.blendingMode = .behindWindow
		backgroundVisualEffect.material = .sidebar
		backgroundVisualEffect.state = .active
		
		let lineView = NSBox(frame: NSRect(x: 250, y: -5, width: 10, height: 250))
		lineView.fillColor = .textColor
		
		let view = NSView(frame: NSRect(x: 0, y: 0, width: 500, height: 200))
		
		view.wantsLayer = true
		view.layer?.cornerRadius = 10.0
		
		view.addSubview(backgroundVisualEffect)
		view.addSubview(lineView)
		view.addSubview(detailsView)
		
		let viewController = NSViewController()
		
		viewController.view = view
		
		let window = NSWindow(contentRect: NSRect(x: (NSScreen.main?.frame.width ?? 0) - 550, y: 5, width: 500, height: 200), styleMask: [.fullSizeContentView, .titled], backing: .buffered, defer: true)
		window.center()
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
		
		createList()
		
		KeyboardShortcuts.setShortcut(.init(.v, modifiers: .option), for: .useSuggestion)
		KeyboardShortcuts.onKeyDown(for: .useSuggestion) {
			if let selectedSuggestion = SuggestionsManager.shared.suggestions[safely: self.currentlySelectedSuggestion] {
				#warning("__IMPORTANT__: Make code go back to the previous frame (based on CodeInfo.frame)")
				self.codeInteraction.useCode(selectedSuggestion.code, withFrame: NSRect(x: 0, y: 0, width: 0, height: 0))
			}
		}
		
		KeyboardShortcuts.setShortcut(.init(.leftBracket, modifiers: .option), for: .selectUpwards)
		KeyboardShortcuts.onKeyDown(for: .selectUpwards) {
			if self.currentlySelectedSuggestion == 0 {
				self.currentlySelectedSuggestion = self.countOfSuggestions
				self.tableView.selectRowIndexes([self.currentlySelectedSuggestion], byExtendingSelection: false)
			} else {
				self.currentlySelectedSuggestion -= 1
				self.tableView.selectRowIndexes([self.currentlySelectedSuggestion], byExtendingSelection: false)
			}
		}
		
		KeyboardShortcuts.setShortcut(.init(.rightBracket, modifiers: .option), for: .selectDownwards)
		KeyboardShortcuts.onKeyDown(for: .selectDownwards) {
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
	
	var currentlySelectedSuggestion: Int {
		get {
			return tableView.selectedRow
		}
		
		set {
			tableView.selectRowIndexes([newValue], byExtendingSelection: false)
			tableView.scrollRowToVisible(newValue)
			
			updateDetails()
		}
	}
	
	var countOfSuggestions: Int {
		get {
			return tableView.numberOfRows
		}
	}
	
	func startSuggestion() {
		self.console.message("Started suggestion")
		timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
			DispatchQueue.main.async {
				let codeInfo = CodeInfo()
				let state = self.codeInteraction.getCodeInfo(codeInfo)
				
				if state {
					if !self.completionWindowIsVisible {
						self.completionWindow.makeKeyAndOrderFront(self.completionWindow)
						self.completionWindowIsVisible = true
					}
					
					var newOrigin = codeInfo.frame.origin
					
					newOrigin.y = NSScreen.main!.frame.height - newOrigin.y
					
					let newFrame = NSRect(x: newOrigin.x, y: newOrigin.y - 220, width: 500, height: 200)
					
					self.completionWindow.setFrame(newFrame, display: true, animate: true)
					
					if self.query != codeInfo.query {
						self.query = codeInfo.query
						SuggestionsManager.shared.load(forQuery: codeInfo.query)
						self.reloadList()
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
	
	var console: DConsole = DConsole.shared
	
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
	
	func fullfills(query: String) -> Bool {
		if query.isOnlyWhitespaces() {
			return true
		} else {
			return title.lowercased().contains(query.lowercased()) || description.lowercased().contains(query.lowercased()) || code.lowercased().contains(query.lowercased())
		}
	}
}

extension String {
	func isOnly(_ character: Character) -> Bool {
		var result = true
		self.forEach { if $0 != character { result = false; return } }
		return result
	}
	
	func isOnlyWhitespaces() -> Bool {
		return isOnly(" ") || isEmpty
	}
}
