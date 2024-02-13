
import SwiftUI
import WebKit
import PythonSupport


struct DominateView : View {
  
  
  @State var tgt : Bool = false
  @State var asciid : String?
  @State var visible : Bool = false
  
  
  var body : some View {
    let html = runDominateDemo()
    WebKit(html: html)
  }
  
  func runDominateDemo() -> String {
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
    do {
      if let zz = try PythonInterface.shared.run(str, returning: "doc"),
         let hh = try? String(zz.__str__()) {
        hi = hh
      } else {
        hi = "dominate demo failed"
      }
      return hi
    } catch(let e) {
      print(e)
    }
    return "demo failed"
  }
  
}

struct WebKit : NSViewRepresentable {
  var html : String
  var tt = TT()
  
  func makeNSView(context: Context) -> WKWebView {
    let wv = WKWebView()
    wv.loadHTMLString("Hello?", baseURL: nil)
    // wv.uiDelegate = tt
    
    wv.autoresizingMask = [ .width, .height]
    //    wv.webPlugInStart()
    return wv
  }
  
  func updateNSView(_ nsView: WKWebView, context: Context) {
    print(html)
    nsView.loadHTMLString(html, baseURL: nil)
  }
}

class TT : NSObject, WKUIDelegate {
  
}

struct Dominate_Previews: PreviewProvider {
  static var previews: some View {
    DominateView()
  }
}
