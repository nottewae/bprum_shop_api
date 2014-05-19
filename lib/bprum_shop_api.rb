require "bprum_shop_api/version"
require 'bcrypt'
require 'json'

module BprumShopApi
  class Api

    def initialize(my_key,remote_key,remote_path,remote_host,remote_port=80,charset='utf-8')
      @my_key = my_key
      @remote_port = remote_port
      @remote_key = remote_key
      @remote_path = remote_path
      @remote_host = remote_host
      @charset = charset
      @number_of_message = 0
      @out_file = File.open('log/api.log','a')
      log_write("API class initializied")
    end
    def log_write(message)
      @number_of_message += 1
      puts @number_of_message.to_s + ": \t" + message + " - in: "+Time.now.to_s+"  \n"
      @out_file.write( @number_of_message.to_s + ": \t" + message + "\n")
    end

    def checkRequest(request)
      log_write("cheking request: \n\t|type::"+request.class.to_s+" \n\t|content::"+request.to_s)
      parsed=JSON.parse(request)
      log_write("respond JSON is:\n"+parsed.inspect)
      arr=parsed["request_body"].sort
      log_write("sorted content:\n"+arr.inspect)
      order_hash=arr.to_h
      mysign=Digest::SHA2.hexdigest(order_hash.to_json+@my_key)
      log_write("signature of this respond must be:\n"+mysign)
      log_write("signature of this respond:\n"+parsed["sign"])
      if mysign==parsed["sign"]
        log_write("this request is valid")
        return parsed["request_body"]
      else
        log_write("this request is invalid")
        false
      end
    end

    def signRequest(params)
      log_write("now generating signature for new request")
      arr=params[:request_body].sort
      params[:request_body]=arr.to_h
      Digest::SHA2.hexdigest(params[:request_body].to_json+@remote_key).to_s
    end

    def requestProcessor(params)
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
