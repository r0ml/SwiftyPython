
import SwiftUI
import PythonSupport

extension Demo {
  static public func runNumpyMatplotlibDemo() {
    let str = """
import numpy as np
import matplotlib.pyplot as plt
import io

# Compute the x and y coordinates for points on sine and cosine curves
x = np.arange(0, 3 * np.pi, 0.1)
y_sin = np.sin(x)
y_cos = np.cos(x)

# Plot the points using matplotlib
plt.plot(x, y_sin)
plt.plot(x, y_cos)
plt.xlabel('x axis label')
plt.ylabel('y axis label')
plt.title('Sine and Cosine')
plt.legend(['Sine', 'Cosine'])

buf = io.BytesIO()
plt.savefig(buf, format='png')
buf.seek(0)
result = buf.getvalue()
"""
    
    guard let hh = Python.run(str, returning: "result") else {
      print("failed to run python code")
      return
    }
    
    let hi = Data(hh)!
    let imm = NSImage(data: hi)!
    
    let window = NSWindow(
      contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
      styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
      backing: .buffered, defer: false)
    window.center()
    window.setFrameAutosaveName("Numpy Matplotlib Demo")
    window.isReleasedWhenClosed = false
    window.contentView = NSHostingView(rootView: NumpyMatplotlibView(plot: imm))
    window.makeKeyAndOrderFront(nil)
  }
}

struct NumpyMatplotlibView : View {
  var plot : NSImage
  var body : some View {
    Image(nsImage: plot)
      .resizable()
      .aspectRatio(contentMode: .fit)
  }
}

struct NumpyMatplotlib_Previews: PreviewProvider {
  static var previews: some View {
    NumpyMatplotlibView(plot: NSImage() )
  }
}

