
import Foundation

import PythonWrapper
import PythonSupport

var greeting = "Hello, playground"

let z = Python.run("z=3+4", returning: "z")

Python.eval("3 + 4")
