require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'csv'

page = Nokogiri::HTML(open('http://kboo.fm/program'))
# html/List of Programs _ KBOO.html

#create an array of URLs
urls = []
page.css('h2.teaser-header > a').each do |el|
   urls << "http://kboo.fm" + el.attribute('href')
end

CSV_OPTIONS = {
  :write_headers => true,
  :headers => %w[urls programname programstatus programshortdesc programsummary programhosts programtopics programgenres]
}

CSV.open('program-list-add.csv', 'wb', CSV_OPTIONS) do |csv|
  urls.each do |url|
    url.chomp!
    begin
      page = Nokogiri.HTML(open(url))
      programname = page.css('h1.page-header').text
      programstatus = page.css('div.field-name-field-program-status > div > div').text
      programshortdesc = page.css('div.field-name-field-short-description > div > div').text
      programsummary = page.css('div.field-name-body > div > div').text
	  programhosts = []
		page.css('div.field-name-field-hosted-by > div > div > span > a').each do |el|
   			programhosts << el.text
		end
	  programtopics = []
		page.css('div.field-name-field-topic-tags > div > div > span > a').each do |el|
   			programtopics << el.text
		end
	  programgenres = []
		page.css('div.field-name-field-genres > div > div > span > a').each do |el|
   			programgenres << el.text
		end
      csv << [url, programname,programstatus,programshortdesc,programsummary,programhosts,programtopics,programgenres]
    rescue OpenURI::HTTPError => e
      csv << [url, e.message]
    end
  end
end