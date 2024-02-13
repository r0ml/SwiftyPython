
import SwiftUI
import PythonSupport

struct NumpyMatplotlibView : View {
  var body : some View {
    let plot = runNumpyMatplotlibDemo()
    Image(nsImage: plot)
      .resizable()
      .aspectRatio(contentMode: .fit)
  }
  
  func runNumpyMatplotlibDemo() -> NSImage {
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
    
    
    guard let hh = try? PythonInterface.shared.run(str, returning: "result") else {
      print("failed to run python code")
      return NSImage()
    }
    
    let hi = Data(hh)!
    let imm = NSImage(data: hi)!
    return imm
  }

  
}

struct NumpyMatplotlib_Previews: PreviewProvider {
  static var previews: some View {
    NumpyMatplotlibView( )
  }
}

