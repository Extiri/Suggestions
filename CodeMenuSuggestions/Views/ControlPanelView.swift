import SwiftUI

struct ControlPanelView: View {
    var body: some View {
      NavigationView {
        SidebarView()
          .frame(width: 200)
        HelpView()
      }
    }
}
