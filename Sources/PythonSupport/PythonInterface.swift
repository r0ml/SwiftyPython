
import Foundation
@_exported import PythonWrapper

public typealias PyObjectRef = UnsafeMutablePointer<PyObject>

public let PyFalse = UnsafeMutableRawPointer( &_Py_FalseStruct ).assumingMemoryBound(to: PyObject.self)
public let PyTrue = UnsafeMutableRawPointer( &_Py_TrueStruct ).assumingMemoryBound(to: PyObject.self)
public let PyNone = UnsafeMutableRawPointer( &_Py_NoneStruct ).assumingMemoryBound(to: PyObject.self)

public var stdout : StdoutCapture!
public var swiftModule : SwiftModule!

// public var PythonInterface.shared = PythonInterface()

public func throwErrorIfPresent() throws {
  if PyErr_Occurred() == nil { return }
  
  var type: PyObjectRef?
  var value: PyObjectRef?
  var traceback: PyObjectRef?
  
  // Fetch the exception and clear the exception state.
  PyErr_Fetch(&type, &value, &traceback)

  // The value for the exception may not be set but the type always should be.
  let resultObject = PythonObject(consuming: value ?? type!)
  let tracebackObject = traceback.flatMap { PythonObject(consuming: $0) }
  PyErr_Print()
  PyErr_Clear()

  throw PythonError.exception(resultObject, traceback: tracebackObject)
}

@dynamicMemberLookup
public class PythonInterface {
  public static var shared = PythonInterface()
  
  public var pyBuiltins: PythonObject! // this is the Python builtins object
  public var pyGlobals: PyObjectRef!
  public var builtins : [ String : PythonObject ]  = [:] // this is a Swift dictionary mapping names to Python builtin objects
  
  public init() {
    // This is the appropriate value for running the app under xcode
    var hh = Bundle.main.privateFrameworksURL!

    let env = ProcessInfo.processInfo.environment
    if let _ = env["PLAYGROUND_COMMUNICATION_SOCKET"],
      let bb = env["PACKAGE_RESOURCE_BUNDLE_PATH"] {
      hh = URL(string: bb)!
    }
      
    // FIXME: hh3 instead of hh for Playgrounds
    let hh1 = hh.appendingPathComponent("Python.framework").appendingPathComponent("Versions").appendingPathComponent("Current")

    // print("setting PythonHomw: \(hh1.path)")
    // FIXME: Py_SetPythonHome is deprecated -- so need to find the modern way to do this
    hh1.path.withWideChars {
      Py_SetPythonHome( $0 )
    }
    
    setup()
    start0()
  }
  
  public func setup() {
    stdout = StdoutCapture()
    swiftModule = SwiftModule()
    Py_Initialize()   // Initialize Python

  }
  
  public func start0() {
    // =======================================================================
    // Above the line is the initialization of the Swift-implemented module(s)
    // below is the actual initialization of the Python interpreter
    //  Py_Initialize()   // Initialize Python
    
    let __main__ = PyImport_ImportModule("__main__")
    pyGlobals = PyModule_GetDict( __main__ )
    pyGlobals.pointee.ob_refcnt += 1
    
    let stdcn = "stdout_capture"
    let stdcnn = stdcn.cString(using: .utf8)
    let stdc = PyImport_ImportModule(stdcnn)
    try! throwErrorIfPresent()
    PyDict_SetItem(pyGlobals, stdcn.pythonObject.retained(), stdc)
    
  }
  
  public func start() {
    let smn = "swift_module"
    let smnn = smn.cString(using: .utf8)!
    let sm = PyImport_ImportModule(smnn)
    try! throwErrorIfPresent()
    PyDict_SetItem(pyGlobals, smn.pythonObject.retained(), sm)
    
    pyBuiltins = PythonObject(retaining: PyEval_GetBuiltins())
    
    // FIXME: this should be in the app! not in the package!!!
    let sys = self.sys
    let bb = Bundle.main.resourceURL!
    let bb1 = bb.appendingPathComponent("venv").appendingPathComponent("site-packages")
    try! sys.path.insert(0, bb1.path)

    do {
      let _ = try PythonInterface.shared.run("""
import ssl
import certifi

def _create_certifi_context():
  return ssl.create_default_context(purpose=ssl.Purpose.SERVER_AUTH, cafile=certifi.where())

ssl._create_default_https_context = _create_certifi_context
""")
    } catch(let e) {
      print(e)
    }
  }

    
  public subscript(dynamicMember name: String) -> PythonObject {
    get {
    if let obj = builtins[name] {
      return obj
    }
    if let obj = pyBuiltins[name] {
      return obj
    }
    if let module = PyImport_ImportModule(name) {
      let res = PythonObject(consuming: module)
      builtins[name] = res
      return res
    }
    try! throwErrorIfPresent()
    return PythonObject(consuming: PyNone)
  }
  }
  
