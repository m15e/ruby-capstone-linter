# rubocop:disable Metrics/CyclomaticComplexity
# rubocop:disable Style/GlobalVars
# rubocop:disable Lint/UselessAssignment
module LineChecker
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
    line.start_with?('  ')
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

  def empty_line?(line)
    (line == "\n") and (line.length == 1) and count_spaces(line).zero?
  end

  def newline?(line)
    line.split("/\s+/")[-1].include?("\n")
  end

  def css_prop?(line)
    r = line.split(':')[0].strip
    $css_props.include?(r) ? r : 'not-css-prop'
  end

  def classify_start(line)
    line_start = html_selector?(line) ? 'html_tag' : line_start
    line_start = class_selector?(line) ? 'class_selector' : line_start
    line_start = id_selector?(line) ? 'id_selector' : line_start
    line_start = double_indent?(line) ? 'double_indent' : line_start
    line_start = valid_ml_close?(line) ? 'close_bracket' : line_start
    line_start = empty_line?(line) ? 'empty_line' : line_start
  end
end
# rubocop:enable Metrics/CyclomaticComplexity
# rubocop:enable Style/GlobalVars
# rubocop:enable Lint/UselessAssignment
