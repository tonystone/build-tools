cmake_minimum_required(VERSION 3.9)

project(build-tools LANGUAGES NONE)

#
# Paths.
#
set(WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR})

#
# GYB
#
add_custom_command(
        OUTPUT gyb.py
        COMMAND wget
        ARGS --quiet https://raw.githubusercontent.com/apple/swift/main/utils/gyb.py
        WORKING_DIRECTORY ${WORKING_DIRECTORY}
)

add_custom_command(
        OUTPUT gyb
        COMMAND wget
        ARGS --quiet https://raw.githubusercontent.com/apple/swift/main/utils/gyb
        WORKING_DIRECTORY ${WORKING_DIRECTORY}
        DEPENDS gyb.py
)

add_custom_target(gyb-tool ALL
        DEPENDS gyb.py gyb
        )

#
# Installation section
#
install(
        PROGRAMS ${WORKING_DIRECTORY}/gyb ${WORKING_DIRECTORY}/gyb.py
        DESTINATION build-tools/bin
)
install(
        PROGRAMS source/xctest_tool.rb source/gyb_tool.rb source/xcworkspace_tool.rb
        DESTINATION build-tools/bin
)
install(
        FILES README.md LICENSE
        DESTINATION build-tools
)
install(
        DIRECTORY documentation/
        DESTINATION build-tools/documentation
)
