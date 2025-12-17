def to_snake_case(not_snake_case):
    """ Converts camel-case to snake-case.

    Based on convert_camel_case_to_lower_case_underscore from rosidl_cmake.
    Unfortunately regex doesn't exist in Bazel.

    Args:
      not_snake_case: a camel-case string.
    Returns:
      A snake-case string.
    """
    result = ""
    not_snake_case_padded = " " + not_snake_case + " "
    for i in range(len(not_snake_case)):
        prev_char, char, next_char = not_snake_case_padded[i:i + 3].elems()
        if char.isupper() and next_char.islower() and prev_char != " ":
            # Insert an underscore before any upper case letter which is not
            # followed by another upper case letter.
            result += "_"
        elif char.isupper() and (prev_char.islower() or prev_char.isdigit()):
            # Insert an underscore before any upper case letter which is
            # preseded by a lower case letter or number.
            result += "_"
        result += char.lower()

    return result

middleware_cpp_deps = select({
    "//bazel/platforms:config_ros2": ["//third_party/ros2:rclcpp"],
    "//conditions:default": [],
})

middleware_copts = select({
    "//bazel/platforms:config_ros2": ["-std=c++17"],
    "//bazel/platforms:config_aas": ["-std=c++17"],
    "//conditions:default": ["-std=c++14"],
})

geometry_msgs_deps = select(
    {
        "//bazel/platforms:config_ros2": [
            "//third_party/ros2:geometry_msgs_interface_cc",
            "//third_party/ros2:nav_msgs_interface_cc",
            "//third_party/ros2:shape_msgs_interface_cc",
            "//third_party/ros2:std_msgs_interface_cc",
        ],
        "//conditions:default": [
        ],
    },
    no_match_error = "No known platform specified.",
)

visualization_msgs_deps = select(
    {
        "//bazel/platforms:config_ros2": [
            "@ros2_galactic_common_interfaces//:visualization_msgs_interface_cc",
            "//third_party/ros2:sensor_msgs_interface_cc",
        ],
        "//conditions:default": [
        ],
    },
    no_match_error = "No known platform specified.",
)

middleware_pub_sub_deps = select({
    "//bazel/platforms:config_ros2": ["//platform/ros/galactic/subscriber_publisher:ros2_pub_sub_creator_impl"],
    "//conditions:default": ["//platform/aas/communication/subscriber_publisher:aas_pub_sub_creator_impl"],
})
