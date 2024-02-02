
import SwiftUI
import Caerbannog

extension Demo {
  
  static public func runBingImagesDownload() {
    let window = NSWindow(
      contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
      styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
      backing: .buffered, defer: false)
    window.center()
    window.setFrameAutosaveName("Google Images Download Window")
    window.isReleasedWhenClosed = false
    window.contentView = NSHostingView(rootView: GoogleImagesView())
    window.makeKeyAndOrderFront(nil)
  }
}

struct GoogleImagesView : View {
  @State var imgs : [NSImage] = []
  @State var keyword : String = ""

  var body : some View {
    VStack {
      Text("Try 'orange'")
      TextField("keyword", text: $keyword, onCommit: {
        let aa = Python.bing_image_downloader.downloader
//        let c = [ "query": self.keyword.pythonObject, "limit":3.pythonObject,
//                  "output_dir": FileManager.default.temporaryDirectory.path.pythonObject ] // , "print_paths" : true.pythonObject ]
//        let d = try! aa.download(c)
        
        let od = FileManager.default.temporaryDirectory
        defer { try? FileManager.default.removeItem(at: od) }
        
        // Bug in bing_image_downloader causes force_replace to cause a failure
        try! aa.download(query: self.keyword.pythonObject, limit: 3.pythonObject, output_dir: od.path.pythonObject, force_replace: true)
        
        let ii = try! FileManager.default.contentsOfDirectory(atPath: od.path + "/" + keyword)
        self.imgs = ii.map { NSImage(contentsOfFile: od.path+"/"+keyword+"/"+$0)! }
      })
    List {
      ForEach(imgs, id: \.hash ) { i in
        Image(nsImage: i).resizable().aspectRatio(contentMode: .fit)
      }
    }
  }
  }
}