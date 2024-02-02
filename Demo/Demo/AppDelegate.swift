
import SwiftUI
import PythonSupport

struct Demo {
  
}


@main struct SampleApp : App {
  var body : some Scene {
    WindowGroup {
      ContentView().task {
        await MainActor.run {
          let p = Python
          swiftModule.addMethod("alert", swiftModuleAlert)
          Python.start()
        }
      }
    }
  }
}
