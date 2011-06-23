class String
  
  def combinations
    combo_impl.sort.uniq
  end
  
  private
  def combo_impl
    combos = []
    combos << self
    
    (0...self.size).each do |i|
      removed_char_self = self.dup
      removed_char_self.slice!(i)
      unless removed_char_self.empty?
        combos += removed_char_self.combinations
      end
    end
    combos
  end
  
end