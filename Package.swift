// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "trexvpn",
    platforms: [
        .macOS(.v12), .iOS(.v15)
    ],
    products: [
        .library(name: "trexvpn", targets: ["trexvpn"]),
    ],
    targets: [
        .target(
            name: "trexvpn",
            path: "src"
        ),
    ]
)
