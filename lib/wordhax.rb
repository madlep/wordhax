require 'progress'

class Wordhax
  
  def initialize(options={:display_progress => false})
    @display_progress = options[:display_progress]
    @words = load_words()
    @word_combo_index = build_word_index(@words)
  end
  
  def matches(letters)
    results = @word_combo_index[letters.downcase.chars.sort] || []
    results.map{|id| @words[id]}
  end
    
  private
  def load_words()
    word_txt_path = File.join(File.dirname(__FILE__), '..', 'data', 'words_nl.txt')
    words = File.readlines(word_txt_path)
    words.map!{|word| word.strip.downcase} # kill newline characters
    words
  end
  
  def build_word_index(words)
    word_index = {}
    
    progress_increment = 1000
    interval_counter = 0
    
    indexer = lambda{
      words.each_with_index do |word, i|
        key = word.chars.sort
        (word_index[key] ||= []) << i

        # this is hacky - modulus is cleaner, but runs MUCH slower for some reason
        if @display_progress
          interval_counter += 1
          if interval_counter == progress_increment
            Progress.set(i)
            interval_counter = 0
          end
        end
      end
      Progress.set(@words.size) if @display_progress
    }
    
    if @display_progress
      Progress.start('indexing', @words.size, &indexer)
    else
      indexer.call
    end

    word_index
  end
    
end
