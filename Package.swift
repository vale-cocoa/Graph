// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Graph",
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "Graph",
            targets: ["Graph"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/vale-cocoa/Deque", from: "2.0.2"),
        .package(url: "https://github.com/vale-cocoa/PriorityQueue", from: "2.0.1"),
        .package(url: "https://github.com/vale-cocoa/IndexedPriorityQueue", from: "0.1.4"),
        .package(url: "https://github.com/vale-cocoa/UnionFind.git", from: "1.0.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "Graph",
            dependencies: ["Deque", "PriorityQueue", "IndexedPriorityQueue", "UnionFind"]),
        .testTarget(
            name: "GraphTests",
            dependencies: ["Graph", "Deque", "PriorityQueue", "IndexedPriorityQueue", "UnionFind"]),
    ]
)
