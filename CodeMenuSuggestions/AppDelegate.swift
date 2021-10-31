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
		SettingsManager.shared.settings.isAvailable = true
		
		completionManager = CompletionManager.shared
	}
	
	func applicationWillTerminate(_ aNotification: Notification) {
		
	}
}

extension NSStoryboard {
	subscript(_ identifier: String) -> Any {
		return instantiateController(withIdentifier: identifier)
	}
}
