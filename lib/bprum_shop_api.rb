#require "bprum_shop_api/version"
require 'bcrypt'
require 'json'
require 'term/ansicolor'
module BprumShopApi
  class Api

    def initialize(my_key,remote_key,remote_path,remote_host,charset='utf-8')
      @my_key = my_key
      @remote_key = remote_key
      @remote_path = remote_path
      @remote_host = remote_host
      @charset = charset
      @number_of_message = 0
      @out_file = File.open('log/api.log','a')
      log_write("API class initializied".white)
    end
    def log_write(message)
      @number_of_message += 1
      @out_file.write( @number_of_message.tos + ": \t" + message + "\n")
      log_write("Log started logfile is appdir/log/api.log".white)
    end
    def checkRequest(request)
      log_write("cheking request: "+(+"\n\t|type::"+request.class+" \n\t|content::"+request.to_s).yellow)
      parsed=JSON.parse(request)
      log_write(("respond JSON is:\n"+parsed.inspect).yellow)
      arr=parsed["request_body"].sort
      log_wite("sorted content:\n"+(arr.inspect).yellow)
      order_hash=arr.to_h
      mysign=Digest::SHA2.hexdigest(order_hash.to_json+@my_key)
      log_write("signature of this respond must be:\n"+(mysign).yellow)
      log_write("signature of this respond:\n"+(request["sign"]).yellow)
      if mysign==request["sign"]
        log_write(("this request is valid").red)
        return request["request_body"]
      else
        log_write(("this request is invalid").green)
        false
      end
    end

    def signRequest(params)
      log_write("now generating signature for new request")
      arr=params[:request_body].sort
      params[:request_body]=arr.to_h
      Digest::SHA2.hexdigest(params[:request_body].to_json+@remote_key)
    end

    def reguestProcessor(params)
      hash=params
      hash[:sign]=signRequest(params)
      hash=hash.to_json
      result={}
      Net::HTTP.start(@remote_host) do |http|
        req = Net::HTTP::Post.new(@remote_path)
        req.set_content_type('text/json', { 'charset' => @charset })
        req.body = hash
        response = http.request(req)
        if response.class.to_s == 'Net::HTTPOK'
          puts response.inspect
          puts response.value
          result = JSON.parse(response.body)
        else
          puts response.inspect
        end
      end
      if result["access"]=="granted"
        result["body"]
      else
        return false
      end
    end

  end
end
