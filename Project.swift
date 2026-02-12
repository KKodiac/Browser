import ProjectDescription

let project = Project(
    name: "Browser",
    settings: .settings(
        base: [
            "DEVELOPMENT_TEAM": "LVBMDY357W",
            "CODE_SIGN_STYLE": "Automatic",
        ],
        configurations: [
            .debug(name: "Debug"),
            .release(name: "Release"),
        ]
    ),
    targets: [
        .target(
            name: "Browser",
            destinations: [.mac],
            product: .app,
            bundleId: "com.browser.app",
            deploymentTargets: .macOS("14.0"),
            infoPlist: .file(path: "Browser/Info.plist"),
            sources: ["Browser/**/*.swift"],
            dependencies: [
                .sdk(name: "AppKit", type: .framework),
                .sdk(name: "WebKit", type: .framework),
                .external(name: "ComposableArchitecture"),
            ],
            settings: .settings(
                base: [
                    "CODE_SIGN_ENTITLEMENTS": "Browser/Browser.entitlements",
                    "ENABLE_PREVIEWS": "YES",
                    "SWIFT_VERSION": "5.0",
                ]
            )
        ),
    ]
)