  public func imports( _ sub : String, from: String) -> PythonObject {
    let a = PyList_New(1)
    let z = PyList_SetItem(a, 0, sub.pythonObject.pointer)
    let iml = PyImport_ImportModuleLevel(from, nil, nil, a, 0)
    return PythonObject(retaining: iml!)
  }
  
  
  // Python error (if active) thrown as a Swift error
  
 public subscript<T>(dynamicMember name: String) -> T? where T : ConvertibleToPython {
    get {
    if let obj = builtins[name] {
      return obj as? T
    }
    if let obj = pyBuiltins[name] {
      return obj as? T
    }
    if let module = PyImport_ImportModule(name) {
      let res = PythonObject(consuming: module)
      builtins[name] = res
      return res as? T
    }
    try! throwErrorIfPresent()
    return PythonObject(consuming: PyNone) as? T
  }
    set {
      PyDict_SetItem(pyGlobals, name.pythonObject.retained(), newValue.pythonObject.retained())
    }
    
  }
  
  public func run(_ str : String, returning: String) throws -> PythonObject? {
    return try self.run(str, returning: [returning]).first!
  }
  
  public func run(_ str : String, returning: [String] = []) throws -> [PythonObject?] {
    // If I had an error somewhere and forgot to check, now is when I'm going to ignore it.
    PyErr_Clear()
    PyRun_SimpleStringFlags(str, nil)
    try throwErrorIfPresent()
    
    let r = returning.map {
      // PyDict_GetItemString(pyGlobals, $0.??)
      let z = $0.pythonObject
      if let kk = PyDict_GetItem(pyGlobals, z.pointer) {
        return PythonObject(retaining: kk)
      } else {
        return PythonObject(retaining: PyNone)
      }
    }
    return r
  }
  
  public func eval(_ str: String) throws -> PythonObject {
    PyErr_Clear()
    let kk = PyDict_New()
    let j = PyRun_StringFlags(str, Py_eval_input, pyGlobals, kk, nil)
    try throwErrorIfPresent()
    let r = PythonObject(retaining: j!)
    return r
  }
}

//=======================================================================
// String extensions
//=======================================================================
extension String {
  /// Calls the given closure with a pointer to the contents of the string represented as a null-terminated wchar_t array.
  func withWideChars<Result>(_ body: (UnsafeMutablePointer<wchar_t>) -> Result) -> Result {
    var u32 = self.unicodeScalars.map { wchar_t(bitPattern: $0.value) } + [0]
    return u32.withUnsafeMutableBufferPointer { body($0.baseAddress!) }
  }
}

//================================================================================

public enum PythonError : Error, Equatable {
  case exception(PythonObject, traceback: PythonObject?)
  case invalidCall(PythonObject)
  case invalidModule(String)
  case indexError(PythonObject)
  case runError(PythonObject)
}

extension PythonError : CustomStringConvertible {
  public var description: String {
    switch self {
    case .exception(let e, let t):
      var exceptionDescription = "Python exception: \(e)"
      if let t = t {
        exceptionDescription += try! "\nTraceback: \(PythonObject("").join(PythonInterface.shared.traceback.format_tb(t)))"
      }
      return exceptionDescription
    case .invalidCall(let e):   return "Invalid Python call: \(e)"
    case .invalidModule(let m): return "Invalid Python module: \(m)"
    case .indexError(let m):    return "Index error: \(m)"
    case .runError(let m): return "Run error: \(m)"
    }
  }
}

//================================================================================

//==============================================
// Standard operators
//==============================================

private typealias PythonBinaryOp = (PyObjectRef?, PyObjectRef?) -> PyObjectRef?

public extension PythonObject {
  private static func binaryOp(_ op: PythonBinaryOp, lhs: PythonObject, rhs: PythonObject) -> PythonObject {
    let result = op(lhs.pointer, rhs.pointer)
    try! throwErrorIfPresent()
    return PythonObject(consuming: result!)
  }
  
