require 'watir'
require 'nokogiri'
require 'json'
require 'time'
require 'pry'

class Moldindconbank

	attr_reader :browser
	def initialize
		@browser = Watir::Browser.new(:chrome)                      
	end

	def collect_data
		log_in
		sleep(2)
		parse_accounts
	end

	def log_in
		browser.goto("https://wb.micb.md/")
		puts "Write your Username: "
		browser.text_field(class: "username").set(gets.chomp)
		puts "Write your Password: "
		browser.text_field(id: "password").set(gets.chomp)
		browser.button(class: "wb-button").click
		#
	end

	def parse_accounts	
		accounts = browser.divs(class: %w(contract status-active))
 		accounts_info = accounts.map do |element|
			Watir::Wait.until { element.div(class: "contract-cards").a.present? }
			element.div(class: "contract-cards").a.click
			go_to_card_info
			page = Nokogiri::HTML(browser.div(id: "contract-information").html)
			go_to_transaction_info
			result = {
					name: parse_name(page),
					balance: parse_balance(page),
					currency: parse_currency(page),
					description: parse_nature(page),
					transactions: parse_transactions(&:to_hash)
			}	
			browser.li(class: %w(new_cards_accounts-menu-item active)).a.click
			result
		end
		log_out
		JSON.pretty_generate( accounts: accounts_info )
	end

	def go_to_card_info
		browser.ul(class: %w(ui-tabs-nav ui-helper-reset ui-helper-clearfix ui-widget-header ui-corner-all)).lis[1].click
	end

	def parse_name(page)
		page.css('tr')[-3].css('td')[1].text    
	end

	def parse_balance(page)
		page.css('tr')[-1].css('td')[1].css('span')[0].text
	end

	def parse_currency(page)
		page.css('tr')[-1].css('td')[1].css('span')[1].text
	end

	def parse_nature(page)
		page.css('tr')[3].css('td')[1].text.gsub("2. De baza - ", "")
	end

	def go_to_transaction_info
		browser.link(href: "#contract-history").click
	 	browser.text_field(class: %w(filter-date from maxDateToday hasDatepicker)).click
	 	Watir::Wait.until { browser.link(class: %w(ui-datepicker-prev ui-corner-all)).present? }
	  browser.link(class: %w(ui-datepicker-prev ui-corner-all)).click
	  sleep(2)
	  Watir::Wait.until { browser.link(class: "ui-state-default").present? }
	  browser.link(class: "ui-state-default").click
	end

	def parse_transactions
		Watir::Wait.until { browser.div(class: "operations").li.present? }
		transaction_list = browser.div(class: "operations").lis 
		list = transaction_list.map do |li|
			Watir::Wait.until { li.link.present? }
			li.link.click
			transaction = Nokogiri::HTML.parse(browser.div(class: "operation-details-body").html)
			describe_transaction = Nokogiri::HTML.parse(browser.div(class: "operation-details-header").html)
			browser.send_keys :escape
			Moldtransaction.new(
				parse_data(transaction),
				parse_description(describe_transaction),
				parse_amount(transaction)
			).to_hash
		end
	end

	def parse_data(transaction)
		transaction.css('.operation-details-body').css('.details-section')[0].css('.value')[0].text
	end

	def parse_description(describe_transaction)
		describe_transaction.css('.operation-details-header').text.gsub("  ", "")
	end

	def parse_amount(transaction)
		transaction.css('.details-section.amounts').css('.value')[0].text
	end

	def log_out
		browser.span(class: "logout-link-wrapper").click
	end

end

class Moldtransaction

	attr_reader :date, :description, :amount
	def initialize(date, description, amount)
		@date = Time.parse(date)
		@description = description
		@amount = amount
	end

	def to_hash	
		{
			date: @date,
			description: @description,
			amount: @amount
		}
	end

end

if __FILE__ == $0
webbanking = Moldindconbank.new	
puts webbanking.collect_data
end