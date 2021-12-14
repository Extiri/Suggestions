//
//  AppDelegate.swift
//  CMCompletionFeatureExperimental
//
//  Created by Wiktor Wójcik on 20/08/2021.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {
	var completionManager: CompletionManager? = nil
	var statusItem: NSStatusItem?
	
	@IBOutlet weak var menu: NSMenu!
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
		statusItem!.button!.title = "Suggestions"
		
		statusItem?.menu = menu
	}
	
	func applicationDidFinishLaunching(_ aNotification: Notification) {
		SettingsManager.shared.settings.isAvailable = true
		
		completionManager = CompletionManager.shared
	}
	
	@IBAction func quit(_ sender: NSMenuItem) {
		NSApp.terminate(nil)
	}
}

extension NSStoryboard {
	subscript(_ identifier: String) -> Any {
		return instantiateController(withIdentifier: identifier)
	}
}
