load(":aarch64_toolchain_config.bzl", "cc_toolchain_config")

package(default_visibility = ["//visibility:public"])

cc_toolchain_config(name = "linux_aarch64_toolchain_config")

filegroup(name = "empty")

cc_toolchain(
    name = "linux_aarch64_toolchain",
    all_files = ":empty",
    compiler_files = ":empty",
    dwp_files = ":empty",
    linker_files = ":empty",
    objcopy_files = ":empty",
    strip_files = ":empty",
    supports_param_files = 0,
    toolchain_config = ":linux_aarch64_toolchain_config",
    toolchain_identifier = "linux_aarch64-toolchain",
)

toolchain(
    name = "cc_toolchain_for_linux_aarch64",
    # Removed exec_compatible_with so this toolchain is usable from any execution
    # platform. Keep target_compatible_with to indicate it's for arm64 targets.
    target_compatible_with = [
        "@platforms//cpu:arm64",
        "@platforms//os:linux",
    ],
    toolchain = ":linux_aarch64_toolchain",
    toolchain_type = "@bazel_tools//tools/cpp:toolchain_type",
)