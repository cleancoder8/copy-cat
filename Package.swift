// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "CopyCat",
    platforms: [.macOS(.v14)],
    products: [.executable(name: "CopyCat", targets: ["CopyCat"])],
    targets: [.executableTarget(name: "CopyCat"), .testTarget(name: "CopyCatTests", dependencies: ["CopyCat"])]
)
