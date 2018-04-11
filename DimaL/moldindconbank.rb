require 'watir'
require 'nokogiri'
require 'json'
require 'pry'
require_relative 'moldtransaction'

class Moldindconbank

	attr_reader :browser, :page, :trans, :desc_trans
	def initialize
		@browser = Watir::Browser.new(:chrome)
		browser.goto("https://wb.micb.md/")                       
	end

	def collect_data
		log_in
		sleep(3)
		go_to_card_data
		sleep(3)
		go_to_transaction_data
		sleep(3)
		#transactions = Moldtransaction.new
		# html = Nokogiri::HTML(browser.div(class: "operations").html)
		result = {
			name: parse_name,
			balance: parse_balance,
			currency: parse_currency,
			nature: parse_nature,
			transactions:[parse_transactions]
		}	
		puts result
	end

	def log_in
		browser.text_field(class: "username").set("yconnicov")
		browser.text_field(id: "password").set("12Luchita12")
		browser.button(class: "wb-button").click
	end

	def go_to_card_data
		browser.div(class: "contract-cards").click
		browser.link(id: "ui-id-2").click
		sleep(3)
		@page = Nokogiri::HTML(browser.div(id: "contract-information").html)
	end

	def parse_name
		page.css('tr')[-3].css('td')[1].text    
	end

	def parse_balance
		page.css('tr')[-1].css('td')[1].css('span')[0].text
	end

	def parse_currency
		page.css('tr')[-1].css('td')[1].css('span')[1].text
	end

	def parse_nature
		page.css('tr')[3].css('td')[1].text.gsub("2. De baza - ", "")
	end

	def go_to_transaction_data
		browser.link(href: "#contract-history").click
	 	browser.text_field(class: %w(filter-date from maxDateToday hasDatepicker)).click
	 	sleep(3)
	  	browser.link(class: %w(ui-datepicker-prev ui-corner-all)).click
	  	sleep(3)
	  	browser.link(class: "ui-state-default").click
	end

	def parse_transactions
		transaction_list = browser.div(class: "operations").lis 
		transaction_list.each do |li|
			li.link.click
			sleep(3)
			@trans = Nokogiri::HTML.parse(browser.div(class: "operation-details-body").html)
			@desc_trans = Nokogiri::HTML.parse(browser.div(class: "operation-details-header").html)
			list = {
				data: trans.css('.operation-details-body').css('.details-section')[0].css('.value')[0].text,
				description: desc_trans.css('.operation-details-header').text,
				amount: trans.css('.details-section.amounts').css('.value')[0].text
				}
			browser.send_keys :escape
		end
	end

	# def parse_data#(html)
	# 	trans.css('.operation-details-body').css('.details-section')[0].css('.value')[0].text
	# end

	# def parse_description
	# 	trans.css('.operation-details-header').text
	# end

	# def parse_amount
	# 	trans.css(%w(.details-section amounts)).css('.value')[0].text
	# end

end


webbanking = Moldindconbank.new	
puts webbanking.collect_data

