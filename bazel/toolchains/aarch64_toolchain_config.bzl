load("@bazel_tools//tools/build_defs/cc:action_names.bzl", "ACTION_NAMES")
load("@bazel_tools//tools/cpp:cc_toolchain_config_lib.bzl", "feature", "flag_group", "flag_set", "tool_path", "with_feature_set")

all_compile_actions = [
    ACTION_NAMES.c_compile,
    ACTION_NAMES.cpp_compile,
    ACTION_NAMES.linkstamp_compile,
    ACTION_NAMES.cc_flags_make_variable,
    ACTION_NAMES.cpp_module_codegen,
    ACTION_NAMES.cpp_header_parsing,
    ACTION_NAMES.cpp_module_compile,
]

all_link_actions = [
    ACTION_NAMES.cpp_link_executable,
    ACTION_NAMES.cpp_link_dynamic_library,
    ACTION_NAMES.cpp_link_nodeps_dynamic_library,
    ACTION_NAMES.lto_index_for_dynamic_library,
    ACTION_NAMES.lto_index_for_nodeps_dynamic_library,
    ACTION_NAMES.lto_index_for_executable,
]

def _impl(ctx):
    tool_paths = [
        tool_path(
            name = "gcc",
            path = "/usr/bin/aarch64-linux-gnu-gcc",
        ),
        tool_path(
            name = "g++",
            path = "/usr/bin/aarch64-linux-gnu-g++",
        ),
        tool_path(
            name = "ld",
            path = "/usr/bin/aarch64-linux-gnu-ld",
        ),
        tool_path(
            name = "ar",
            path = "/usr/bin/aarch64-linux-gnu-ar",
        ),
        tool_path(
            name = "cpp",
            path = "/usr/bin/aarch64-linux-gnu-cpp",
        ),
        tool_path(
            name = "gcov",
            path = "/usr/bin/aarch64-linux-gnu-gcov",
        ),
        tool_path(
            name = "nm",
            path = "/usr/bin/aarch64-linux-gnu-nm",
        ),
        tool_path(
            name = "objdump",
            path = "/usr/bin/aarch64-linux-gnu-objdump",
        ),
        tool_path(
            name = "strip",
            path = "/usr/bin/aarch64-linux-gnu-strip",
        ),
    ]

    features = [
        feature(
            name = "default_compiler_flags",
            enabled = True,
            flag_sets = [
                flag_set(
                    actions = all_compile_actions,
                    flag_groups = [
                        flag_group(
                            flags = [
                                "--sysroot=/usr/aarch64-linux-gnu",
                                "-no-canonical-prefixes",
                                "-fno-canonical-system-headers",
                            ],
                        ),
                    ],
                ),
            ],
        ),
        feature(
            name = "default_linker_flags",
            enabled = True,
            flag_sets = [
                flag_set(
                    actions = all_link_actions,
                    flag_groups = [
                        flag_group(
                            flags = [
                                "-pipe",
                                "-Wl,-no-as-needed",
                                "-Wl,-z,relro,-z,now",
                                "-lstdc++",
                                "-lm",
                                "-L/usr/aarch64-linux-gnu/lib",
                                "-L/usr/lib/gcc-cross/aarch64-linux-gnu/13",

                                #    "-nodefaultlibs",
                                "-lc",
                                "-lgcc_s",
                                "-lgcc",
                                "-ldl",
                            ],
                        ),
                    ],
                ),
                flag_set(
                    actions = all_link_actions,
                    flag_groups = [flag_group(flags = ["-Wl,--gc-sections"])],
                    with_features = [with_feature_set(features = ["opt"])],
                ),
            ],
        ),
        feature(
            name = "supports_dynamic_linker",
            enabled = True,
        ),
        feature(
            name = "supports_shared_libraries",
            enabled = True,
        ),
        feature(name = "legacy_link_flags", enabled = False),
        feature(name = "legacy_compile_flags", enabled = False),
        feature(name = "supports_pic", enabled = True),
        feature(name = "supports_start_end_lib", enabled = False),
        feature(
            name = "library_search_directories",
            enabled = True,
            flag_sets = [
                flag_set(
                    actions = all_link_actions,
                    flag_groups = [
                        flag_group(
                            expand_if_available = "library_search_directories",
                            iterate_over = "library_search_directories",
                            flags = ["-L%{library_search_directories}"],
                        ),
                    ],
                ),
            ],
        ),
        feature(
            name = "user_link_flags",
            enabled = True,
            flag_sets = [
                flag_set(
                    actions = all_link_actions,
                    flag_groups = [
                        flag_group(
                            expand_if_available = "user_link_flags",
                            iterate_over = "user_link_flags",
                            flags = ["%{user_link_flags}"],
                        ),
                    ],
                ),
            ],
        ),
        feature(
            name = "link_shared",
            enabled = True,
            flag_sets = [
                flag_set(
                    actions = [
                        ACTION_NAMES.cpp_link_dynamic_library,
                        ACTION_NAMES.cpp_link_nodeps_dynamic_library,
                    ],
                    flag_groups = [
                        flag_group(
                            flags = ["-shared"],
                        ),
                    ],
                ),
            ],
        ),
    ]

    return cc_common.create_cc_toolchain_config_info(
        ctx = ctx,
        features = features,
        cxx_builtin_include_directories = [
            "/usr/aarch64-linux-gnu/include",
            "/usr/aarch64-linux-gnu/usr/include",
            "/usr/lib/gcc-cross/aarch64-linux-gnu/11/include",
            "/usr/lib/gcc-cross/aarch64-linux-gnu/11/include-fixed",
            "/usr/lib/gcc-cross/aarch64-linux-gnu/13/include",
            "/usr/lib/gcc-cross/aarch64-linux-gnu/13/include-fixed",
        ],
        builtin_sysroot = "/",
        toolchain_identifier = "linux_aarch64-toolchain",
        host_system_name = "local",
        target_system_name = "aarch64-linux-gnu",
        target_cpu = "aarch64",
        target_libc = "glibc",
        compiler = "gcc",
        abi_version = "unknown",
        abi_libc_version = "unknown",
        tool_paths = tool_paths,
    )

cc_toolchain_config = rule(
    implementation = _impl,
    attrs = {},
    provides = [CcToolchainConfigInfo],
)
