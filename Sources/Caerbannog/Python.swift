
import AppKit
import PythonWrapper
// @_exported import PythonWrapper


public typealias PyObjectRef = UnsafeMutablePointer<PyObject>

public let PyFalse = UnsafeMutableRawPointer( &_Py_FalseStruct ).assumingMemoryBound(to: PyObject.self)
public let PyTrue = UnsafeMutableRawPointer( &_Py_TrueStruct ).assumingMemoryBound(to: PyObject.self)
public let PyNone = UnsafeMutableRawPointer( &_Py_NoneStruct ).assumingMemoryBound(to: PyObject.self)

public var stdout : StdoutCapture!
public var swiftModule : SwiftModule!

public var Python = PythonInterface()

fileprivate func throwErrorIfPresent() throws {
  if PyErr_Occurred() == nil { return }
  
  var type: PyObjectRef?
  var value: PyObjectRef?
  var traceback: PyObjectRef?
  
  // Fetch the exception and clear the exception state.
  PyErr_Fetch(&type, &value, &traceback)
  
  // The value for the exception may not be set but the type always should be.
  let resultObject = PythonObject(consuming: value ?? type!)
  let tracebackObject = traceback.flatMap { PythonObject(consuming: $0) }
  throw PythonError.exception(resultObject, traceback: tracebackObject)
}

@dynamicMemberLookup
public class PythonInterface {

  public var pyBuiltins: PythonObject! // this is the Python builtins object
  public var pyGlobals: PyObjectRef!
  public var builtins : [ String : PythonObject ]  = [:] // this is a Swift dictionary mapping names to Python builtin objects
  
  public init() {
    let hh = Bundle.main.privateFrameworksURL!
/*
 let kk = try? FileManager.default.contentsOfDirectory(
            at: hh,
            includingPropertiesForKeys: nil
        )
 */
     let hh1 = hh.appendingPathComponent("Python.framework").appendingPathComponent("Versions").appendingPathComponent("Current")
//    let hh1 = kk!.first!
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
    
    // let module = PyImport_ImportModule("sys")
    // let sys = PythonObject(consuming: module!)
    // builtins["sys"] = sys
    
    //  // If I were initialized, I could have said:
    let sys = self.sys
    let bb = Bundle.main.resourceURL!
    let bb1 = bb.appendingPathComponent("venv").appendingPathComponent("lib")
    let bb2 = try! FileManager.default.contentsOfDirectory(atPath: bb1.path)
    for k in bb2 {
      let bb3 = bb1.appendingPathComponent(k).appendingPathComponent("site-packages")
      try! sys.path.insert(0, bb3.path)
    }
 
    // FIXME: put this back to make SSL work
/*
 let _ = Python.run("""
import ssl
import certifi

def _create_certifi_context():
  return ssl.create_default_context(purpose=ssl.Purpose.SERVER_AUTH, cafile=certifi.where())

ssl._create_default_https_context = _create_certifi_context
""")
 */
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
  
  public func run(_ str : String, returning: String) -> PythonObject? {
    return self.run(str, returning: [returning]).first!
  }
  
  public func run(_ str : String, returning: [String] = []) -> [PythonObject?] {
    // If I had an error somewhere and forgot to check, now is when I'm going to ignore it.
    PyErr_Clear()
    PyRun_SimpleStringFlags(str, nil)
    if PyErr_Occurred() != nil {
      PyErr_Print()
      PyErr_Clear()
    }
    
    let r = returning.map {
      // PyDict_GetItemString(pyGlobals, $0.??)
      let z = $0.pythonObject
      return PythonObject(retaining: PyDict_GetItem(pyGlobals, z.pointer))
    }
    return r
  }
}

@dynamicCallable
@dynamicMemberLookup

public struct PythonObject {
  var pointer: PyObjectRef
  
  public init(retaining pointer: PyObjectRef) {
    self.pointer = pointer
    retain()
  }
  
  public init(consuming pointer: PyObjectRef) {
    self.pointer = pointer
  }
  
  public func retain() {
    Py_IncRef(pointer)
  }
  
  public func retained() -> PyObjectRef {
    retain()
    return pointer
  }
  
  public func release() {
    Py_DecRef(pointer)
  }
}

extension PythonObject : CustomStringConvertible {
  public var description: String {
    let z = PythonObject(retaining: PyEval_GetBuiltins())
    let str = z["str"]!
    return try! String( str(self))!
  }
  
  public var debugDescription: String {
    return description
  }
  
}

extension PythonObject : CustomPlaygroundDisplayConvertible {
  public var playgroundDescription: Any {
    return description
  }
}

extension PythonObject : CustomReflectable {
  public var customMirror: Mirror {
    return Mirror(self, children: [], displayStyle: .struct)
  }
}

public extension PythonObject {
  init(tupleOf elements: ConvertibleToPython...) {
    self.init(tupleContentsOf: elements)
  }
  
  init<T : Collection>(tupleContentsOf elements: T) where T.Element == ConvertibleToPython {
    let tuple = PyTuple_New(elements.count)!
    for (index, element) in elements.enumerated() {
      PyTuple_SetItem(tuple, index, element.pythonObject.retained())
    }
    self.init(consuming: tuple)
  }
}

public extension PythonObject {
  
