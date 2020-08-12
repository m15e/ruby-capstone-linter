#!/usr/bin/env ruby
require 'rainbow' # docs https://www.rubydoc.info/gems/rainbow/3.0.0
require_relative '../lib/lint.rb'

# get input files

in_args = ARGV

files = Dir.glob('**/**.css')  

if files.empty?
  puts 'File ending with .css does not exist in this project.'
  exit
end

if in_args[0] == 'ignore'
  scrap = in_args.select { |file_name| file_name.end_with?('.css')  }
  scrap.each { |file| files.delete(file)  }
end


for file in files
  puts Rainbow(file).underline.bright  
  lint = Lint.new(file)  
  puts "total lines: #{lint.instance_variable_get(:@file_hash)[:line_count]+1}"
  lint.instance_variable_get(:@file_hash)[:errors].each { |err| puts "#{err[0]}" + Rainbow("✖").red + "#{err[1]}" }
  puts "\n"
end
