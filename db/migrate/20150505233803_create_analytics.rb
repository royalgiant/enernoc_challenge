class CreateAnalytics < ActiveRecord::Migration
  def change
    create_table :analytics do |t|
    	t.integer :custid
    	t.integer :elec_gas
    	t.string :disconnect_doc
    	t.integer :move_in_date
    	t.integer :move_out_date
    	t.integer :bill_year
    	t.integer :bill_month
    	t.integer :span_days
    	t.integer :meter_read_date
    	t.string :meter_read_type
    	t.integer :consumption
    	t.string :exception_code
      	t.timestamps null: false
    end
  end
end
