// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "SwiftyPython",
  platforms: [
      .macOS(.v11),
  ],
  products: [
    // Products define the executables and libraries produced by a package, and make them visible to other packages.
    .library(
      name: "Python",
      targets: ["SwiftyPython"]),
  ],
  dependencies: [
    // Dependencies declare other packages that this package depends on.
    // .package(url: /* package url */, from: "1.0.0"),
    
  ],
  targets: [
  .binaryTarget(name: "SwiftyPython",
                path: "cpython/Python.xcframework"
                )
                ]
)
