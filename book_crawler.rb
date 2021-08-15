require 'zip'
require 'nokogiri'
require 'open-uri'
require 'ruby-progressbar'

def extract_zip(file, destination)
  Zip::File.open(file) do |zip_file|
    zip_file.each do |f|
      fpath = File.join(destination, f.name)
      zip_file.extract(f, fpath) unless File.exist?(fpath)
    end
  end
end

def read_url(url)
  URI.open(url).read
rescue StandardError => e
  sleep 3
  puts "'Failure' #{e.message}"
  retry
end

def with_progress(progressbar)
  result = yield
  progressbar.increment
  result
end

base_url = 'https://chitanka.info'

index_progressbar = ProgressBar.create(title: 'Scraping Index', total: 38)
urls = 1.upto(38).map do |page|
  with_progress(index_progressbar) do
    "#{base_url}/books/category/thriller.html/#{page}"
  end
end

links_progressbar = ProgressBar.create(title: 'Scraping Links', total: 38)
books_urls = urls.flat_map do |url|
  with_progress(links_progressbar) do
    document = Nokogiri.parse read_url(url)
    document.css('a.dl.dl-txt').map { |link| link['href'] }
  end
end

FileUtils.mkdir_p('./books/zipped/')
download_progressbar = ProgressBar.create(title: 'Downloading Books', total: books_urls.size)
books_urls.each do |url|
  with_progress(download_progressbar) do
    book_content = read_url("#{base_url}#{url}")
    File.write("./books/zipped/#{url.split('/').last}", book_content)
  end
end

FileUtils.mkdir_p('./books/raw/')
unzip_progressbar = ProgressBar.create(title: 'Unzipping Books', total: books_urls.size)
Dir['./books/zipped/*'].each do |book_file|
  with_progress(unzip_progressbar) { extract_zip(book_file, './books/raw/') }
end
