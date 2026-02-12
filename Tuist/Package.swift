// swift-tools-version: 5.10
import PackageDescription

#if TUIST
import ProjectDescription

let packageSettings = PackageSettings(
    productTypes: [
        "ComposableArchitecture": .framework,
    ]
)
#endif

let package = Package(
    name: "Browser",
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "1.17.0"),
    ]
)
