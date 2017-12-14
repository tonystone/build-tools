cmake_minimum_required(VERSION 3.9)

project(build-tools LANGUAGES NONE)

#
# Build tool paths.
#
set(BUILD_DIR .build)
set(GYB_WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}/${BUILD_DIR}/build-gyb)

#
# Since we are downloading gyb using a custom command, we need to generate the download directory.
#
add_custom_command(
        OUTPUT ${GYB_WORKING_DIRECTORY}
        COMMAND ${CMAKE_COMMAND} -E make_directory ${GYB_WORKING_DIRECTORY}
)

#
# GYB
#
add_custom_command(
        OUTPUT gyb.py
        COMMAND wget
        ARGS --quiet https://github.com/apple/swift/raw/master/utils/gyb.py
        WORKING_DIRECTORY ${GYB_WORKING_DIRECTORY}
        DEPENDS ${GYB_WORKING_DIRECTORY}
)

add_custom_command(
        OUTPUT gyb
        COMMAND wget
        ARGS --quiet https://github.com/apple/swift/raw/master/utils/gyb
        WORKING_DIRECTORY ${GYB_WORKING_DIRECTORY}
        DEPENDS gyb.py ${GYB_WORKING_DIRECTORY}
)

add_custom_target(gyb-tool ALL
        DEPENDS gyb.py gyb
        )

#
# Installation section
#
install(
        PROGRAMS ${GYB_WORKING_DIRECTORY}/gyb ${GYB_WORKING_DIRECTORY}/gyb.py
        DESTINATION build-tools/bin
)
install(
        PROGRAMS source/generate_xctest_runner.rb source/process_gyb.rb
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
