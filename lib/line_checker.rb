# rubocop:disable Metrics/CyclomaticComplexity
# rubocop:disable Style/GlobalVars
# rubocop:disable Lint/UselessAssignment
module LineChecker
  def space_split(line)
    line.split(' ')
  end

  def first_el(line)
    space_split(line)[0].to_s
  end

  def last_el(line)
    space_split(line)[-1].to_s
  end

  def start_space_count(line)
    line[/\A */].size
  end

  def end_space_count(line)
    line[/ *\z/].size
  end

  def html_selector?(line)
    $html_tags.include?(first_el(line))
  end

  def class_selector?(line)
    first_el(line).start_with?('.')
  end

  def id_selector?(line)
    first_el(line).start_with?('#')
  end

  def double_indent?(line)
    start_space_count(line) == 2
  end

  def count_spaces(line)
    line.count(' ')
  end

  def no_space(line)
    line.count(' ').zero?
  end

  def single_line_check(line)
    line.include?('{') and line.include?('}')
  end

  def valid_ml_close?(line)
    no_space(line) and (line.length == 2) and line.include?("}\n")
  end

  def valid_sl_close?(line)
    single_line_check(line) and line.end_with?("; }\n")
  end

  def empty_line?(line)
    (line == "\n") and (line.length == 1) and count_spaces(line).zero?
  end

  def newline?(line)
    line.include?("\n")
  end

  def has_semi?(line)
    line.include?(";")
  end

  # makes error of assuming : to follow double indent
  def css_prop?(line)
    if !line.include?(':')
      return 'not-css-prop'
    else
      r = line.split(':')[0].strip           
      $css_props.include?(r) ? r : 'not-css-prop'
    end
  end

  def classify_start(line)
    line_start = ''
    line_start = html_selector?(line) ? 'html_tag' : line_start
    line_start = class_selector?(line) ? 'class_selector' : line_start
    line_start = id_selector?(line) ? 'id_selector' : line_start
    line_start = start_space_count(line) == 2 ? 'double_indent' : line_start
    line_start = valid_ml_close?(line) ? 'close_bracket' : line_start
    line_start = valid_sl_close?(line) ? 'close_bracket' : line_start
    line_start = empty_line?(line) ? 'empty_line' : line_start    
  end
end
# rubocop:enable Metrics/CyclomaticComplexity
# rubocop:enable Style/GlobalVars
# rubocop:enable Lint/UselessAssignment
