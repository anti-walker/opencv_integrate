workspace(name = "opencv_bazel_test")

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

# rules_foreign_cc (兼容 Bazel 5.3.2 的最新稳定版)
http_archive(
    name = "rules_foreign_cc",
    sha256 = "2a4d07cd64b0719b39a7c12218a3e507672b82a97b98c6a89d38565894cf7c51",
    strip_prefix = "rules_foreign_cc-0.9.0",
    url = "https://github.com/bazelbuild/rules_foreign_cc/archive/0.9.0.tar.gz",
)

load("@rules_foreign_cc//foreign_cc:repositories.bzl", "rules_foreign_cc_dependencies")

rules_foreign_cc_dependencies()

# OpenCV 4.10.0 源码
_OPENCV_BUILD_FILE = """
filegroup(
    name = "all_srcs",
    srcs = glob(["**"]),
    visibility = ["//visibility:public"],
)
"""

http_archive(
    name = "opencv_src",
    build_file_content = _OPENCV_BUILD_FILE,
    sha256 = "b2171af5be6b26f7a06b1229948bbb2bdaa74fcf5cd097e0af6378fce50a6eb9",
    strip_prefix = "opencv-4.10.0",
    urls = ["http://127.0.0.1:8000/opencv-4.10.0.tar.gz"],
)
