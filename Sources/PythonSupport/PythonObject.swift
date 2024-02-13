// Copyright (c) 1868 Charles Babbage
// Found amongst his effects by r0ml

import Foundation
@_exported import PythonWrapper

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
    if Py_IsNone(pointer) != 0 {
      return "None"
    } else {
      let z = PythonObject(retaining: PyEval_GetBuiltins())
      let str = z["str"]!
      return try! String( str(self))!
    }
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
