#!/usr/bin/env ruby
#
#   generate_xctest_runner.rb
#
#   Copyright 2017 Tony Stone
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#
#   Created by Tony Stone on 10/2/17.
#
require 'getoptlong'
require 'fileutils'
require 'pathname'
require "rubygems"
require "json"

include FileUtils

def usage()
  string = <<USAGE
Usage:
   <FileName> [--package-path path]

Options:
  --package-path  Path to directory containing Package.swift
USAGE

  string.sub! "<FileName>", File.basename(__FILE__)
  puts string
end

#
# Main routine
#
#
package_path="./"

options = GetoptLong.new(
    [ '--package-path', GetoptLong::REQUIRED_ARGUMENT ],
    [ '--help', GetoptLong::NO_ARGUMENT ]
)
options.quiet = true

begin
    options.each do |option, value|
        if    option == '--package-path' then package_path=value.dup
        elsif option == '--help' then usage(); abort
        end
    end
rescue GetoptLong::InvalidOption
    usage()
    abort
end

package_path = File.expand_path(package_path)
default_tests_directory = defaultTestsDirectory(package_path)

unless File.file?(File.join(package_path, "Package.swift"))
  abort("Package.swift file not found at '#{package_path}', aborting.")
end

#
# Parse the output of swift package dump-package which outputs the Package file in JSON format.
#
package = JSON.parse(`swift package --package-path #{package_path} dump-package`)

# Extract the test targets
test_targets = package["targets"].select { |t| t["isTest"] }

classes = Array.new
module_names = Array.new

#
# Process each test target in turn
#
test_targets.each do |target|
    module_name = target["name"]

    target_path = target["path"] || File.join(default_tests_directory, module_name)

    module_names << module_name
    classes = classes + processTestFiles(module_name, File.join(package_path, target_path))
end

#
# If its the root level and there are classes, create the LinuxMain file
#
if classes.count > 0
  createLinuxMain module_names, classes, File.join(package_path, default_tests_directory)
end

BEGIN {

    #
    # Return the tests directory name the user is using or default to Tests
    #
    def defaultTestsDirectory(package_path)

      if File.directory?(package_path + "Test")
        return "Test"
      else
        return "Tests"
      end
    end

    def createExtensionFile(file_name, classes)

        extension_file = file_name.sub! ".swift", "+XCTest.swift"
        print "Creating file: " + extension_file + "\n"

        File.open(extension_file, 'w') { |file|

            file.write header(extension_file)
            file.write "\n"

            for classArray in classes
                file.write "extension " + classArray[0] + " {\n\n"
                file.write "   static var allTests: [(String, (" + classArray[0] + ") -> () throws -> Void)] {\n"
                file.write "      return [\n"

                first = true

                for funcName in classArray[1]
                    if !first
                        file.write ",\n"
                    end
                    file.write "                (\"" + funcName + "\", " + funcName + ")"

                    first = false
                end

                file.write "\n           ]\n"
                file.write "   }\n"
                file.write "}\n"
            end
        }
    end

    def createLinuxMain(module_names, file_classes, path)

        file_name = path + "/LinuxMain.swift"
        print "Creating file: " + file_name + "\n"

        File.open(file_name, 'w') { |file|

            file.write header(file_name)
            file.write "\n"

            file.write "#if os(Linux) || os(FreeBSD)\n"

            module_names.each do |module_name|
              file.write "   @testable import " + module_name + "\n"
            end
            file.write "\n"
            file.write "   XCTMain([\n"

            first = true

            for classes in file_classes
                for classArray in classes
                    if !first
                        file.write ",\n"
                    end
                    file.write "         testCase(" + classArray[0] + ".allTests)"
                    first = false
                end
            end
            file.write"\n    ])\n"
            file.write "#endif\n"
        }
    end

    #
    # Process the source file returning a list of classes in the source
    #
    # Classes structure:
    #
    #   className -> Array of func names
    #
    def parseSourceFile(file_name)

        puts "Parsing file:  " + file_name + "\n"

        classes = Array.new

        current_class = nil

        in_if_linux = false
        in_else    = false
        ignore    = false

        #
        # Read the file line by line
        # and parse to find the class
        # names and func names
        #
        File.readlines(file_name).each do |line|

            if in_if_linux
                if /\#else/.match(line)
                    in_else = true
                    ignore = true
                else
                    if /\#end/.match(line)
                        in_else = false
                        in_if_linux = false
                        ignore = false
                    end
                end
            else
                if /\#if[ \t]+os\(Linux\)/.match(line)
                    in_if_linux = true
                    ignore = false
                end
            end

            if !ignore

                # Match class or func
                match = line[/class[ \t]+[a-zA-Z0-9_]*(?=[ \t]*:[ \t]*XCTestCase)|func[ \t]+test[a-zA-Z0-9_]*(?=[ \t]*\(\))/, 0]
                if match

                    if match[/class/, 0] == "class"
                        class_name = match.sub(/^class[ \t]+/, '')
                        #
                        # Create a new class / func structure
                        # and add it to the classes array.
                        #
                        current_class = [class_name, Array.new]

                        classes << current_class

                    else # Must be a func
                        func_name  = match.sub(/^func[ \t]+/, '')
                        #
                        # Add each func name the the class / func
                        # structure created above.
                        #
                        current_class[1] << func_name
                    end
                end
            end
        end
        return classes
    end

    def processTestFiles(module_name, path)

        classes = Array.new

        Dir[path + '/*Test{s,}.swift'].each do |file_name|

            if File.file? file_name

                file_classes = parseSourceFile(file_name)

                #
                # If there are classes in the
                # test source file, create an extension
                # file for it.
                #
                if file_classes.count > 0
                    createExtensionFile(file_name, file_classes)

                    classes << file_classes
                end
            end
        end

        #
        # Now process the sub directories
        #
        Dir[path + '/*'].each do |sub_directory|

          if File.directory?(sub_directory)
            sub_classes = processTestFiles(module_name, sub_directory)

            # Aggregate the files and classes
            classes = classes + sub_classes
          end
        end

        return classes
    end

    def header(file_name)
      string = <<-eos
///
/// <TargetFile>
///
/// Copyright <Year> Tony Stone
///
///  Licensed under the Apache License, Version 2.0 (the "License");
///  you may not use this file except in compliance with the License.
///  You may obtain a copy of the License at
///
///  http://www.apache.org/licenses/LICENSE-2.0
///
///  Unless required by applicable law or agreed to in writing, software
///  distributed under the License is distributed on an "AS IS" BASIS,
///  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
///  See the License for the specific language governing permissions and
///  limitations under the License.
///
///  Created by Tony Stone on <Date>.
///
import XCTest

///
/// NOTE: This file was auto generated by file <ScriptFile>.
///
/// Do NOT edit this file directly as it will be regenerated automatically when needed.
///
      eos

      string.sub! "<ScriptFile>", File.basename(__FILE__)
      string.sub! "<TargetFile>", File.basename(file_name)
      string.sub! "<Year>", Time.now.strftime("%Y")
      string.sub! "<Date>", Time.now.strftime("%m/%d/%Y")
    end
}
