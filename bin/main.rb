#!/usr/bin/env ruby
require 'rainbow' # docs https://www.rubydoc.info/gems/rainbow/3.0.0
require 'json'


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

# p files


def classify_line(line)
  html_tags_file = File.read('./assets/html-tags.json')
  html_tags = JSON.parse(html_tags_file)
  css_props_file = File.read('./assets/css-properties.json')
  css_props = JSON.parse(css_props_file)
  
  line_classes = ['space', 'eof', 'comment', 'rule', 'setting'] # consider adding pseudo_el
  line_arr = line.split("/\s+/")  
  full_line = line_arr[0]
  split_line = line_arr[0].split(/ /)#end_of_line = line_arr[-1]

  space_count = full_line.count(' ')
  start_el = split_line[0]
  end_el = split_line[-1]
  line_class = ''
  
  #p tags    
  if (html_tags.include? line_arr[0].split(' ')[0])
    line_class = 'html_tag'
  elsif line_arr[0].to_s.start_with?('.')
    line_class = 'class_tag'
  elsif line_arr[0].to_s.start_with?('#')
    line_class = 'id_tag'  
  elsif line_arr[0].to_s.start_with?('  ') and line_arr[0].split(' ')[0]
    #p "!!!! DI #{line_arr[0].to_s} blop: #{line_arr[0].split(' ')}" # this still right??
    line_class = 'double_indent'
  elsif full_line == start_el and start_el == end_el 
    line_class = 'empty line'
    if start_el.start_with?("}\n")
      line_class = 'close bracket'
    end
  end

  #p "#{line_class}, #{start_of_line}, #{split_line} "
  # line_class = (line_arr[0].to_s.start_with?'.') ? 'class_tag' : 'line_class_unknown'
  # line_class = (line_arr[0].to_s.start_with?'#') ? 'id_tag' : 'line_class_unknown'
  #if .include? line[0]  # simple case - consider first space is empty spaces
  return [line_class, space_count, start_el, end_el, split_line]
end

# loop through files - after open
for file in files
  lint = Lint.new
  lint.file_hash[:file_name] = file  

  puts Rainbow(file).underline.bright
  File.foreach(file).with_index { |line, i| lint.file_hash[:lines] << [i+1, classify_line(line)] }
  lint.file_hash[:lines].each { |l| p l }
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

