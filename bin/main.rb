#!/usr/bin/env ruby
require 'rainbow'
require_relative '../lib/lintr.rb'

# get input files

in_args = ARGV

files = Dir.glob('**/**.css')

if files.empty?
  puts 'File ending with .css does not exist in this project.'
  exit
end

if in_args[0] == 'ignore'
  scrap = in_args.select { |file_name| file_name.end_with?('.css') }
  scrap.each { |file| files.delete(file) }
end

files.each do |file|  
  puts Rainbow(file).underline.bright
  lint = Lintr.new(file)
  puts "total lines: #{lint.file_hash[:line_count] + 1}"
  lint.file_hash[:errors].each do |err|
    puts err[1].to_s + err[-1].to_s + Rainbow('✖  ').red + err[2].to_s
  end
  if lint.file_hash[:errors].empty?
    puts Rainbow('✔ ✔ ✔ ').green + "Clean file. No infringements detected."
  end
  puts "\n"    
end
