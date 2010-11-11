require "rubygems"
require "haml"
require "sinatra"
require "pp"

use Rack::Static, :urls => ["/css", "/js", "/img"], :root => "public"

configure :development do
  set :cuty_capt, "/Users/tuupola/bin/CutyCapt";
end

configure :production do
  set :cuty_capt, "/home/tuupola/cutycapt/CutyCapt/xvfb-run.sh --server-args='-screen 0, 1024x768x24' /home/tuupola/cutycapt/CutyCapt/CutyCapt"
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

get "/1.0/*" do
  out = File.join(settings.cache_folder, "test.png")
  system("#{settings.cuty_capt} --url='#{url}' --out='#{out}' --plugins=on --delay=1000")
  send_file(out, :disposition => "inline", 
  #               :filename => File.basename(out),
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