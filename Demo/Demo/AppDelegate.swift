
import SwiftUI
import PythonSupport

struct Demo {
  
}


@main struct SampleApp : App {
  @Environment(\.openWindow) var openWindow
  
  var body : some Scene {
    WindowGroup {
      ContentView().task {
        await MainActor.run {
          // This needs to happen in order to initialize Python
          let p = PythonInterface.shared
          swiftModule.addMethod("alert", swiftModuleAlert)
          PythonInterface.shared.start()
        }
        openWindow(id: "stdout")
      }
      
    }

    Window("Stdout", id: "stdout") {
      StdoutView()
    }

    
    Window("Bing Images", id: "bingImages") {
      BingImageView()
    }
    
    Window("Alert", id: "alertView") {
      AlertView()
    }
    
    Window("Dominate", id: "dominateView") {
      DominateView()
    }
    
    Window("Boto", id: "botoView") {
      BotoView()
    }
    
    Window("Asciify", id: "asciifyView") {
      AsciifyView()
    }
    
    Window("Numpy Matplotlib", id: "numpyMatplotlibView") {
      NumpyMatplotlibView()
    }
    
   }
}
