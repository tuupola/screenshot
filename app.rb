require "rubygems"
require "haml"
require "sinatra"
require "pp"

use Rack::Static, :urls => ["/css", "/js", "/images"], :root => "public"

before do
end

get "/" do
  haml :index
end

post "/" do
  @url = Rack::Utils.escape(params["url"].gsub("http://", ""))
  haml :index
end

get "/1.0/*" do
  out = "/Users/tuupola/Code/ruby/shot/public/img/test.png"
  system("/Users/tuupola/bin/CutyCapt --url='#{url}' --out='#{out}' --plugins=on --delay=1000")
  send_file(out, :disposition => "inline", 
                 #:filename => File.basename(out),
                 :type => "image/png")
end

helpers do
  
  def url
    url = Rack::Utils.unescape(params["splat"][0])
    unless "http" == url[0, 4]
      url = "http://" + url
    end
    url
  end

end