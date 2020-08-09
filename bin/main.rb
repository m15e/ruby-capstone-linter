#!/usr/bin/env ruby
require 'rainbow' # docs https://www.rubydoc.info/gems/rainbow/3.0.0
require 'json'

html_tags_file = File.read('./assets/html-tags.json')

html_tags = JSON.parse(html_tags_file)

p html_tags.include?('div')


# to be moved to lib 

class Lint 
  attr_accessor :file_hash

  def initialize
    @files = [] # is this necessary
    @file_hash = {
      file_name: '',
      lines: []
    }
  end
end

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
  lint = Lint.new
  lint.file_hash[:file_name] = file  

  puts Rainbow(file).underline.bright
  File.foreach(file).with_index { |line, i| lint.file_hash[:lines] << [i, line] }
  puts lint.file_hash  
end

def classify_line(line)
  line_classes = ['space', 'eof', 'comment', 'rule', 'setting'] # consider adding pseudo_el

  #if .include? line[0]  # simple case - consider first space is empty spaces
  return line_class
end

# no spaces if rule 

# empty line before rule

# html tags https://gist.github.com/cecchi/99772a8483914b112400

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

