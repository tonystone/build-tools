#!/usr/bin/env ruby
#
#   gyb_tool.rb
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
#   Created by Tony Stone on 10/12/17.
#
require 'getoptlong'
require 'fileutils'
require 'pathname'

include FileUtils

def usage()
  string = <<USAGE
Usage:
   <FileName> [--recursive] [--gyb-path Path] [--input-path path] [--output-path path]

Options:
  --recursive   Process the --input-path recursively (default is non-recursive)
  --gyb-path Path to the gyb program (defaults to using the search path)
  --input-path  Path to directory containing the gyb files (defaults to the current directory if not specified)
  --output-path Path to place processed file (files will be placed in the same directory they are found if not specified)
USAGE

  string.sub! "<FileName>", File.basename(__FILE__)
  puts string
end

#
# Main routine
#
#
input_path="./"
output_path=nil
gyb_path=nil
recursive=false

options = GetoptLong.new(
    [ '--recursive',    GetoptLong::NO_ARGUMENT],
    [ '--input-path',   GetoptLong::REQUIRED_ARGUMENT ],
    [ '--output-path',  GetoptLong::REQUIRED_ARGUMENT ],
    [ '--gyb-path',     GetoptLong::REQUIRED_ARGUMENT ],
    [ '--help',         GetoptLong::NO_ARGUMENT ]
)
options.quiet = true

begin
  options.each do |option, value|
    if    option == '--recursive'   then recursive=true
    elsif option == '--input-path'  then input_path=value.dup
    elsif option == '--output-path' then output_path=value.dup
    elsif option == '--gyb-path'    then gyb_path=value.dup
    elsif option == '--help'        then usage; abort
    end
  end
rescue GetoptLong::InvalidOption
  usage
  abort
end

#
# Setup paths and validate that we can proceed.
#
search_path =  File.expand_path(input_path)
if recursive
  search_path = File.join(search_path, "/**/*.gyb")
else
  search_path = File.join(search_path, "/*.gyb")
end

if gyb_path
  gyb = File.join(gyb_path, "gyb")
else
  gyb = `which gyb`
end

unless File.file? gyb
  puts "gyb not found in path, cannot continue"
  abort
end

if output_path
  unless File.directory?(output_path)
    FileUtils.mkdir_p(output_path)
  end
end

#
# Find all gyb files and process them one at a time
#
Dir[search_path].each { |input_file|

  if File.file? input_file
    if output_path
      output_file = File.join(output_path, File.basename(input_file, ".*"))
    else
      output_file = Pathname(input_file).sub_ext ''
    end

    output_file = File.expand_path(output_file)

    puts 'Processing input file: ' + input_file
    puts 'Output File: ' + output_file.to_s

    #
    # Run gyb and process the files
    #
    unless system("#{gyb} --line-directive '' -o '#{output_file}' '#{input_file}'")
      puts "Failed to process file '#{input_file}', error #{$?}"
    end

  end
}