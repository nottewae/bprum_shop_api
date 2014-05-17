require_relative File.join("..","lib","bprum_shop_api.rb",)
api=BprumShopApi::Api.new("1c48e7d8ee6c4d4ff0db6c5fa147a7fd6463faa2a6c657cb1ecb7736e6a2498a","81fe6b125f392e5fb75be71284a8420321e388e5f79b103100e011f3ec16630a","","")
puts api.signRequest({request_body:{for:"14555",name:"blablabla"}})
puts api.checkRequest({sign:"81fe6b125f392e5fb75be71284a8420321e388e5f79b103100e011f3ec16630a",request_body:{for:"14555",name:"blablabla"}})