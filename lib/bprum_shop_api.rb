require "bprum_shop_api/version"

module BprumShopApi
  class Api

    def initialize(my_key,remote_key,remote_path,remote_host)
      @my_key=my_key
      @remote_key=remote_key
      @remote_path=remote_path
      @remote_host=remote_host
    end

    def checkRequest(params)
      params["sign"]=nil
      mysign=Digest::SHA2.hexdigest(params.to_json+@my_key)
      if mysign==params["sign"]
        true
      else
        false
      end
    end
    def signRequest(params)
      Digest::SHA2.hexdigest(params.to_json+@remote_key)
    end
    def reguestProcessor(params)
      hash=params
      hash["sign"]=signRequest(params)
      hash=hash.to_json
      result={}
      Net::HTTP.start(@remote_host) do |http|
        req = Net::HTTP::Post.new(@remote_path)
        req.set_content_type('text/json', { 'charset' => 'utf-8' })
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
