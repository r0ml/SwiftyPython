
import PythonWrapper

public protocol ConvertibleToPython {
  var pythonObject: PythonObject { get }
}

extension PythonObject : ConvertibleToPython {
  public var pythonObject: PythonObject { return self }
}

extension Bool : ConvertibleToPython {
  public var pythonObject: PythonObject {
    return PythonObject(consuming: PyBool_FromLong(self ? 1 : 0))
  }
}

extension String : ConvertibleToPython {
  public var pythonObject: PythonObject {
    let v = self.cString(using:.utf8)!
    let c = v.count
    let r = UnsafeMutablePointer<CChar>.allocate(capacity: c)
    for i in 0..<c { r[i]=v[i] }
    let j = PyUnicode_FromStringAndSize(r, c-1)
    r.deallocate()
    return PythonObject(consuming: j!)
  }
}

extension Int : ConvertibleToPython {
  public var pythonObject: PythonObject { return PythonObject(consuming: PyLong_FromLong(self)) }
}

extension UInt : ConvertibleToPython {
  public var pythonObject: PythonObject { return PythonObject(consuming: PyLong_FromSize_t(Int(self))) }
}

extension Double : ConvertibleToPython {
  public var pythonObject: PythonObject { return PythonObject(consuming: PyFloat_FromDouble(self)) }
}

extension Optional : ConvertibleToPython where Wrapped : ConvertibleToPython {
  public var pythonObject: PythonObject { return self?.pythonObject ?? Python.None }
}

extension Array : ConvertibleToPython where Element : ConvertibleToPython {
  public var pythonObject: PythonObject {
    let list = PyList_New(count)!
    for (index, element) in enumerated() {
      // `PyList_SetItem` steals the reference of the object stored.
      _ = PyList_SetItem(list, index, element.pythonObject.retained() )
    }
    return PythonObject(consuming: list)
  }
}

extension Dictionary : ConvertibleToPython where Key : ConvertibleToPython, Value : ConvertibleToPython {
  public var pythonObject: PythonObject {
    let dict = PyDict_New()!
    for (key, value) in self {
      let k = key.pythonObject.retained()
      let v = value.pythonObject.retained()
      PyDict_SetItem(dict, k, v)
      Py_DecRef(k)
      Py_DecRef(v)
    }
    return PythonObject(consuming: dict)
  }
}

extension Range : ConvertibleToPython where Bound : ConvertibleToPython {
  public var pythonObject: PythonObject { return try! Python.slice(lowerBound, upperBound, Python.None) }
}

extension PartialRangeFrom : ConvertibleToPython where Bound : ConvertibleToPython {
  public var pythonObject: PythonObject { return try! Python.slice(lowerBound, Python.None, Python.None) }
}

extension PartialRangeUpTo : ConvertibleToPython where Bound : ConvertibleToPython {
  public var pythonObject: PythonObject { return try! Python.slice(Python.None, upperBound, Python.None) }
}