  static func + (lhs: PythonObject, rhs: PythonObject) -> PythonObject { return binaryOp(PyNumber_Add, lhs: lhs, rhs: rhs)  }
  static func - (lhs: PythonObject, rhs: PythonObject) -> PythonObject { return binaryOp(PyNumber_Subtract, lhs: lhs, rhs: rhs)  }
  static func * (lhs: PythonObject, rhs: PythonObject) -> PythonObject { return binaryOp(PyNumber_Multiply, lhs: lhs, rhs: rhs)  }
  static func / (lhs: PythonObject, rhs: PythonObject) -> PythonObject { return binaryOp(PyNumber_TrueDivide, lhs: lhs, rhs: rhs) }
  static func += (lhs: inout PythonObject, rhs: PythonObject) { lhs = binaryOp(PyNumber_InPlaceAdd, lhs: lhs, rhs: rhs) }
  static func -= (lhs: inout PythonObject, rhs: PythonObject) { lhs = binaryOp(PyNumber_InPlaceSubtract, lhs: lhs, rhs: rhs) }
  static func *= (lhs: inout PythonObject, rhs: PythonObject) { lhs = binaryOp(PyNumber_InPlaceMultiply, lhs: lhs, rhs: rhs) }
  static func /= (lhs: inout PythonObject, rhs: PythonObject) { lhs = binaryOp(PyNumber_InPlaceTrueDivide, lhs: lhs, rhs: rhs) }
}

//===========================================================
// Python Comparable and Equatable
//===========================================================
extension PythonObject : Equatable, Comparable {
  private func compared(to other: PythonObject, byOp: Int32) -> Bool {
    retain(); other.retain(); defer { release(); other.release() }
    switch PyObject_RichCompareBool(pointer, other.pointer, byOp) {
    case 0: return false
    case 1: return true
    default:
      try! throwErrorIfPresent()
      fatalError("No result or error returned when comparing \(self) to \(other)")
    }
  }
  
  public static func == (lhs: PythonObject, rhs: PythonObject) -> Bool { return lhs.compared(to: rhs, byOp: Py_EQ) }
  public static func != (lhs: PythonObject, rhs: PythonObject) -> Bool { return lhs.compared(to: rhs, byOp: Py_NE) }
  public static func <  (lhs: PythonObject, rhs: PythonObject) -> Bool { return lhs.compared(to: rhs, byOp: Py_LT) }
  public static func <= (lhs: PythonObject, rhs: PythonObject) -> Bool { return lhs.compared(to: rhs, byOp: Py_LE) }
  public static func >  (lhs: PythonObject, rhs: PythonObject) -> Bool { return lhs.compared(to: rhs, byOp: Py_GT) }
  public static func >= (lhs: PythonObject, rhs: PythonObject) -> Bool { return lhs.compared(to: rhs, byOp: Py_GE) }
}

//======================================================================

extension PythonObject : Hashable {
  public func hash(into hasher: inout Hasher) {
    guard let hash = try? Int(self.__hash__()) else {
      fatalError("Cannot use '__hash__' on \(self)")
    }
    hasher.combine(hash)
  }
}

extension PythonObject : MutableCollection {
  public typealias Index = PythonObject
  public typealias Element = PythonObject
  
  public var startIndex: Index { return PythonObject(0) }
  public var endIndex: Index { return try! PythonInterface.shared.len(self) }
  public func index(after i: Index) -> Index { return i + PythonObject(1) }
  
  public subscript(index: PythonObject) -> PythonObject {
    get {
      if let j = self[index as ConvertibleToPython] { return j }
      try! throwErrorIfPresent()
      return PythonObject(consuming: PyExc_IndexError)
    }
    set {
      self[index as ConvertibleToPython] = newValue
    }
  }
}

//=======================================================
// Python Iterator (Sequence)
//=======================================================
extension PythonObject : Sequence {
  public struct Iterator : IteratorProtocol {
    fileprivate let pythonIterator: PythonObject
    
    public func next() -> PythonObject? {
      guard let result = PyIter_Next(self.pythonIterator.pointer) else {
        PyErr_Print() // try! throwErrorIfPresent()
        PyErr_Clear()
        return nil
      }
      return PythonObject(consuming: result)
    }
  }
  
  public func makeIterator() -> Iterator {
    guard let result = PyObject_GetIter(pointer) else {
      try! throwErrorIfPresent()
      preconditionFailure()
    }
    return Iterator(pythonIterator: PythonObject(consuming: result))
  }
}
