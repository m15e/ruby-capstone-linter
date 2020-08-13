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
    no_newline_after_oneline_declaration    
    single_line_rule?
    close_curly_alone
    rule_ends_with_semicolon
    trailing_spaces?
    starting_spaces?
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
      last_el = last_el(line)
      nl_at_end = newline?(line)
      @file_hash[:lines_all] << [i + 1, start_el, line_len, line, last_el, nl_at_end]
    end    

    @file_hash[:lines_double_indent] = @file_hash[:lines_all].select { |line| line[1] == 'double_indent' }
    @file_hash[:lines_open_bracket] = @file_hash[:lines_all].select { |line| line[-3].include? '{' }
    @file_hash[:lines_close_bracket] = @file_hash[:lines_all].select { |line| line[-3].include? '}' }
    @file_hash[:lines_rules] = @file_hash[:lines_all].select { |line| $selector_arr.any?(line[1]) }
  end


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
