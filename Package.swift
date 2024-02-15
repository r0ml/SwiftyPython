// swift-tools-version:5.9

import PackageDescription

let package = Package.init(
  name: "Python",
  platforms: [
      .macOS(.v14),
  ],
  products: [
    .library(
      name: "Python",
      targets: ["PythonSupport"]),
  ],
  dependencies: [
  ],
  targets: [
    .target(
      name: "PythonSupport",
      dependencies: ["PythonWrapper"],
      linkerSettings: [.linkedFramework("Python")]
    ),
    .target(
      name: "PythonWrapper",
      dependencies: ["RawPythonWrapper"],
      linkerSettings: [.linkedFramework("Python")]
    ),
    .target(
      name: "RawPythonWrapper",
      dependencies: ["PythonX"],
      cSettings: [
        .headerSearchPath("Python.framework/Headers")
      ]
    ),
  

      .binaryTarget(name: "PythonX",
                path: "./HandRolled/Python.xcframework"
                ),
/*
      .binaryTarget(name: "PythonX",
                       url: "https://github.com/r0ml/SwiftyPython/releases/download/3.12.0/Python.xcframework.zip",
                       checksum: "208783362a48a337421aa53754bf8e6d58ddbd51189981507e990b39572ffe1b"),
*/
  ]

)
