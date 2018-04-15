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

