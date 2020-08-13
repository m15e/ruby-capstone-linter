require 'line_checker'

describe LineChecker do
  include LineChecker 
  let(:single_line_rule) { ".container { background-color: blue; }\n" }
  let(:spaces_start) { "   .container {\n" }  
  let(:four_spaces_start) { "    p {\n" }  
  let(:four_spaces_end) { "p {    \n" }  
  
  describe '#first_el' do
    it 'returns the first element of a space split array' do
      expect(first_el(single_line_rule)).to eql('.container')
    end

    it 'returns the first element of a space split array that starts with spaces' do
      expect(first_el(spaces_start)).to eql('.container')
    end
  end

  describe '#last_el' do
    it 'returns the last element of a space split array' do
      expect(last_el(single_line_rule)).to eql('}')
    end
  end

  describe '#start_space_count' do
    it 'returns correct number of spaces at start' do
      expect(start_space_count(four_spaces_start)).to eql(4)
    end
  end

  describe '#end_space_count' do
    it 'returns correct number of spaces at end' do
      expect(end_space_count(four_spaces_end)).to eql(4)
    end
  end

  describe '#double_indent?' do
    it 'returns true if space starts with only 2 spaces' do
      expect(double_indent?('  color:')).to eql(true)
    end

    it 'returns false if space starts with more than 2 spaces' do
      expect(double_indent?(four_spaces_start)).to eql(false)
    end
  end

  describe '#class_selector' do
    it 'returns true if line starts with a .' do
      expect(class_selector?('.some_class')).to eql(true)
    end

    it 'returns false if line starts with a div' do
      expect(class_selector?('div')).to eql(false)
    end

    it 'returns false if line starts with a #' do
      expect(class_selector?('#')).to eql(false)
    end
  end

  describe '#id_selector' do
    it 'returns true if line starts with a #' do
      expect(id_selector?('#some_id')).to eql(true)
    end

    it 'returns false if line starts with a div' do
      expect(id_selector?('div')).to eql(false)
    end

    it 'returns false if line starts with a .' do
      expect(id_selector?('.')).to eql(false)
    end
  end

  describe '#valid_ml_close' do
    it 'correctly identifies correctly placed closing bracket (multi-line-case)' do
      expect(valid_ml_close?("}\n")).to eql(true)
    end

    it 'correctly identifies poorly spaced closing bracket (multi-line-case)' do
      expect(valid_ml_close?("  }\n")).to eql(false)
    end
  end

  describe '#valid_sl_close' do
    it 'correctly identifies correctly placed closing bracket and semi-colon (single-line-case)' do
      expect(valid_sl_close?(".container { background-color: blue; }\n")).to eql(true)
    end

    it 'correctly identifies poorly spaced closing bracket (single-line-case)' do
      expect(valid_sl_close?(".container { background-color: blue; } ")).to eql(false)
    end
  end

  describe '#empty_line?' do
    it 'returns true when it correctly identifies an empty line' do
      expect(empty_line?("\n")).to eql(true)
    end
    
    it 'returns false when line is not empty' do
      expect(empty_line?(spaces_start)).to eql(false)
    end
  end
  
end

