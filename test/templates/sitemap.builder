xml.instruct! :xml, :version => '1.0', :encoding => 'UTF-8'
xml.urlset :xmlns => 'http://www.sitemaps.org/schemas/sitemap/0.9' do
  xml.url do
    xml.loc @config[:url] + "/"
    xml.changefreq "daily"
    xml.priority 1
  end

  xml.url do
    xml.loc @config[:url] + "/about/"
    xml.changefreq "weekly"
  end

  xml.url do
    xml.loc @config[:url] + "/contributing/"
    xml.changefreq "weekly"
  end

  xml.url do
    xml.loc @config[:url] + "/sources/"
    xml.changefreq "weekly"
  end

  articles.each do |article|
    xml.url do
      xml.loc article.url
      xml.lastmod article[:date].iso8601
      xml.changefreq "weekly"
      xml.priority 0.7
    end
  end
end
