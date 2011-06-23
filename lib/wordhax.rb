require 'progress'
require 'core_ext/string'

class Wordhax
  
  def initialize(options={:display_progress => false, :force_reindex => false})
    @display_progress = options[:display_progress]
    @words = load_words()
    @word_combo_index = load_word_index(@words, options[:force_reindex])
  end
  
  def matches(letters)
    combos = letters.downcase.combinations
    
    results = combos.inject([]){|acc, combo|
      acc += (@word_combo_index[combo.chars.sort] || [])
      acc
    }
    
    results.uniq.map{|id| @words[id]}.sort_by{|word| word.size}
  end
    
  private
  def words_path
    File.join(File.dirname(__FILE__), '..', 'data', 'words_nl.txt')
  end
  
  def words_combo_index_path
    File.join(File.dirname(__FILE__), '..', 'data', 'words_combo_index')
  end
  
  def load_words()
    words = File.readlines(words_path)
    words.map!{|word| word.strip.downcase} # kill newline characters
    words
  end
  
  def load_word_index(words, force_reindex)
    if !File.exists?(words_combo_index_path) || force_reindex
      word_index = build_word_index(words)
      File.open(words_combo_index_path, "wb") do |f|
        Marshal.dump(word_index, f)
      end
      word_index
    else
      File.open(words_combo_index_path, "r") do |f|
        Marshal.load(f)
      end
    end
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
