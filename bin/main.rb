#!/usr/bin/env ruby
require 'rainbow' # docs https://www.rubydoc.info/gems/rainbow/3.0.0
require 'json'

html_tags_file = File.read('./assets/html-tags.json')
$html_tags = JSON.parse(html_tags_file)
css_props_file = File.read('./assets/css-properties.json')
$css_props = Array.new
css_props = JSON.parse(css_props_file).each { |pr| $css_props << pr.values[0] }

# p $css_props.length
$css_props = $css_props.uniq
$selector_arr = ['html_tag', 'id_selector', 'class_selector']
p $css_props.length, $css_props[..20]

# to be moved to lib 

class Lint 
  attr_accessor :file_hash

  def initialize
    @files = [] # is this necessary
    @file_hash = {
      file_name: '',
      lines: [],
      errors: []
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

def space_split(line)
  line.split(' ')
end

def raw_split(line)
  line.split("/\s+/")
end

def first_el(line)
  space_split(line)[0].to_s
end

def last_el_raw(line)
  raw_split(line)[0]
end

def is_html_selector(line)
  $html_tags.include?(first_el(line)) 
end

def is_class_selector(line)
  first_el(line).start_with?('.') 
end

def is_id_selector(line)  
  first_el(line).start_with?('#') 
end

def is_double_indent(line)
  line.start_with?('  ')
end

def count_spaces(line)
  line.count(' ')
end

def no_space(line)
  line.count(' ') == 0
end

def is_valid_ml_close(line)
  no_space(line) and (line.length == 2) and (line.include?("}\n")) 
end

def is_empty_line(line)
  (line == "\n") and (line.length == 1) and (count_spaces(line) == 0)
end

def fn_call(k,fn,line)
  fn(line) ? k : line_start
end

# rules 

def no_EOS_newline?(file)
  File.open(file).readlines[0]

end

# TODO: refactor this
def classify_start(line)

  line_start = is_html_selector(line) ? 'html_tag' : line_start
  line_start = is_class_selector(line) ? 'class_selector' : line_start
  line_start = is_id_selector(line) ? 'id_selector' : line_start
  line_start = is_double_indent(line) ? 'double_indent' : line_start
  line_start = is_valid_ml_close(line) ? 'close_bracket' : line_start
  line_start = is_empty_line(line) ? 'empty_line' : line_start
  
  line_start  
end

# line_arr = line.split("/\s+/")  
# # full_line = line_arr[0]
# split_line = line_arr[0].split(/ /)#end_of_line = line_arr[-1]

# # space_count = full_line.count(' ')
# # start_el = first_el(line)
# end_el = split_line[-1]

#line_arr, line_class, space_count, full_line, start_el, end_el, split_line

def has_newline(line)
  #line.split("/\s+/")[-1].end_with?("\n") ? true : false
  line.split("/\s+/")[-1].include?("\n")
end

def has_css_prop(line)
  r = line.split(':')[0].strip
  $css_props.include?(r) ? r : 'not-css-prop'
end

def is_single_line_rule(line) 
  p line[-2]  
end


# loop through files - after open
for file in files
  lint = Lint.new
  lint.file_hash[:file_name] = file  
  line_count = `wc -l < #{file}`.to_i
  
  

  puts Rainbow(file).underline.bright
  puts "total lines: #{line_count+1}"
  File.readlines(file).each_with_index { |line, i| lint.file_hash[:lines] << [i+1, classify_start(line), line.length, last_el_raw(line), has_newline(line)] }
  
  
  #lc = File.open(file).readlines[-1]
  line_count = `wc -l < #{file}`.to_i
  #line_count = lint.file_hash[:lines].count
  last_line = lint.file_hash[:lines].last


  # p `wc -l < #{file}`.to_i # fact way to print line count
  # p "lc: #{lc}" 
  # p line_count
  



  # RULES

  # find missing-end-of-source newline
  if last_line[-1] == false
    puts "#{last_line[0]}:#{last_line[2]} " + Rainbow("✖").red + " Missing end-of-source newline"    
  end

  # create list of lines with double_indent 
  lines_double_indent = lint.file_hash[:lines].select { |line| line[1] == 'double_indent' }
  
  lines_close_bracket = lint.file_hash[:lines].select { |line| line[-2].include? "}" }#line[1] == 'close_bracket' or }#(line[-2].include? "}") }
  lines_open_bracket = lint.file_hash[:lines].select { |line| line[-2].include? "{" }

  lines_rules = lint.file_hash[:lines].select { |line| $selector_arr.any?(line[1]) }

  

  # check that css rule follows double_indent
  lines_double_indent.each do |l| 
    if has_css_prop(l[-2]) == 'not-css-prop'
      puts "#{l[0]}:3 " + Rainbow("✖").red + " Expecting css-rule after double indent"
    end
  end

  # css rule should end with ;
  lines_double_indent.each do |l| 
    line = l[-2]
    if (has_css_prop(line) != 'not-css-prop') and (!(line).end_with?(";\n"))
      puts "#{l[0]}:#{line.length} " + Rainbow("✖").red + " Expecting a trailing semicolon after setting CSS property."
    end
  end

  # double indent before rule 

  # no empty space after close bracket
  lines_rules.each do |l|
    line = l[-2]
    if line.include?('{') and line.include?("}")
      if line.end_with?(" \n")
        puts "#{l[0]}:#{line.length} " + Rainbow("✖").red + " Missing new line after single line declaration."
      end
    end
  end

  # expecting newline after close bracket
  lines_close_bracket.each do |l| 
    if l[1] != 'close_bracket' 
      puts "#{l[0]}:#{l[-2].length} " + Rainbow("✖").red + " Invalid close bracket, expecting \"}\" with no leading or trailing spaces. "
      
    end
  end

  puts "\n"



  # expect new_line and opennign bracket after selector


  # development output
  # p "-"*50
  # p "Development output:"
  # lint.file_hash[:lines].each { |l| p l }

  # lint.file_hash[:lines].last[-1] == false
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