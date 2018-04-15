require_relative './spec_helper'
require_relative '../moldindconbank.rb'

RSpec.describe Moldindconbank do
let(:file) { File.open("./operations.html","r") { |f| f.read } }
let(:page) { Nokogiri::HTML.fragment(file).css("#contract-information") }

let(:fileNew) { File.open("./transactions.html","r") { |f| f.read } }
let(:body) { Nokogiri::HTML.fragment(fileNew).css(".operation-details-body") }
let(:header) { Nokogiri::HTML.fragment(fileNew).css(".operation-details-header") }

	before do
	expect(Watir::Browser).to receive(:new).and_return("OK")	
	end

	context "Parsing accounts information" do
		it "parse_name" do
			expect(subject.send(:parse_name, page)).to eq("Iana Connicov")
		end

		it "parse_nature" do
			expect(subject.send(:parse_nature, page)).to eq("MasterCard Standard Contactless")
		end

		it "parse_currency" do
			expect(subject.send(:parse_currency, page)).to eq("USD")
		end

		it "parse_balance" do
			expect(subject.send(:parse_balance, page)).to eq("0,51")
		end
	end

	context "Parsing( transactions information" do
		it "parse_data" do
			expect(subject.send(:parse_data, body)).to eq("13 aprilie 2018 15:38")
		end

		it "parse_description" do
			expect(subject.send(:parse_description, header)).to eq("Transfer între carduri MasterCard 535113******9700")
		end

		it "parse_amount" do
			expect(subject.send(:parse_amount, body)).to eq("500,00 USD")
		end
	end

end