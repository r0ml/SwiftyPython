
// Alert(title: Text("Important message"), message: Text("Wear sunscreen"), dismissButton: .default(Text("Got it!")))

import SwiftUI
import PythonSupport

@Observable class Alerter {
  var showing : Bool = false
  var title : String = "title"
  var message : String = "message"
  var dismiss : String = "Got it!"
}

struct AlertView: View {
  @State var showing : Bool = false
  
  var body: some View {

    // The following needs to be in AppDelegate's applicationWillFinishLaunching()
    //     swiftModule.addMethod("alert", swiftModuleAlert)

    Button(action: {
      let _ = try? Python.run(
"""
print("clem")
swift_module.alert('one','two','three')
""")
    }) {
      Text("Show Alert")
    }
    .alert(isPresented: $showing) {
      Alert(title: Text(alerter.title), message: Text(alerter.message), dismissButton: .default(Text(alerter.dismiss)))
    }.frame(minWidth: 480, minHeight: 300)
      .onChange(of: alerter.showing) {
        showing = alerter.showing
      }
      .onChange(of: showing) {
        alerter.showing = showing
      }
  }
}

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
  
  alerter.showing = true
  return PyNone
}
