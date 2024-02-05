// Copyright (c) 1868 Charles Babbage
// Found amongst his effects by r0ml

import SwiftUI
import PythonSupport

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
        .task {
          doit()
//          await MainActor.run {
//            Python.run("import ensurepip")
//          }
          
        }
    }
  
  func doit() {
    Task {
      await MainActor.run {
        Python.run("import sqlite3")
        Python.run("c = sqlite3.connect('')")
        Python.run("c.execute('create table clem(a int)')")
        // Python.run("import ensurepip; ensurepip.bootstrap(upgrade=False, user=True)")
        //        Python.run("import pip")
        // Python.run("pip.main(['install', 'asciify'])")
      }
    }
  }
}

#Preview {
    ContentView()
}
