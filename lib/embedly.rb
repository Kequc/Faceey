class Embedly
  def self.get_attrs(url)
    embedly_url = "http://api.embed.ly/1/oembed?url=#{url}"
    response = RestClient.get embedly_url
    attrs = JSON.parse response.body
  rescue
    {}
  end
end