  subscript(dynamicMember memberName: String) -> PythonObject {
    get {
      if let result = (memberName.utf8CString.withUnsafeBufferPointer {
        PyObject_GetAttrString(pointer, $0.baseAddress) }) {
        return PythonObject(consuming: result)
      }
      
      if self.isType(&PyModule_Type) {
        let s = String(self.__name__)!+"."+memberName
        return PythonObject(consuming: PyImport_Import(PythonObject(s).retained()))
      }
      
      try! throwErrorIfPresent()
      return PythonObject(retaining: PyNone)
    }
    
    nonmutating set {
      let selfObject = retained()
      defer { release() }
      let valueObject = newValue.retained()
      defer { newValue.release() }
      
      if PyObject_SetAttrString(selfObject, memberName, valueObject) == -1 {
        try! throwErrorIfPresent()
        fatalError("Could not set PythonObject member '\(memberName)' to the specified value")
      }
    }
  }
  
  subscript(key: ConvertibleToPython) -> PythonObject? {
    get {
      guard let result = PyObject_GetItem(pointer, key.pythonObject.pointer) else { return nil }
      return PythonObject(retaining: result)
    }
    nonmutating set {
      if let newValue = newValue {
        PyObject_SetItem(pointer, key.pythonObject.pointer, newValue.pythonObject.pointer)
      } else {
        PyObject_DelItem(pointer, key.pythonObject.pointer)
      }
      try! throwErrorIfPresent()
    }
  }
  
  /// Call `self` with the specified positional arguments.
  /// If the call fails for some reason, `PythonError.invalidCall` is thrown.
  /// - Precondition: `self` must be a Python callable.
  /// - Parameter args: Positional arguments for the Python callable.
  @discardableResult
  func dynamicallyCall(
    withArguments args: [ConvertibleToPython] = []
  ) throws -> PythonObject {
    try throwErrorIfPresent()
    
    // Positional arguments are passed as a tuple of objects.
    let argTuple = PythonObject(tupleContentsOf: args)
    defer { argTuple.release() }
    
    // Python calls always return a non-null object when successful. If the
    // Python function produces the equivalent of C `void`, it returns the
    // `None` object. A `null` result of `PyObjectCall` happens when there is an
    // error, like `self` not being a Python callable.
    let selfObject = retained()
    defer { release() }
    
    guard let result = PyObject_CallObject(selfObject, argTuple.pointer) else {
      // If a Python exception was thrown, throw a corresponding Swift error.
      try throwErrorIfPresent()
      throw PythonError.invalidCall(self)
    }
    return PythonObject(consuming: result)
  }
  
  /// Call `self` with the specified arguments.
  /// If the call fails for some reason, `PythonError.invalidCall` is thrown.
  /// - Precondition: `self` must be a Python callable.
  /// - Parameter args: Positional or keyword arguments for the Python callable.
  @discardableResult
  func dynamicallyCall(
    withKeywordArguments args:
    KeyValuePairs<String, ConvertibleToPython> = [:]
  ) throws -> PythonObject {
    try throwErrorIfPresent()
    
    // An array containing positional arguments.
    var positionalArgs: [PythonObject] = []
    // A dictionary object for storing keyword arguments, if any exist.
    var kwdictObject: PyObjectRef? = nil
    
    for (key, value) in args {
      if key.isEmpty {
        positionalArgs.append(value.pythonObject)
        continue
      }
      // Initialize dictionary object if necessary.
      if kwdictObject == nil { kwdictObject = PyDict_New()! }
      // Add key-value pair to the dictionary object.
      // TODO: Handle duplicate keys.
      // In Python, `SyntaxError: keyword argument repeated` is thrown.
      let k = PythonObject(key).retained()
      let v = value.pythonObject.retained()
      PyDict_SetItem(kwdictObject, k, v)
      Py_DecRef(k)
      Py_DecRef(v)
    }
    
    defer { Py_DecRef(kwdictObject) } // Py_DecRef is `nil` safe.
    
    // Positional arguments are passed as a tuple of objects.
    let argTuple = PythonObject(tupleContentsOf: positionalArgs)
    defer { argTuple.release() }
    
    // Python calls always return a non-null object when successful. If the
    // Python function produces the equivalent of C `void`, it returns the
    // `None` object. A `null` result of `PyObjectCall` happens when there is an
    // error, like `self` not being a Python callable.
    let selfObject = retained()
    defer { release() }
    
    guard let result = PyObject_Call(selfObject, argTuple.pointer, kwdictObject) else {
      // If a Python exception was thrown, throw a corresponding Swift error.
      try throwErrorIfPresent()
      throw PythonError.invalidCall(self)
    }
    return PythonObject(consuming: result)
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
}

extension PythonError : CustomStringConvertible {
  public var description: String {
    switch self {
    case .exception(let e, let t):
      var exceptionDescription = "Python exception: \(e)"
      if let t = t {
        exceptionDescription += try! "\nTraceback: \(PythonObject("").join(Python.traceback.format_tb(t)))"
      }
      return exceptionDescription
    case .invalidCall(let e):   return "Invalid Python call: \(e)"
    case .invalidModule(let m): return "Invalid Python module: \(m)"
    case .indexError(let m):    return "Index error: \(m)"
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
  public var endIndex: Index { return try! Python.len(self) }
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
