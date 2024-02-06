
import SwiftUI
import PythonSupport

struct BingImageView : View {
  @State var imgs : [NSImage] = []
  @State var keyword : String = ""
  
  var body : some View {
    VStack {
      Text("Try 'orange'")
      TextField("keyword", text: $keyword, onCommit: {
        let aa = Python.bing_image_downloader.downloader
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
