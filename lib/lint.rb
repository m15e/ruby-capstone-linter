require 'json'
require_relative './line_checker.rb'
require_relative './rules.rb'
# rubocop:disable Style/GlobalVars

class Lintr
  include LineChecker
  include Rules
  attr_accessor :file_hash

  def initialize(file)
    html_tags_file = File.read('./assets/html-tags.json')
    $html_tags = JSON.parse(html_tags_file)

    $css_props = []
    css_props_file = File.read('./assets/css-properties.json')
    JSON.parse(css_props_file).each { |pr| $css_props << pr.values[0] }
    $css_props = $css_props.uniq

    $selector_arr = %w[html_tag id_selector class_selector]

    setup(file)
    css_rule_after_double_indent
    rule_ends_with_semicolon
    no_newline_after_oneline_declaration
    close_curly_alone
    single_line_rule?
    eof_newline?
    sort_and_pad_errors
  end

  def setup(file)
    @file_hash = {
      file_name: file,
      line_count: `wc -l < #{file}`.to_i,
      lines_all: [],
      lines_double_indent: [],
      lines_open_bracket: [],
      lines_close_bracket: [],
      lines_rules: [],
      rules_single: [],
      errors: []
    }

    File.readlines(file).each_with_index do |line, i|
      start_el = classify_start(line)
      line_len = line.length
      last_el = last_el_raw(line)
      nl_at_end = newline?(line)
      @file_hash[:lines_all] << [i + 1, start_el, line_len, last_el, nl_at_end ]
    end
    p @file_hash[:lines_all]

    @file_hash[:lines_double_indent] = @file_hash[:lines_all].select { |line| line[1] == 'double_indent' } # line[1]: start el
    @file_hash[:lines_open_bracket] = @file_hash[:lines_all].select { |line| line[-2].include? '{' } # line[-2] 
    @file_hash[:lines_close_bracket] = @file_hash[:lines_all].select { |line| line[-2].include? '}' }
    @file_hash[:lines_rules] = @file_hash[:lines_all].select { |line| $selector_arr.any?(line[1]) }
  end

  # def css_rule_after_double_indent
  #   @file_hash[:lines_double_indent].each do |l|
  #     if css_prop?(l[-2]) == 'not-css-prop'
  #       @file_hash[:errors] << [l[0], "#{l[0]}:3 ", ' Expected css-rule after double indent', l]
  #     end
  #   end
  # end

  # def single_line_rule?
  #   @file_hash[:lines_rules].each do |l|
  #     if single_line_check(l[-2])        
  #       @file_hash[:rules_single] << l
  #     end      
  #   end  
  # end

  # def rule_ends_with_semicolon
  #   @file_hash[:lines_double_indent].each do |l|
  #     line = l[-2]
  #     if (css_prop?(line) != 'not-css-prop') and !line.end_with?(";\n")
  #       @file_hash[:errors] << [l[0], "#{l[0]}:#{line.length} ", ' Expected trailing semicolon when setting CSS prop.']
  #     end
  #   end
  # end

  # def close_curly_alone
  #   @file_hash[:lines_close_bracket].each do |l|
  #     if l[1] != 'close_bracket'
  #       @file_hash[:errors] << [l[0], "#{l[0]}:#{l[-2].length} ", ' Invalid close bracket, no leading/trailing spaces.']
  #     end
  #   end
  # end

  # def no_newline_after_oneline_declaration
  #   @file_hash[:lines_rules].each do |l|
  #     line = l[-2]
  #     next unless line.include?('{') and line.include?('}')

  #     if line.end_with?(" \n")
  #       @file_hash[:errors] << [l[0], "#{l[0]}:#{line.length} ", ' Missing new line after single line declaration.', l]
  #     end
  #   end
  # end

  # def eof_newline?
  #   last_line = @file_hash[:lines_all].last
  #   return unless last_line[-1] == false

  #   @file_hash[:errors] << [last_line[0], "#{last_line[0]}:#{last_line[2]} ", ' Missing end-of-source newline']
  # end

  def sort_and_pad_errors
    @file_hash[:errors].each do |l|
      error_loc = l[1]
      pad_length = (7 - error_loc.length)
      pad_str = ' ' * pad_length
      l.append(pad_str)
    end
    @file_hash[:errors] = @file_hash[:errors].sort_by(&:first)
  end
end
# rubocop:enable Style/GlobalVars
