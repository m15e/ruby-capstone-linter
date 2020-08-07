#!/usr/bin/env ruby

# get input

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

p files
