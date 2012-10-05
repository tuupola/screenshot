require "rubygems"
require "haml"
require "sinatra"
require "md5"
#require "prawn"
#require "prawn/fast_png"
require "pp"

use Rack::Static, :urls => ["/css", "/js", "/img"], :root => "public"

configure :development do
  #set :cuty_capt, "/Users/tuupola/bin/CutyCapt";
  set :phantomjs, "/usr/local/bin/phantomjs"
end

configure :production do
  #set :cuty_capt, "/usr/local/CutyCapt/xvfb-run.sh --auto-servernum --server-args='-screen 0, 1024x768x24' /usr/local/CutyCapt/CutyCapt"
  set :phantomjs, "/opt/phantomjs/bin/phantomjs"
end

set :cache_folder, Proc.new { File.join(root, "public", "img") }

before do
end

get "/" do
  haml :index
end

post "/" do
  pp params
  @url = Rack::Utils.escape(params["url"].gsub("http://", "")) + "." + params["format"]
  # Ajax submitting not used at the moment.
  if request.xhr?
    haml :ajax, :layout => false
  else
    # Display inline
    if "inline" == params["display"]
      haml :index
    # or download
    else
      redirect "/1.0/download/#{params['url']}.#{params['format']}"
    end
  end
end

get %r{/1.0/download/(.*)\.(jpg|png|pdf)?$} do  
  generate_screenshot
  download_screenshot
end

#
# Accepts both  /1.0/www.example.com/bar.png and /1.0/www.example.com%2fbar.png
# style requests. However Apache will return 404 for latter unless you have
# AllowEncodedSlashes On
#
get %r{/1.0/(.*)\.(jpg|png|pdf)?$} do
  generate_screenshot
  display_screenshot
end

get "/1.0/*" do
  redirect "#{params["splat"][0]}.png"
end

get "/toggle" do
  toggle_mode
  redirect "/"
end

helpers do
  def generate_screenshot
    if ("xxpdf" == extension) 
      system("#{settings.cuty_capt} --url='#{url_with_http}' --out='#{out}.png' --plugins=on --delay=1000")
      png = "#{out}.png"
      Prawn::Document.generate("#{out}.pdf", :page_size => 'A4') do
        image open(png), :position => :center, 
                         :vposition => :center, 
                         #:fit => Prawn::Document::PageGeometry::SIZES["A4"]
                         :fit => [540,763]
      end
    else
      #system("#{settings.cuty_capt} --url='#{url_with_http}' --out='#{out}.#{extension}' --plugins=on --delay=1000")
      system("#{settings.phantomjs} rasterize.js #{url_with_http} #{out}.#{extension}")
    end
  end
  
  def display_screenshot
    send_file("#{out}.#{extension}", :disposition => "inline")
  end
  
  def download_screenshot
    send_file("#{out}.#{extension}", :filename => File.basename(out) + ".#{extension}")
  end
  
  def url_with_http
    #url = Rack::Utils.unescape(params["splat"][0])
    url = Rack::Utils.unescape(params["captures"][0])
    unless "http" == url[0, 4]
      url = "http://" + url
    end
    url
  end
  
  def out
    hash = MD5.new(url_with_http)
    out = File.join(settings.cache_folder, "#{hash}")
  end
  
  def extension
    params["captures"][1] || "png"
  end
  
  def mode
    request.cookies["screenshot_mode"] || "simple"
  end
  
  def advanced_visibility
    "advanced" == mode ? "visible" : "hidden"
  end

  def advanced_toggle_text
    "advanced" == mode ? "<< Hide advanced" : "Show advanced >>"
  end

  def toggle_mode
    if "simple" == mode
      response.set_cookie("screenshot_mode", "advanced")
    else
      response.set_cookie("screenshot_mode", "simple")
    end
  end
  
end