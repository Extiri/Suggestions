//
//  ShowAlertFunction.swift
//  Suggestions
//
//  Created by Wiktor Wójcik on 15/07/2023.
//

import Cocoa

func showAlert(message: String, informative: String, buttons: [String] = [], showDontRepeat: Bool = false, completionHandler: @escaping (NSApplication.ModalResponse) -> () = { _ in }) {
  DispatchQueue.main.async {
    let alert = NSAlert()
    
    alert.messageText = message
    alert.informativeText = informative
    
    buttons.forEach { alert.addButton(withTitle: $0) }
    alert.buttons.forEach { $0.setAccessibilityTitle($0.title) }
    
    alert.showsSuppressionButton = showDontRepeat
    
    let result = alert.runModal()
    completionHandler(result)
  }
}
