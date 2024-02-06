
import SwiftUI

struct ContentView: View {
  //  let ad = AppDelegate.only
  //  @EnvironmentObject var ad : AppDelegate
  @Environment(\.openWindow) var openWindow
  
  var body: some View {
    VStack() {
      Text("Check out the source code to see how it works!").fixedSize(horizontal: false, vertical: false ).frame(alignment: .leading).layoutPriority(10)
      Buttonier(label: "Run Bing Images Downloads") { openWindow(id: "bingImages") }
      Buttonier(label: "Run Asciify demo") { openWindow(id: "asciifyView") }
      Buttonier(label: "Run NumpyMatplotlib") { openWindow(id: "numpyMatplotlibView") }
      Buttonier(label: "Run Dominate demo") { openWindow(id: "dominateView") }
      Buttonier(label: "Run Boto demo") { openWindow(id: "botoView") }
      Buttonier(label: "Run Numpy demo", action: Demo.runNumpyDemo)
      Buttonier(label: "Run Module demo") { openWindow(id: "alertView") }
    }.frame(minWidth: 250, minHeight: 200).padding(.horizontal, 40).padding(.vertical, 20)
      .fixedSize(horizontal: false, vertical: false)
  }
}

// I needed this in order to make all the buttons the same width in the VStack
struct Buttonier : View {
  var label : String
  var action : () -> ()
  
  var body : some View {
    GeometryReader() { gg in Button(action: self.action) {
      Text(self.label).frame(minWidth: gg.size.width, alignment: .leading)
    } }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
