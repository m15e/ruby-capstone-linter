#!/usr/bin/env ruby
require 'rainbow' # docs https://www.rubydoc.info/gems/rainbow/3.0.0

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

# p files

# loop through files - after open
for file in files
  puts Rainbow(file).underline.bright
  File.foreach(file) { |line| p line }
end
# next open and read file content - 1

# no spaces if rule 

# rule needs to be #rule {, .rule, html element { 
# find rule simple

# find rule html element

# how to store loop through content

# check indentation - may be possible with a string split

# bonus: create live with upload version

# if single line only 1 declaration

# can even consider doing rule that 



# check for properties - in assets folder - can also be loaded as script
# https://gist.github.com/davidhund/3bd6757d6a36a283b0a2933666bd1976

