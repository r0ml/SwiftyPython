
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
          let p = Python
          swiftModule.addMethod("alert", swiftModuleAlert)
          Python.start()
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
