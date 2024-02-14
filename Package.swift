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
      dependencies: ["PythonWrapper"]
    ),
    .target(
      name: "PythonWrapper",
      dependencies: ["RawPythonWrapper"]
    ),
    .target(
      name: "RawPythonWrapper",
      dependencies: ["PythonX"],
      cSettings: [
        .headerSearchPath("Python.framework/Headers")
      ]
    ),
  
/*
      .binaryTarget(name: "PythonX",
                path: "./HandRolled/Python.xcframework"
                ),
*/
      .binaryTarget(name: "PythonX",
                       url: "https://github.com/r0ml/SwiftyPython/releases/download/3.12.beta1/Python.xcframework.zip",
                       checksum: "d2e001ab11c18cbdf0157c0737970d3cbd98af286ac79f9d05e66e7cc63b7e2d"),

  ]

)
