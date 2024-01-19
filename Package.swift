// swift-tools-version:5.4
// The swift-tools-version declares the minimum version of Swift required to build this package.

import Foundation
import PackageDescription

private func files(withExtension ext: Set<String>, anchor: String = #file) -> [String] {
    let baseURL = URL(fileURLWithPath: anchor)
        .deletingLastPathComponent()

    let allFiles = FileManager.default
        .enumerator(atPath: baseURL.path)?
        .allObjects ?? []

    return allFiles
        .compactMap { $0 as? String }
        .map { URL(fileURLWithPath: $0) }
        .filter { ext.contains($0.pathExtension) || ext.contains($0.lastPathComponent) }
        .map { $0.relativePath }
}

let package = Package(
    name: "etpan",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v10_12),
        .iOS(.v10)
    ],
    products: [
        .library(name: "iconv", type: .static, targets: ["iconv"]),
        .library(name: "sasl2", type: .static, targets: ["sasl2"]),
        .library(name: "etpan", type: .static, targets: ["etpan"]),
        .executable(name: "imap-sample", targets: ["imap-sample"]),
        .executable(name: "mime-parse", targets: ["mime-parse"]),
        .executable(name: "mime-create", targets: ["mime-create"]),
        .executable(name: "compose-msg", targets: ["compose-msg"]),
        .executable(name: "frm", targets: ["frm"]),
        .executable(name: "frm-simple", targets: ["frm-simple"]),
        .executable(name: "frm-tree", targets: ["frm-tree"]),
        .executable(name: "fetch-attachment", targets: ["fetch-attachment"]),
        .executable(name: "readmsg", targets: ["readmsg"]),
        .executable(name: "readmsg-simple", targets: ["readmsg-simple"]),
    ],
    dependencies: [
        .package(url: "https://github.com/krzyzanowskim/OpenSSL.git", .exact("1.1.2200"))
    ],
    targets: [
        .target(
            name: "iconv",
            path: "dependencies/iconv",
            sources: [
                "libiconv/libcharset/lib/localcharset.c",
                "libiconv/lib/iconv.c",
                "libiconv/lib/relocatable.c"
            ],
            cSettings: [
                .headerSearchPath("libiconv/libcharset"),
                .headerSearchPath("libiconv/libcharset/include"),
                .headerSearchPath("libiconv/srclib"),
                .headerSearchPath("libiconv/lib"),
                .headerSearchPath("config/macos", .when(platforms: [.iOS])),
                .headerSearchPath("config/ios", .when(platforms: [.macOS])),
                .headerSearchPath("config/android", .when(platforms: [.android])),
                .define("ANDROID", .when(platforms: [.android])),
                .define("LIBDIR", to: "\"\""),
                .define("BUILDING_LIBICONV"),
                .define("IN_LIBRARY"),
                .unsafeFlags([
                    "-Wno-parentheses-equality",
                ])
            ]
        ),
        .target(
            name: "sasl2",
            dependencies: [
                .product(name: "OpenSSL", package: "OpenSSL", condition: .when(platforms: [.iOS, .macOS])),
            ],
            path: "dependencies/sasl2",
            sources: [
                "cyrus-sasl/common/crypto-compat.c",
                "cyrus-sasl/common/plugin_common.c",
                "cyrus-sasl/lib/auxprop.c",
                "cyrus-sasl/lib/canonusr.c",
                "cyrus-sasl/lib/checkpw.c",
                "cyrus-sasl/lib/client.c",
                "cyrus-sasl/lib/common.c",
                "cyrus-sasl/lib/config.c",
                "cyrus-sasl/lib/dlopen.c",
                "cyrus-sasl/lib/external.c",
                "cyrus-sasl/lib/getsubopt.c",
                "cyrus-sasl/lib/md5.c",
                "cyrus-sasl/lib/saslutil.c",
                "cyrus-sasl/lib/server.c",
                "cyrus-sasl/lib/seterror.c",
                "cyrus-sasl/lib/snprintf.c",
                "cyrus-sasl/plugins/anonymous.c",
                "cyrus-sasl/plugins/cram.c",
                "cyrus-sasl/plugins/digestmd5.c",
                "cyrus-sasl/plugins/login.c",
                "cyrus-sasl/plugins/ntlm.c",
                "cyrus-sasl/plugins/otp.c",
                "cyrus-sasl/plugins/passdss.c",
                "cyrus-sasl/plugins/plain.c",
                "cyrus-sasl/plugins/scram.c",
                "cyrus-sasl/plugins/srp.c"
            ],
            cSettings: [
                .headerSearchPath("cyrus-sasl/include"),
                .headerSearchPath("cyrus-sasl/common"),
                .headerSearchPath("cyrus-sasl/plugins"),
                .headerSearchPath("config/macos", .when(platforms: [.macOS])),
                .headerSearchPath("config/ios", .when(platforms: [.iOS])),
                .headerSearchPath("config/android", .when(platforms: [.android])),
                .headerSearchPath("include/sasl"),
                .define("GCC_FALLTHROUGH", to: "/* fall through */"),
                .define("PLUGINDIR", to: "\"/usr/lib/sasl2\""),
                .define("CONFIGDIR", to: "\"/usr/lib/sasl2:/etc/sasl2\""),
                .unsafeFlags([
                    "-Wno-parentheses-equality"
                ]),
            ]
        ),
        .target(
            name: "etpan",
            dependencies: [
                .product(name: "OpenSSL", package: "OpenSSL", condition: .when(platforms: [.iOS, .macOS])),
                .target(name: "sasl2"),
                .target(name: "iconv"),
            ],
            path: ".",
            exclude: ["src/windows", "src/bsd"] + files(withExtension: ["in", "rc", "am", "Makefile", "TODO"]),
            sources: ["src"],
            cSettings: [
                .headerSearchPath("config/macos", .when(platforms: [.macOS])),
                .headerSearchPath("config/ios", .when(platforms: [.iOS])),
                .headerSearchPath("config/android", .when(platforms: [.android])),
                .headerSearchPath("dependencies/include/iconv"),
                .headerSearchPath("include/libetpan"),
                .headerSearchPath("src"),
                .headerSearchPath("src/data-types"),
                .headerSearchPath("src/low-level"),
                .headerSearchPath("src/low-level/imap"),
                .headerSearchPath("src/low-level/imf"),
                .headerSearchPath("src/low-level/mime"),
                .headerSearchPath("src/low-level/nntp"),
                .headerSearchPath("src/low-level/pop3"),
                .headerSearchPath("src/low-level/smtp"),
                .headerSearchPath("src/main"),
                .headerSearchPath("src/driver/implementation/data-message"),
                .headerSearchPath("src/driver/implementation/feed"),
                .headerSearchPath("src/driver/implementation/imap"),
                .headerSearchPath("src/driver/implementation/db"),
                .headerSearchPath("src/driver/implementation/maildir"),
                .headerSearchPath("src/driver/implementation/mbox"),
                .headerSearchPath("src/driver/implementation/mh"),
                .headerSearchPath("src/driver/implementation/mime-message"),
                .headerSearchPath("src/driver/implementation/nntp"),
                .headerSearchPath("src/driver/implementation/pop3"),
                .headerSearchPath("src/driver/interface"),
                .headerSearchPath("src/driver/tools"),
                .define("HAVE_ICONV", to: "1"),
                .define("HAVE_CONFIG_H", to: "1")
            ],
            linkerSettings: [
                // We use system (aka toolchain) OpenSSL on Android, that's why we add linking here
                .linkedLibrary("crypto", .when(platforms: [.android])),
                .linkedLibrary("ssl", .when(platforms: [.android])),
                .linkedLibrary("z"),
            ]
        ),
        .target(name: "option-parser", dependencies: ["etpan"], path: "tests", sources: ["option-parser.c"]),
        .target(name: "frm-common", dependencies: ["etpan"], path: "tests", sources: ["frm-common.c"]),
        .target(name: "readmsg-common", dependencies: ["etpan"], path: "tests", sources: ["readmsg-common.c"]),
        .executableTarget(name: "imap-sample", dependencies: ["etpan"], path: "tests", sources: ["imap-sample.c"]),
        .executableTarget(name: "mime-parse", dependencies: ["etpan"], path: "tests", sources: ["mime-parse.c"]),
        .executableTarget(name: "mime-create", dependencies: ["etpan"], path: "tests", sources: ["mime-create.c"]),
        .executableTarget(name: "compose-msg", dependencies: ["etpan"], path: "tests", sources: ["compose-msg.c"]),
        .executableTarget(name: "frm", dependencies: ["etpan", "option-parser", "frm-common"], path: "tests", sources: ["frm.c"]),
        .executableTarget(name: "frm-simple", dependencies: ["etpan", "option-parser", "frm-common"], path: "tests", sources: ["frm-simple.c"]),
        .executableTarget(name: "frm-tree", dependencies: ["etpan", "option-parser", "frm-common"], path: "tests", sources: ["frm-tree.c"]),
        .executableTarget(name: "fetch-attachment", dependencies: ["etpan", "option-parser", "readmsg-common"], path: "tests", sources: ["fetch-attachment.c"]),
        .executableTarget(name: "readmsg", dependencies: ["etpan", "option-parser", "readmsg-common"], path: "tests", sources: ["readmsg.c"]),
        .executableTarget(name: "readmsg-simple", dependencies: ["etpan", "option-parser", "readmsg-common"], path: "tests", sources: ["readmsg-simple.c"])
    ]
)
