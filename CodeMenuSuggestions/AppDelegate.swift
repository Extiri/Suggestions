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
	
	func applicationDidFinishLaunching(_ aNotification: Notification) {
		print(SettingsManager.shared.settings.isAvailable)
		SettingsManager.shared.settings.isAvailable = true
		
		completionManager = CompletionManager.shared
		
		var isDebug = false
		
		#if DEBUG
		isDebug = true
		#endif
		
		if !UserDefaults.standard.bool(forKey: "NotFirst") || isDebug {
			let welcomeWindowController = NSStoryboard(name: "Main", bundle: nil)["Welcome"] as! NSWindowController
			
			welcomeWindowController.window?.standardWindowButton(.miniaturizeButton)?.isHidden = true
			welcomeWindowController.window?.standardWindowButton(.zoomButton)?.isHidden = true
			
			welcomeWindowController.window?.center()
			
			//elcomeWindowController.window?.makeKeyAndOrderFront(welcomeWindowController)
		
			UserDefaults.standard.setValue(true, forKey: "NotFirst")
		}
	}
	
	func applicationWillTerminate(_ aNotification: Notification) {
		
	}
}

extension NSStoryboard {
	subscript(_ identifier: String) -> Any {
		return instantiateController(withIdentifier: identifier)
	}
}
