
import PythonSupport

// import PythonWrapper
// import PythonX

let k = PythonInterface.shared

try k.eval("3+7")
PyNone


PythonObject(consuming: PythonInterface.shared.pyGlobals).description

