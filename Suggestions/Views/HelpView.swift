import SwiftUI

struct HelpView: View {
  var body: some View {
    VStack(alignment: .leading) {
      Text("How to make suggestions appear?")
        .font(.title3.bold())
      
      Text("All you have to do is enter \(SettingsManager.shared.settings.callsign)\(SettingsManager.shared.settings.callsign) signs on the line where you want to show suggestions, then a suggestions window will appear. You enter query after §§ signs. Suggestions window will update automatically.")
      
      Divider()
      
      Text("How to select and choose suggestions?")
        .font(.title3.bold())
      
      Text("In suggestions window, you can move upwards using ⌥ (Option) + [ key combination and downwards using ⌥ (Option) + ]. You choose snippet to enter using ⌥ (Option) + v. If snippet contains placeholders, query will be replaced with a special placeholder query which denotes placeholders using @name=#\"\"# pattern. Fill values between #\" and \"# and then use  ⌥ (Option) + v keyboard shortcut again.")
      
      Divider()
      
      Text("How to use abbreviations?")
        .font(.title3.bold())
      
      Text("You can use abbreviations by first setting an abbreviation for a snippet in CodeMenu and then accessing it by entering § anywhere and then the abbreviation. Code will appear automatically.")
      
      Spacer()
    }
    .padding()
  }
}
