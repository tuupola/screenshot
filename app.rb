require "rubygems"
require "haml"
require "sinatra"
require "md5"
require "prawn"
require "pp"

use Rack::Static, :urls => ["/css", "/js", "/img"], :root => "public"

configure :development do
  set :cuty_capt, "/Users/tuupola/bin/CutyCapt";
end

configure :production do
  set :cuty_capt, "/usr/local/CutyCapt/xvfb-run.sh --auto-servernum --server-args='-screen 0, 1024x768x24' /usr/local/CutyCapt/CutyCapt"
end

set :cache_folder, Proc.new { File.join(root, "public", "img") }

before do
end

get "/" do
  haml :index
end

post "/" do
  @url = Rack::Utils.escape(params["url"].gsub("http://", ""))
  haml :index
end

#
# Accepts both  /1.0/www.example.com/bar.png and /1.0/www.example.com%2fbar.png
# style requests. However Apache will return 404 for latter unless you have
# AllowEncodedSlashes On
#
#get "/1.0/*" do
get %r{/1.0/(.*)\.(jpg|png|pdf)?$} do
  pp params
  if ("pdf" == extension) 
    system("#{settings.cuty_capt} --url='#{url}' --out='#{out}.png' --plugins=on --delay=1000")
    png = "#{out}.png"
    Prawn::Document.generate("#{out}.pdf", :page_size => 'A4') do
      image open(png), :position => :center, 
                       :vposition => :center, 
                       #:fit => Prawn::Document::PageGeometry::SIZES["A4"]
                       :fit => [540,763]
    end
    send_file("#{out}.#{extension}", :disposition => "inline")
  else
    system("#{settings.cuty_capt} --url='#{url}' --out='#{out}.#{extension}' --plugins=on --delay=1000")
    send_file("#{out}.#{extension}", :disposition => "inline")
  end    
  #               :filename => File.basename(out),
  #               :type => "image/#{extension}")
end

get "/1.0/*" do
  redirect "#{params["splat"][0]}.png"
end

helpers do
  
  def url
    #url = Rack::Utils.unescape(params["splat"][0])
    url = Rack::Utils.unescape(params["captures"][0])
    unless "http" == url[0, 4]
      url = "http://" + url
    end
    url
  end
  
  def out
    hash = MD5.new(url)
    out = File.join(settings.cache_folder, "#{hash}")
  end
  
  def extension
    params["captures"][1] || "png"
  end
    
end