import Cocoa
import SwiftUI

@main
class AppDelegate: NSObject, NSApplicationDelegate {
  var completionManager: CompletionManager? = nil
  var statusItem: NSStatusItem!
  var controlWindow: NSWindow!
  
  @IBOutlet weak var menu: NSMenu!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    statusItem = NSStatusBar.system.statusItem(withLength: 20)
    
    statusItem?.button?.setAccessibilityTitle("Status icon")
    
    let image = NSImage(named: "StatusIcon")
    image?.size = NSSize(width: 17, height: 17)
    
    statusItem?.button?.image = image
    
    statusItem?.menu = menu
  }
  
  func applicationDidFinishLaunching(_ aNotification: Notification) {
    SettingsManager.shared.settings.isAvailable = true
    
    completionManager = CompletionManager.shared
    
    let windowWidth = 900.0
    let windowHeight = 500.0
    
    let origin = CGPoint.zero
    let size = CGSize(width: windowWidth, height: windowHeight)
    
    let controller = NSHostingController(rootView: ControlPanelView())
    
    controlWindow = NSWindow(contentRect: NSRect(origin: origin, size: size), styleMask: [.titled, .closable, .fullSizeContentView, .resizable], backing: .buffered, defer: false)
    controlWindow.title = "Control Panel"
    controlWindow.minSize = NSSize(width: windowWidth, height: windowHeight)
    controlWindow.contentViewController = controller
    controlWindow.isReleasedWhenClosed = false
    controlWindow.setAccessibilityTitle("Control Panel")
    controlWindow.setFrame(NSRect(x: 0, y: 0, width: windowWidth, height: windowHeight), display: true, animate: false)
  }
  
  @IBAction func toggleControlWindow(_ sender: NSMenuItem) {
    if controlWindow.isVisible {
      controlWindow.close()
    } else {
      controlWindow.makeKeyAndOrderFront(nil)
    }
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
