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
		completionManager = CompletionManager.shared
	}

	func applicationWillTerminate(_ aNotification: Notification) {
		
	}
}
