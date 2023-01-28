import SwiftUI

struct HelpView: View {
  var body: some View {
    VStack {
      Text("How to make suggestions appear?")
        .font(.title)
      
      Text("All you have to do is enter §§ signs on the line where you want to show suggestions, then a suggestions window will appear. You enter query after §§ signs. Suggestions window will update automatically.")
      
      Divider()
      
      Text("How to select and choose suggestions?")
        .font(.title)
      
      Text("In suggestions window, you can move upwards using ⌥ (Option) + [ key combination and downwards using ⌥ (Option) + ]. You choose snippet to enter using ⌥ (Option) + v.")
      
      Spacer()
    }
    .padding()
  }
}

struct HelpView_Previews: PreviewProvider {
  static var previews: some View {
    HelpView()
  }
}
