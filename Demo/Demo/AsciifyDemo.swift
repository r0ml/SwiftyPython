
import SwiftUI
import PythonWrapper
import PythonSupport

struct AsciifyView : View {
  @State var tgt : Bool = false
  @State var img : NSImage?
  @State var asciid : String?
  @State var visible : Bool = false
  
  var body : some View {
    VStack {
      Text("Drop an Image on me").frame(maxWidth: .infinity, maxHeight: .infinity)
        .onDrop(of: [NSPasteboard.PasteboardType.fileURL.rawValue], delegate: self  )
        .background(Color.gray)
      HStack {
        if visible {
          Image(nsImage: img!)
            .resizable()
            .aspectRatio(contentMode: .fit)
          ScrollView(.vertical, showsIndicators: true) {
            Text(asciid ?? "asciify failed").font(Font.custom("Courier", size: 15)).fixedSize(horizontal: false, vertical: true ).frame(alignment: .leading)

            }.layoutPriority(10).fixedSize(horizontal: false, vertical: true )
        }
      }.frame(minHeight: 400, alignment: .center).layoutPriority(10)// .fixedSize(horizontal: false, vertical: true )
    }
  }
}

struct Asciify_Previews: PreviewProvider {
  static var previews: some View {
    AsciifyView()
  }
}


extension AsciifyView : DropDelegate {
  
  func performDrop(info: DropInfo) -> Bool {
    let provider = info.itemProviders(for: [NSPasteboard.PasteboardType.fileURL.rawValue])
    provider[0].loadDataRepresentation(forTypeIdentifier: NSPasteboard.PasteboardType.fileURL.rawValue) {
      (data, error) in
      if let d = data,
        let ff = String(data: d, encoding: .utf8),
        let f = URL(string: ff),
         let i = NSImage(contentsOf: f) {
        self.img = i
        
        Task {
          await MainActor.run {
            // animated GIF causes error to be thrown here
        
            // FIXME: can I set the paths for dlopen here?
            
            
            /*
            let boodoo = Python.run("""
import PIL.Image
from PIL import Image
boodoo = 'goober'

# i = Image.open('\(f.path)')
# boodoo = i
# k = i.resize(150, 75, Image.ANTIALIAS)

# import asciify
# boodoo = asciify.do(k)
""", returning: "boodoo")
*/
            
//              let pi = Python.imports("Image", from: "PIL")
            let pi = Python.PIL.Image
            
              let j = try! pi.open(f.path)
            let k = try? j.resize([150,75].pythonObject, pi.LANCZOS)
               let aa = Python.asciify.AsciiManager()
            let bb = aa.transform(k)
              self.asciid = String(aa!)
              self.visible = true
/*            } else {
              if PyErr_Occurred() != nil {
                PyErr_Print()
                PyErr_Clear()
              }
            }
  */
            
          }
        }
      }
      
    }
    return true
  }
}

