# encoding: UTF-8
require 'nokogiri'
require 'csv'
require 'open-uri'
require_relative 'data'

class Product
	attr_accessor :name, :cost, :image_url
	def initialize(product_name, cost, image_url)
		@name = product_name
		@cost = cost
		@image_url = image_url
	end
end

puts "Подождите немного..."

array = []
page_index = 1
puts URL + '?n=100&p=' + page_index.to_s
doc = Nokogiri::HTML(open(URL + '?n=100&p=' + page_index.to_s))
while true do
	items_count = doc.xpath("//img[@itemprop='image']").size
	0.upto(items_count - 1) do |i|
		item = {}
		url = doc.xpath("//a[@class='product_img_link']")[i].attributes["href"].value
		content = Nokogiri::HTML(open(url))
		item_name = content.xpath("//h1[@itemprop='name']").to_a.first.children.last.text.strip
		product_image = content.xpath("//img[@id='bigpic']").to_a.first.attributes["src"].value
		weight_count = content.xpath("//ul[@class='attribute_labels_lists']").size
		0.upto(weight_count - 1) do |i|
			weight = content.xpath("//ul[@class='attribute_labels_lists']")[i].xpath("//span[@class='attribute_name']")[i].children.text
			product_cost = content.xpath("//ul[@class='attribute_labels_lists']")[i].xpath("//span[@class='attribute_price']")[i].children.text.strip
			product_name = (item_name + " - " + weight).gsub(/\s+/, " ").strip
			puts "#{product_name}\n#{product_cost}\n#{product_image}\n"
			array.push(Product.new(product_name, product_cost, product_image))
		end
	end
	break if items_count < 100
	page_index += 1
	doc = Nokogiri::HTML(open(URL + '?n=100&p=' + page_index.to_s))
end

CSV.open(FILE_NAME + ".csv", "w") do |csv|
	csv << ["Название", "Цена", "Изображение"]
	for item in array
		csv << [item.name, item.cost, item.image_url]
	end
end

puts "Файл записан!"

