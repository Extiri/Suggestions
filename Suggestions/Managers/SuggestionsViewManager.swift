import Cocoa
import Accessibility
import Combine
import KeyboardShortcuts
import Highlightr

  /// Manager responsible for presenting the suggestion view and updating it.
class SuggestionsViewManager {
  static let shared = SuggestionsViewManager()
  
  var tableView: NSTableView = NSTableView()
  var scrollView: NSScrollView = NSScrollView()
  
  let detailsView: NSScrollView
  
  var placeholderSnippet: String? = nil
  var placeholderSnippetsPlaceholders: PlaceholdersDictionary? = nil
  var isFillingPlaceholders: Bool {
    placeholderSnippet != nil
  }
  
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
    
    if let suggestion = SuggestionsManager.shared.suggestions[safely: tableView.selectedRow], !isFillingPlaceholders {
      detailsText = ""

      if !suggestion.description.isEmpty {
        detailsText += suggestion.description
        
        detailsText += "\n\n\n"
      }
      
      let highlighter = Highlightr()!

      highlighter.setTheme(to: SettingsManager.shared.settings.highlightingTheme ?? (NSAppearance.current.name == .darkAqua ? "paraiso-dark" : "paraiso-light"))
      
      if highlighter.supportedLanguages().contains(suggestion.language) {
        textView.textStorage!.append(highlighter.highlight(suggestion.code, as: suggestion.language) ?? NSAttributedString(string: ""))
      } else {
        textView.textStorage!.append(highlighter.highlight(suggestion.code) ?? NSAttributedString(string: ""))
      }
      
    } else if isFillingPlaceholders {
      detailsText = "Enter values in between #\" and \"# in proper places next to placeholder names and then press ⌥ (Option) + v again. To cancel, delete all placeholders after §§ signs.\n\n"
      
      let highlighter = Highlightr()!
      
      highlighter.setTheme(to: SettingsManager.shared.settings.highlightingTheme ?? (NSAppearance.current.name == .darkAqua ? "paraiso-dark" : "paraiso-light"))
      
      detailsText += "\n"
      
      textView.textStorage!.append(highlighter.highlight(placeholderSnippet!) ?? NSAttributedString(string: ""))
    } else {
      detailsText = "There are no snippets matching this query."
    }
  }
  
  func createList() {
    scrollView = NSScrollView(frame: NSRect(x: 0, y: 0, width: 251, height: 220))
    
    tableView = NSTableView()
    tableView.bounds = scrollView.frame
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
    scrollView.hasHorizontalScroller = false
    scrollView.hasVerticalScroller = true
    
    updateDetails()
    
    completionWindow.contentView?.addSubview(scrollView)
    
    SuggestionsManager.shared.load(forQuery: "")
    
    reloadList()
  }
  
  func reloadList() {
    tableView.reloadData()
    
    tableView.selectRowIndexes([0], byExtendingSelection: false)
    tableView.scrollRowToVisible(0)
    
    updateDetails()
  }
  
  init() {
    codeInteraction = CodeInteraction()
    
    detailsView = NSTextView.scrollableTextView()
    detailsView.frame = NSRect(x: 263, y: 5, width: 240, height: 198)
    detailsView.drawsBackground = false

    (detailsView.documentView as! NSTextView).string = "This snippet is a example."
    (detailsView.documentView as! NSTextView).drawsBackground = false
    
    let lineView = NSBox(frame: NSRect(x: 250, y: -5, width: 10, height: 250))
    lineView.fillColor = .textColor
    
    let view = NSView(frame: NSRect(x: 0, y: 0, width: 500, height: 200))
    
    view.wantsLayer = true
    view.layer?.cornerRadius = 10.0
    
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
      if self.isFillingPlaceholders {
        let code = PlaceholdersManager.parseAndSetPlaceholders(query: self.query, code: self.placeholderSnippet!, placeholders: self.placeholderSnippetsPlaceholders!)
        self.codeInteraction.useCode(code, isAbbreviation: false)
        self.placeholderSnippet = nil
        self.placeholderSnippetsPlaceholders = nil
      } else {
        if let selectedSuggestion = SuggestionsManager.shared.suggestions[safely: self.currentlySelectedSuggestion] {
          if PlaceholdersManager.hasPlaceholdersToFill(placeholders: selectedSuggestion.placeholders) {
            self.placeholderSnippet = selectedSuggestion.code
            self.placeholderSnippetsPlaceholders = selectedSuggestion.placeholders
            self.codeInteraction.useCode("§§" + PlaceholdersManager.createPlaceholdersQuery(code: selectedSuggestion.code, placeholders: selectedSuggestion.placeholders), isAbbreviation: false)
          } else {
            self.codeInteraction.useCode(PlaceholdersManager.setPlaceholders(code: selectedSuggestion.code, values: [:]), isAbbreviation: false)
          }
        }
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
    
    if checkAvailability() {
      startSuggestion()
    }
  }
  
  var timer: Timer? = nil
  
  let codeInteraction: CodeInteraction
  
  var completionWindowIsVisible = false
  
  var query = ""
  
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
    self.console.message("Started suggestions")
    
    // Replace timer with something more efficient, if possible.
    timer = Timer.scheduledTimer(withTimeInterval: SettingsManager.shared.settings.refreshRate / 10, repeats: true) { _ in
      DispatchQueue.main.async {
        let codeInfo = CodeInfo()
        let state = self.codeInteraction.getCodeInfo(codeInfo)

        if codeInfo.isAbbreviation {
          // Is an abbreviation
          self.query = codeInfo.query
          self.completionWindowIsVisible = false
          self.completionWindow.close()
          if let snippet = CodeMenuProvider.shared.abbreviationsDictionary[self.query] {
            if PlaceholdersManager.hasPlaceholdersToFill(placeholders: snippet.placeholders) {
              if let code = PlaceholdersManager.askForPlaceholderSetting(title: snippet.title, code: snippet.code, placeholdersToFill: snippet.placeholders) {
                self.codeInteraction.useCode(code, isAbbreviation: true)
              } else {
                self.codeInteraction.useCode(PlaceholdersManager.setPlaceholders(code: snippet.code), isAbbreviation: true)
              }
              return
            }
            
            self.codeInteraction.useCode(PlaceholdersManager.setPlaceholders(code: snippet.code), isAbbreviation: true)
            return
          }
        }
        
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
            if codeInfo.query == "" {
              self.placeholderSnippet = nil
            }
            
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
  
  func checkAvailability() -> Bool {
    if !apiIsEnabled {
      showAlert(message: "Accessibility permission not enabled.", informative: "Suggestions requires Accessibility permission to access text in other apps. Go to Settings > Privacy and Security > Accessibility and click the toggle next to Suggestions. Then run Suggestions again.", buttons: ["Quit Suggestions", "Open settings and quit Suggestions"]) { button in
        if button == .alertSecondButtonReturn {
          self.openAccessiblityPreferencesPane()
          exit(0)
        } else if button == .alertFirstButtonReturn {
          exit(0)
        }
      }
      
      completionFeatureAvailable = false
      console.error("Accessibility API not enabled")
      
      
      return false
    } else {
      completionFeatureAvailable = true
      console.success("Accessibility API enabled")
      
      return true
    }
  }
  
  var console = DConsole.shared
  
  var completionFeatureAvailable = false
  
  func openAccessiblityPreferencesPane() {
    NSWorkspace.shared.open(URL(fileURLWithPath: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility.prefPane"))
  }
  
  var completionWindow: NSWindow
  
  var apiIsEnabled: Bool {
    return AXIsProcessTrustedWithOptions([kAXTrustedCheckOptionPrompt.takeUnretainedValue() as NSString: true] as CFDictionary?)
  }
}
