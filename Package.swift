// swift-tools-version:5.4
// The swift-tools-version declares the minimum version of Swift required to build this package.

import Foundation
import PackageDescription

var products: [Product] = [
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
]

var etpanDependencies: [Target.Dependency] = [
    .product(name: "OpenSSL", package: "OpenSSL", condition: .when(platforms: [.iOS, .macOS])),
    .target(name: "sasl2", condition: .when(platforms: [.android, .iOS])),
]

var targets: [Target] = [
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
        dependencies: etpanDependencies,
        path: ".",
        exclude: [
            "src/windows",
            "src/bsd",
            "src/low-level/imap/TODO",
            "src/low-level/imap/Makefile.am",
            "src/low-level/mh/Makefile.am",
            "src/low-level/mbox/TODO",
            "src/low-level/mbox/Makefile.am",
            "src/low-level/Makefile.am",
            "src/low-level/imf/TODO",
            "src/low-level/imf/Makefile.am",
            "src/low-level/feed/Makefile.am",
            "src/low-level/smtp/TODO",
            "src/low-level/smtp/Makefile.am",
            "src/low-level/pop3/Makefile.am",
            "src/low-level/mime/TODO",
            "src/low-level/mime/Makefile.am",
            "src/low-level/maildir/Makefile.am",
            "src/low-level/nntp/Makefile.am",
            "src/data-types/Makefile.am",
            "src/driver/interface/Makefile.am",
            "src/driver/tools/Makefile.am",
            "src/driver/TODO",
            "src/driver/Makefile.am",
            "src/driver/implementation/data-message/Makefile.am",
            "src/driver/implementation/imap/Makefile.am",
            "src/driver/implementation/mh/Makefile.am",
            "src/driver/implementation/mbox/Makefile.am",
            "src/driver/implementation/Makefile.am",
            "src/driver/implementation/feed/Makefile.am",
            "src/driver/implementation/pop3/Makefile.am",
            "src/driver/implementation/db/Makefile.am",
            "src/driver/implementation/maildir/Makefile.am",
            "src/driver/implementation/nntp/Makefile.am",
            "src/driver/implementation/hotmail/Makefile.am",
            "src/driver/implementation/mime-message/Makefile.am",
            "src/versioninfo.rc.in",
            "src/Makefile.am",
            "src/main/libetpan_version.h.in",
            "src/main/Makefile.am",
            "src/engine/Makefile.am",
        ],
        sources: ["src"],
        cSettings: [
            .headerSearchPath("config/macos", .when(platforms: [.macOS])),
            .headerSearchPath("config/ios", .when(platforms: [.iOS])),
            .headerSearchPath("config/android", .when(platforms: [.android])),
            .headerSearchPath("dependencies/include/iconv", .when(platforms: [.android])),
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
            .define("HAVE_ICONV", to: "1", .when(platforms: [.iOS, .macOS])),
            .define("HAVE_CONFIG_H", to: "1")
        ],
        linkerSettings: [
            // We use system (aka toolchain) OpenSSL on Android, that's why we add linking here
            .linkedLibrary("crypto", .when(platforms: [.android])),
            .linkedLibrary("ssl", .when(platforms: [.android])),
            .linkedLibrary("z"),
            .linkedLibrary("iconv", .when(platforms: [.iOS, .macOS])),
            .linkedLibrary("sasl2", .when(platforms: [.macOS])),
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
    .executableTarget(name: "readmsg-simple", dependencies: ["etpan", "option-parser", "readmsg-common"], path: "tests", sources: ["readmsg-simple.c"]),
]

#if TARGET_ANDROID
targets += [
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
]

packages += [
    .library(name: "iconv", type: .static, targets: ["iconv"]),
]

etpanDependencies += [
    .target(name: "iconv", condition: .when(platforms: [.android])),
]
#endif

let package = Package(
    name: "etpan",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v10_12),
        .iOS(.v10)
    ],
    products: products,
    dependencies: [
        .package(url: "https://github.com/krzyzanowskim/OpenSSL.git", .exact("1.1.2200"))
    ],
    targets: targets
)
