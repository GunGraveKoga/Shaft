// swift-tools-version: 6.4
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Playground",
    platforms: [
        .macOS(.v14),
        .iOS(.v15),
        .tvOS(.v15),
    ],
    products: [
        // Shaft playground app
        .executable(name: "Playground", targets: ["Playground"]),
    ],
    dependencies: [
        .package(
            url: "https://github.com/ShaftUI/SwiftReload.git",
            from: "0.0.1"
        ),
        .package(
            url: "https://github.com/ShaftUI/SwiftMath",
            .upToNextMajor(from: "3.4.0")
        ),
        .package(path: ".."),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .executableTarget(
            name: "Playground",
            dependencies: [
                .product(name: "Shaft", package: "Shaft"),
                .product(name: "ShaftMarkdown", package: "Shaft"),
                .product(name: "ShaftSetup", package: "Shaft"),
                .product(name: "ShaftLucide", package: "Shaft"),
                .product(name: "ShaftCodeHighlight", package: "Shaft"),
                .product(name: "SwiftMath", package: "SwiftMath"),
                .product(
                    name: "SwiftReload",
                    package: "SwiftReload",
                    condition: .when(platforms: [.linux, .macOS])
                ),
            ],
            swiftSettings: [
                .interoperabilityMode(.Cxx, .when(platforms: [.windows, .linux, .macOS])),
                .unsafeFlags(["-Xfrontend", "-enable-private-imports"]),
                .unsafeFlags(["-Xfrontend", "-enable-implicit-dynamic"]),
            ],
            linkerSettings: [
                .unsafeFlags(
                    ["-Xlinker", "--export-dynamic"],
                    .when(platforms: [.linux, .android])
                )
            ]
        ),

    ]
)
