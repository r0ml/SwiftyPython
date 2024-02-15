
import Foundation

import PythonSupport

Python.eval("3 + 4")

Python.run("import sys; z = sys.path", returning: "z")
