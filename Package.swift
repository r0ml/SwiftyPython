// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package.init(
  name: "Python",
  platforms: [
      .macOS(.v14),
  ],
  products: [
    // Products define the executables and libraries produced by a package, and make them visible to other packages.
    .library(
      name: "Python",
      targets: ["PythonSupport", "PythonX", "PythonWrapper"]),
  ],
  dependencies: [
    // Dependencies declare other packages that this package depends on.
    // .package(url: /* package url */, from: "1.0.0"),
    
  ],
  targets: [
    .target(
      name: "PythonSupport",
      dependencies: ["PythonWrapper", "PythonX"]
    ),
    .target(
      name: "PythonWrapper",
      dependencies: [],
 //     publicHeadersPath: "./HandRolled/Python.xcframework/macos-arm64_x86_64/Python.framework/Headers"
      
      cSettings: [
//        .headerSearchPath("./Products/Library/Frameworks/Python.framework/Headers"),
//         .headerSearchPath("Python.xcframework/"),
        .headerSearchPath("Python.framework/Headers")
       
      ]
    ),
  .binaryTarget(name: "PythonX",
                path: "./HandRolled/Python.xcframework"
                )
                ]
)
