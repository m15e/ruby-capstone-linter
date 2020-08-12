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

  def has_newline(line)
    line.split("/\s+/")[-1].include?("\n")
  end
  
  def has_css_prop(line)
    r = line.split(':')[0].strip
    $css_props.include?(r) ? r : 'not-css-prop'
  end

  def classify_start(line)
    line_start = is_html_selector(line) ? 'html_tag' : line_start
    line_start = is_class_selector(line) ? 'class_selector' : line_start
    line_start = is_id_selector(line) ? 'id_selector' : line_start
    line_start = is_double_indent(line) ? 'double_indent' : line_start
    line_start = is_valid_ml_close(line) ? 'close_bracket' : line_start
    line_start = is_empty_line(line) ? 'empty_line' : line_start
  end
  
end
