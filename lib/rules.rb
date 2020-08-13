module Rules
  def css_rule_after_double_indent
    @file_hash[:lines_double_indent].each do |l|   
      if css_prop?(l[-3]) == 'not-css-prop'
        @file_hash[:errors] << [l[0], "#{l[0]}:3 ", ' Expected css-rule after double indent.', l]
      end
    end
  end

  def single_line_rule?
    @file_hash[:lines_rules].each do |l|
      if single_line_check(l[-3])        
        @file_hash[:rules_single] << l
      end      
    end  
  end

  def starting_spaces?
    @file_hash[:lines_all].each do |l|
      line = l[-3]
      if start_space_count(line) >= 3
        @file_hash[:errors] << [l[0], "#{l[0]}:#{line.length} ", ' Too many spaces at start of line.']
      end
    end
  end

  def rule_ends_with_semicolon    
    out_str = ' Expected trailing semicolon when setting CSS prop.'
    @file_hash[:rules_single].each do |l| 
      line = l[-3] 
      if !line.split(':')[1].include?(';')
        @file_hash[:errors] << [l[0], "#{l[0]}:#{line.length} ", out_str]
      end
    end

    @file_hash[:lines_double_indent].each do |l|
      line = l[-3]      
      if (css_prop?(line) != 'not-css-prop') and !has_semi?(line)
        @file_hash[:errors] << [l[0], "#{l[0]}:#{line.length} ", out_str]
      end
    end
  end

  def trailing_spaces?
    @file_hash[:lines_all].each do |l|
      line = l[-3]
      if end_space_count(line) > 0
        @file_hash[:errors] << [l[0], "#{l[0]}:#{line.length} ", ' No trailing spaces at end of line.']
      end
    end
  end

  def close_curly_alone
    @file_hash[:lines_close_bracket].each do |l|
      if l[1] != 'close_bracket' and l[0] != (@file_hash[:line_count]+1)
        @file_hash[:errors] << [l[0], "#{l[0]}:#{l[-3].length} ", ' Invalid close bracket, no leading/trailing spaces.']
      end
    end
  end

  def no_newline_after_oneline_declaration
    @file_hash[:lines_rules].each do |l|
      line = l[-3]
      next unless line.include?('{') and line.include?('}')

      if line.end_with?(" \n")
        @file_hash[:errors] << [l[0], "#{l[0]}:#{line.length} ", ' Missing new line after single line declaration.', l]
      end
    end
  end

  def eof_newline?
    last_line = @file_hash[:lines_all].last
    return unless last_line[-1] == false

    @file_hash[:errors] << [last_line[0], "#{last_line[0]}:#{last_line[2]} ", ' Missing end-of-source newline.']
  end
end  