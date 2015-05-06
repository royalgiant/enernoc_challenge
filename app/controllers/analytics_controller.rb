class AnalyticsController < ApplicationController

	def index
		# Paginate the number of data rows
		@analytics = Analytic.paginate(page: params[:page])
	end

	def stats
		# Number of unique customers count
		@number_unique_customers = Analytic.select(:custid).distinct.count
		
		@elec = Analytic.uniq.where(elec_gas: 1).pluck(:custid) # Get parameters for all unique customers that uses electricity
		@gas = Analytic.uniq.where(elec_gas: 2).pluck(:custid) # Get parameters for all unique customers that uses gas
		
		# Customers - Electricity and Gas
		@elec_and_gas = both_elec_and_gas(@elec, @gas)
		@elec_only = elec_only(@elec_and_gas, @elec) # Customers - Electricty Only
		@gas_only = gas_only(@elec_and_gas, @gas) # Customers - Gas Only

		@consumption_elec = avg_consumption(1, @elec_only.count + @elec_and_gas.count) #Average consumption per bill month per resource across all customers of the resource
		@consumption_gas = avg_consumption(2, @gas_only.count + @elec_and_gas.count) #Average consumption per bill month per resource across all customers of the resource
		@meter_read_elec = meter_readings(1) # Meter reading breakdown per customer by electricity
		
		@meter_read_gas = meter_readings(2) # Meter reading breakdown per customer by gas
	end

	def import
		# Let's uncompress the gzip file into a string
		uncompressed = ActiveSupport::Gzip.decompress(params[:file].read) 
		# Split up the string based on the \n break and assign the array to dataRows
		dataRows = uncompressed.split(/\r?\n/)
		# Let's drop the headers in array[0] since it contains "custid|ElecOrGas|..."
		dataRows = dataRows.drop(1)
		# Keep the bad data in an array
		@bad_data = Array.new
		# Loop through each row and insert data into database
		dataRows.each do |row|
			row_data = row.split("|") # Split up the pipe delimited string
			begin
				# Find if the row of data exists in DB, else create it
				Analytic.find_or_create_by({
				custid: row_data[0].to_i,
				elec_gas: row_data[1].to_i,
				disconnect_doc: row_data[2],
				move_in_date: row_data[3].to_i,
				move_out_date: row_data[4].to_i,
				bill_year: row_data[5].to_i,
				bill_month: row_data[6].to_i,
				span_days: row_data[7].to_i,
				meter_read_date: row_data[8].to_i,
				meter_read_type: row_data[9],
				consumption: row_data[10].to_i,
				exception_code: row_data[11]
			})
			rescue Exception => e
				@bad_data.push(row_data) # Push the bad data into the @bad_data array
			end
		end
		flash[:warning] = !@bad_data.empty? ? @bad_data : nil
		if flash[:warning].nil? 
			flash[:success] = "Data successfully imported"
		end
		redirect_to root_path
	end

	private 

	# returns an array of custid's that uses both elec and gas
	def both_elec_and_gas(elec, gas)
		elec_gas = Array.new
		gas.each do |g|
			if elec.to_a.include?(g)
				elec_gas << g
			end
		end
		return elec_gas
	end
	# returns an array of custid's that uses gas only 
	def gas_only(electricity_gas, gas)
		electricity_gas.each do |eg|
			if gas.include?(eg)
				gas.delete(eg)
			end
		end
		return gas
	end
	# returns an array of custid's that uses elec only
	def elec_only(electricity_gas, elec)
		electricity_gas.each do |eg|
			if elec.include?(eg)
				elec.delete(eg)
			end
		end
		return elec
	end
	# calculates the avg consumption for each month
	def avg_consumption(elec_or_gas, number_customers)
		i = 1
		consumption_per_month = Array.new
		# Loop through all 12 months.
		while i < 13 do
			# Get the sum of consumption for a specific month for a specific resource
			consumption = Analytic.where({elec_gas: elec_or_gas, bill_month: i}).sum(:consumption)
			# Divide by number of unique customers for the resource across the board
			consumption_per_month << (consumption/number_customers.to_f)
			i = i + 1 
		end
		# Give me back the array of averages
		return consumption_per_month
	end

	# returns breakdown of meter readings per customer, split by electricity and gas
	def meter_readings(elec_gas)
		group_custid = Analytic.group(:custid).where(elec_gas: elec_gas).count
		max_number_of_readings = group_custid.max_by { |g| g[1]} # Give me the most readings by a unique customer
		min_number_of_readings = group_custid.min_by { |g| g[1]} # Give me the minimum readings by a unique customer
		return [group_custid, max_number_of_readings[1], min_number_of_readings[1]]
	end
end
