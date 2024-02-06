
import Foundation

import PythonSupport

// for (x,y) in ProcessInfo.processInfo.environment {
//   print("var: \(x), value: \(y)")
// }

// let _ = Python

var greeting = "Hello, playground"

let z = Python.run("z=3+4", returning: "z")

Python.eval("3 + 4")
