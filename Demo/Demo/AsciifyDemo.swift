
import SwiftUI
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
      VStack {
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
            
            
           let k = try! Python.run(
"""
import PIL.Image

img = PIL.Image.open('\(f.path)')
img_flag = True

width, height = img.size
aspect_ratio = height/width
new_width = 120
new_height = aspect_ratio * new_width * 0.55
img = img.resize((new_width, int(new_height)))

img = img.convert('L')

chars = ["@", "J", "D", "%", "*", "P", "+", "Y", "$", ",", "."]

pixels = img.getdata()
new_pixels = [chars[pixel//25] for pixel in pixels]
new_pixels = ''.join(new_pixels)
new_pixels_count = len(new_pixels)
ascii_image = [new_pixels[index:index + new_width] for index in range(0, new_pixels_count, new_width)]
ascii_image = "\\n".join(ascii_image)
""",
returning: "ascii_image")
            
              self.asciid = String(k!)
              self.visible = true
          }
        }
      }
      
    }
    return true
  }
}

