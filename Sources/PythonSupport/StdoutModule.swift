
import SwiftUI
import os
import PythonSupport

let log = Logger()

fileprivate func error_out(_ mm : PyObjectRef?, _ xx : PyObjectRef?) -> PyObjectRef? {
  //  var m = mm!.pointee
  let j = PyTuple_GetItem(xx, 0)
  let zz = PythonObject(retaining: j!)
  try! print( String(Python.str(zz))!, terminator: "", to: &stdout )
  //  let st = PyModule_GetState(&m)
  //  let err = st!.assumingMemoryBound(to: module_state.self).pointee.error
  // PyErr_SetString(err!, "something bad happened".cString(using: .utf8))
  Py_IncRef(&_Py_NoneStruct)
  return UnsafeMutablePointer(&_Py_NoneStruct);
}

fileprivate let error_out_name = "error_out".cString(using: .utf8)
fileprivate let modname = "stdout_capture".cString(using:.utf8)

fileprivate let cbw = unsafeBitCast(callbackWrapper, to: Optional<UnsafeMutableRawPointer>.self)

fileprivate let callbackWrapper : @convention(c) (PyObjectRef, UnsafeMutablePointer<PyModuleDef>?) -> PyObjectRef? = stdout_install

fileprivate var slots = [
  PyModuleDef_Slot.init(slot: Py_mod_exec, value: cbw),
  PyModuleDef_Slot.init(slot: 0, value: nil)]

fileprivate func stdout_install(spec : PyObjectRef, def: UnsafeMutablePointer<PyModuleDef>!) -> PyObjectRef? {
      PyRun_SimpleStringFlags("""
  import stdout_capture
  import sys
  class StdoutCatcher:
      def write(self, stuff):
          stdout_capture.error_out(stuff)
  sys.stdout = StdoutCatcher()
  """, nil);
  
  return nil
}

fileprivate var myextension_methods : [PyMethodDef] = [
  PyMethodDef(ml_name: error_out_name, ml_meth: error_out, ml_flags: METH_VARARGS, ml_doc: nil),
  PyMethodDef(ml_name: nil, ml_meth: nil, ml_flags: 0, ml_doc: nil)
]

fileprivate var moduleDef : PyModuleDef!


fileprivate func myInitFn() -> PyObjectRef? {
  // return PyModule_Create2(&moduleDef!, 3);
/*  moduleDef = PyModuleDef.init(m_base: PyModuleDef_Base(), m_name: modname,
                               m_doc: nil, m_size: 0,
                               m_methods: &myextension_methods,
                               m_slots: &slots,
                               m_traverse: nil,
                               m_clear: nil,
                               m_free: nil)
  */
  
  withUnsafeMutablePointer(to: &myextension_methods[0]) { mxm in
    withUnsafeMutablePointer(to: &slots[0]) { sls in
      withUnsafeBytes(of: modname!) { modnamex in
        moduleDef = PyModuleDef.init(m_base: PyModuleDef_Base(), m_name: modnamex.baseAddress?.bindMemory(to: CChar.self, capacity: modname!.count+1),
                                     m_doc: nil, m_size: 0,
                                     m_methods: mxm, // &myextension_methods,
                                     m_slots: sls, // &slots,
                                     m_traverse: nil,
                                     m_clear: nil,
                                     m_free: nil)
      }
    }
  }

  
  
  
  
  return PyModuleDef_Init(&moduleDef)
}

extension StdoutCapture : TextOutputStream {
  public func write(_ string: String) {
    print(string)
    stringer.write(string)
  }
}

var stringer = ""

public class StdoutCapture {
  public init() {
    let _ = PyImport_AppendInittab(modname, myInitFn );
  }
}

public class Stringer {
  var log : String = ""
}

public struct StdoutView : View {
  @State var stdoutlog = ""
  
  public init() {
  }
  
  public var body : some View {
    ScrollView(.vertical, showsIndicators: true) {
      TextField.init("Python standard output", text: $stdoutlog).fixedSize(horizontal: false, vertical: true)
    }.padding()
      .onChange(of: stringer) {
        stdoutlog = stringer
      }
  }
}
