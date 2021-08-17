require 'set'

number = ARGV.first.to_i
simple_mode = !!ARGV[1]

DIGIT_TO_LETTER = {
  0 => %w(р),
  1 => %w(л),
  2 => %w(м н),
  3 => %w(з с),
  4 => %w(ч),
  5 => %w(п б),
  6 => %w(ш ж),
  7 => %w(к г),
  8 => %w(в ф),
  9 => %w(д т),
  69 => %w(щ),
}.freeze
LETTER_TO_DIGIT = DIGIT_TO_LETTER.flat_map do |digit, letters|
  letters.map { |letter| [letter, digit] }
end.to_h

def bfs(graph, from, to)
  queue = [from]
  visited = [from].to_set
  spanning_tree = {}

  until queue.empty? || visited.include?(to)
    current_node = queue.shift
    (graph[current_node] || []).each do |adjacent_node|
      next if visited.include? adjacent_node

      queue.push adjacent_node
      visited.add adjacent_node
      spanning_tree[adjacent_node] = current_node
    end
  end

  return unless visited.include? to

  path = []
  node = to

  until from == node do
    path.unshift node
    node = spanning_tree[node]
  end

  path.unshift(node)

  path
end

def sentence_breakdown(dictionary, sentence)
  return [dictionary[sentence]] if dictionary[sentence]

  graph = {}
  0.upto(sentence.size.pred).each do |start_index|
    1.upto(sentence.size).each do |end_index|
      word = sentence[start_index...end_index]

      if dictionary[word]
        graph[start_index] ||= []
        graph[start_index].push end_index
      end
    end
  end

  path = bfs graph, 0, sentence.size

  return unless path

  path.each_cons(2).map do |start_index, end_index|
    word = sentence[start_index...end_index]
    [word, dictionary[word]]
  end
end

def footprint_to_words(words)
  footprint_word_pairs = words.map do |word|
    [word.chars.map { |letter| LETTER_TO_DIGIT[letter] }.compact.join, word]
  end

  footprint_word_pairs.
    group_by { |footprint, _word| footprint }.
    transform_values { |words_with_footprint| words_with_footprint.map(&:last) }
end

words = File.read('./books/dict/words.list').split("\n")

mnemonic = sentence_breakdown footprint_to_words(words), number.to_s
raise 'Failed for find mnemonic!' unless mnemonic

if simple_mode
  pp (mnemonic.map { |footprint, words| [footprint, words.first] })
else
  pp mnemonic
end
