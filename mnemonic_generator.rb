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

def find_mnemonic(footprint_to_words, digits, mnemonic = [], length = digits.size)
  return mnemonic if digits.empty?
  raise "Fail #{mnemonic} > #{digits}" if length.zero?

  footprint = digits.take(length).join
  words = footprint_to_words[footprint]
  if words
    find_mnemonic(
      footprint_to_words,
      digits.drop(length),
      mnemonic + [{footprint => words}],
      digits.size - length
    )
  else
    find_mnemonic(footprint_to_words, digits, mnemonic, length.pred)
  end
end

def footprint_to_words(words)
  footprint_word_pairs = words.reject { |word| word.size < 3 }.map do |word|
    [word.chars.map { |letter| LETTER_TO_DIGIT[letter] }.compact.join, word]
  end

  footprint_word_pairs.
    group_by { |footprint, _word| footprint }.
    transform_values { |words_with_footprint| words_with_footprint.map(&:last) }
end

words = File.read('./books/dict/words.list').split("\n")

mnemonic = find_mnemonic(footprint_to_words(words), number.to_s.chars)

if simple_mode
  pp (mnemonic.map { |mn| mn.transform_values(&:first) })
else
  pp mnemonic
end
