#!/usr/bin/env ruby

require 'awesome_print'

class Wordhax
  
  def initialize()
    @words = load_words()
    @word_combo_index = build_word_index(@words)
  end
  
  def matches(letters)
    @word_combo_index[letters.downcase.chars.sort].map{|id| @words[id]}
  end
    
  private
  def load_words()
    word_txt_path = File.join(File.dirname(__FILE__), '..', 'data', 'words_nl.txt')
    words = File.readlines(word_txt_path)
    words.map!(&:strip) # kill newline characters
    words.reject!{|w| w =~ /#.*/ } # kill comment lines starting with '#'
    words
  end
  
  def build_word_index(words)
    word_index = {}
    
    words.each_with_index do |word, i|
      key = word.downcase.chars.sort
      word_index[key] ||= []
      word_index[key] << i
    end

    word_index
  end
    
end

test_letters = ARGV[0] || ""

wordhax = Wordhax.new

matched_words = wordhax.matches(test_letters)
ap matched_words