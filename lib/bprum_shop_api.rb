#require "bprum_shop_api/version"
require 'bcrypt'
require 'json'
module BprumShopApi
  class Api

    def initialize(my_key,remote_key,remote_path,remote_host,charset='utf-8')
      @my_key = my_key
      @remote_key = remote_key
      @remote_path = remote_path
      @remote_host = remote_host
      @charset=charset
    end

    def checkRequest(respond)
      parsed=JSON.parse(respond)
      arr=parsed["request_body"].sort
      order_hash=arr.to_h
      mysign=Digest::SHA2.hexdigest(order_hash.to_json+@my_key)
      if mysign==respond["sign"]
        true
      else
        false
      end
    end
    def signRequest(params)
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
        #TODO Написать обработчик
      else
        return false
      end
    end
  end
end
