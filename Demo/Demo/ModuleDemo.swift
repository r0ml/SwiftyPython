
// Alert(title: Text("Important message"), message: Text("Wear sunscreen"), dismissButton: .default(Text("Got it!")))

import SwiftUI
import Caerbannog

class Alerter : ObservableObject {
  @Published var showing : Bool = false
  @Published var title : String = "title"
  @Published var message : String = "message"
  @Published var dismiss : String = "Got it!"
}

extension Demo {
  static func runModuleDemo() {
    alview = AlertView(flag: alerter)
    
    let w = NSWindow(
      contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
      styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
      backing: .buffered, defer: false)
    w.center()
    w.contentMinSize = CGSize(width: 480, height: 300)
    w.setFrameAutosaveName("Alert Window")
    w.isReleasedWhenClosed = false
    w.contentView = NSHostingView(rootView: alview!)
    window = w
    window?.makeKeyAndOrderFront(nil)
  }
}

struct AlertView: View {
  @ObservedObject var flag : Alerter
  
  var body: some View {

    // The following needs to be in AppDelegate's applicationWillFinishLaunching()
    //     swiftModule.addMethod("alert", swiftModuleAlert)

    Button(action: {
      let _ = Python.run(
"""
print("clem")
swift_module.alert('one','two','three')
""")
    }) {
      Text("Show Alert")
    }
    .alert(isPresented: $flag.showing) {
      Alert(title: Text(flag.title), message: Text(flag.message), dismissButton: .default(Text(flag.dismiss)))
    }.frame(minWidth: 480, minHeight: 300)
  }
}

fileprivate var window : NSWindow?
fileprivate var alview : AlertView?
fileprivate var alerter = Alerter()

// The following needs to be in AppDelegate's applicationWillFinishLaunching()
//     swiftModule.addMethod("alert", swiftModuleAlert)

func swiftModuleAlert(_ a : PyObjectRef?, _ b : PyObjectRef?) -> PyObjectRef? {
  // a is the Python module object for the swift module
  // b is a tuple consisting of the arguments

  // this gets the arguments as an array of PythonObject
  if let po = [PythonObject].init(PythonObject(retaining: &b!.pointee)) {
    // if po.isType(&PyTuple_Type) {
    let j = po.count // Int(try! Python.len(po))!
    if j > 0, let s = String(po[0]) { alerter.title = s }
    if j > 1, let s = String(po[1]) { alerter.message = s }
    if j > 2, let s = String(po[2]) { alerter.dismiss = s }
  }
  
  window?.makeKeyAndOrderFront(nil)
  alerter.showing = true
  return PyNone
}
