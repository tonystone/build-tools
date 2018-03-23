#!/usr/bin/env ruby
#
#   xcworkspace_tool.rb
#
#   Copyright 2018 Tony Stone
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
#   Created by Tony Stone on 03/22/18.
#
require 'fileutils'
require 'pathname'
require 'xcodeproj'

input_array = ARGV

unless input_array.length > 0
  puts "invalid number of arguments."
  puts ""
  puts "Usage:\n\txcworkspace_tool workspace_name [*file_to_add]"
  abort
end

output_path = Pathname.new(File.extname(input_array[0]).size > 0 ? input_array[0] : input_array[0] + ".xcworkspace")
output_dir  = Pathname.new(File.realdirpath(output_path.to_s)).parent

puts output_dir

#
# Use the remainder of the files as additions to the workspace
#
workspace_files = input_array[1..-1].map { |file|
   path = Pathname.new(File.realpath(file))

  raise "File does not exist" unless path.exist?

  if path.directory?
     if [".xcodeproj", ".playground"].include?(File.extname(file))
        Xcodeproj::Workspace::FileReference.new(path.relative_path_from(output_dir), 'container')
     else
        Xcodeproj::Workspace::FileReference.new(path.relative_path_from(output_dir), 'group')
     end
  else
      Xcodeproj::Workspace::FileReference.new(path.relative_path_from(output_dir), 'absolute')
  end
}

workspace = Xcodeproj::Workspace.new(nil)

workspace_files.each { |file| workspace << file }

workspace.save_as(output_path)

puts "Xcode workspace #{output_path} created for #{workspace_files}"


