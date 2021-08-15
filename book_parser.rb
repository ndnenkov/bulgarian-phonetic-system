require 'json'
require 'ruby-progressbar'

words = {}

letters = %w(а б в г д е ж з и й к л м н о п р с т у ф х ц ч ш щ ъ ь ю я)

file_paths = Dir['./books/raw/*.txt']

FileUtils.mkdir_p('./books/dict/')

books_progressbar = ProgressBar.create(title: 'Parsing books', total: file_paths.size)

file_paths.each do |file_path|
  IO.foreach(file_path) do |line|
    line.split(/\s+/).reject(&:empty?).each do |word|
      sanitized_word = word.downcase.gsub(/[^#{letters.join}'-]+/, '')

      next if sanitized_word.empty?
      next if sanitized_word.size > 35

      words[sanitized_word] = words[sanitized_word].to_i.next
    end
  end

  books_progressbar.increment
end

sorted = words.sort_by { |_word, frequency| -frequency }

File.write('./books/dict/words.list', sorted.map(&:first).join("\n"))
File.write('./books/dict/words.json', JSON.generate(sorted.to_h))
