
import SwiftUI
import WebKit
import Caerbannog

extension Demo {
  static public func runDominateDemo() {
    let str = """
import dominate
from dominate.tags import *

doc = dominate.document(title='Dominate your HTML')

with doc.head:
    link(rel='stylesheet', href='style.css')
    script(type='text/javascript', src='script.js')

with doc:
    with div(id='header').add(ol()):
        for i in ['home', 'about', 'contact']:
            li(a(i.title(), href='http://localhost/%s.html' % i))
    with div():
        attr(cls='body')
        p('Lorem ipsum..')

"""
    var hi : String
    if let zz = Python.run(str, returning: "doc"),
      let hh = try? String(zz.__str__()) {
      hi = hh
    } else {
      hi = "dominate demo failed"
    }

    let window = NSWindow(
      contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
      styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
      backing: .buffered, defer: false)
    window.center()
    window.setFrameAutosaveName("Dominate Demo")
    window.isReleasedWhenClosed = false
    window.contentView = NSHostingView(rootView: DominateView(html: hi))
    window.makeKeyAndOrderFront(nil)
  }
}

struct DominateView : View {
  @State var tgt : Bool = false
  @State var asciid : String?
  @State var visible : Bool = false
  
  @State var html : String
  
  var body : some View {
    WebKit(html: self.html)
/*    VStack() {
      ScrollView() {
        TextField("clem", text: $html).lineLimit(60)
      }
    }
 */
  }
}

struct WebKit : NSViewRepresentable {
  var html : String
  var wv = WKWebView()
  var tt = TT()
  
//  func makeCoordinator() -> () {
//
//  }
  
  func makeNSView(context: Context) -> WKWebView {
    wv.loadHTMLString("Hello?", baseURL: nil)
    // wv.uiDelegate = tt
    
    wv.autoresizingMask = [ .width, .height]
      //    wv.webPlugInStart()
    return wv
  }
  
  func updateNSView(_ nsView: WKWebView, context: Context) {
    print(html)
    nsView.loadHTMLString(html, baseURL: nil)
  //  nsView.viewWillDraw()
  //  nsView.superview?.needsLayout = true
  //  nsView.superview?.layoutSubtreeIfNeeded()
   // let zz = nsView.superview!.bounds.size
   // nsView.superview?.setFrameSize(CGSize(width: zz.width+1, height: zz.height+1))
    print(nsView.isLoading)
   // nsView.window?.display()
  }
  
  // typealias NSViewType = WKWebView
  
}

class TT : NSObject, WKUIDelegate {
  
}

struct Dominate_Previews: PreviewProvider {
  static var previews: some View {
    DominateView(html: "<h1 align=center>this is a test</h1><hr/>")
  }
}
