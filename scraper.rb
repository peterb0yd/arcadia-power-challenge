require 'selenium-webdriver'
require 'nokogiri'
require 'yaml'

# keep locally only
config = YAML::load_file 'config.yml'
account = config["account"]

# format date in readable format
def format_date(date)
  return date.strftime('%B %-d, %Y')
end

# get parsable Nokogiri from id
def get_html_by_id(driver, elem_id)
  elem = driver.find_element(id: elem_id)
  return get_html(elem)
end

# get parsable Nokogiri from class
def get_html_by_class(driver, elem_class)
  elem = driver.find_element(class: elem_class)
  return get_html(elem)
end

# get parsable Nokogiri from DOM elem
def get_html(elem)
  raw_html = elem.attribute('innerHTML')
  return Nokogiri::HTML(raw_html)
end

# parse table data into objects
def get_table_objects(html)
  # get table headers
  headers = []
  html.xpath('//*/tr/th').each do |th|
    headers << th.text
  end

  # get table rows
  rows = []
  html.xpath('//*/tbody/tr').each_with_index do |row, i|
    rows[i] = {}
    row.xpath('td').each_with_index do |td, j|
      rows[i][headers[j]] = td.text.gsub("\n", "").strip
    end
  end
  rows.shift
  return rows
end

# initialize geckodriver
driver = Selenium::WebDriver.for :firefox
driver.navigate.to "http://dominionenergy.com"

# fill in username input
user_input = driver.find_element(id: 'user')
user_input.send_keys account["username"]

# fill in password input
pw_input = driver.find_element(id: 'password')
pw_input.send_keys account["password"]
pw_input.submit

# submit form
form_button = driver.find_element(id: 'SignIn')
form_button.click

# --- CHANGE PAGE ---
# --- now on the 'Home' page

# get account name
account_name_html = get_html_by_id(driver, 'account-summary-info-accountname')
account_name = account_name_html.text.strip

# get due date
latest_bill_due_date_html = get_html_by_class(driver, 'bodyTextGreen')
latest_bill_due_date = latest_bill_due_date_html.text

# go to analyze page
driver.find_element(id: 'AnalyzeEnergyUsage_liId').click

# --- CHANGE PAGE ---
# --- now on the 'Analyze Energy Usage' page

# grab inner html from tables
bills_html = get_html_by_id(driver, 'billHistoryTable')
payments_html = get_html_by_id(driver, 'paymentsTable')

# parse html into array and grab first object
latest_bill_data = get_table_objects(bills_html)[0]
latest_payment_data = get_table_objects(payments_html)[0]

# populate bill data
meter_read_date = Date.strptime(latest_payment_data["Meter Read Date"], '%m/%d/%Y')
meter_days = latest_payment_data["Days"].to_i
service_start_date = format_date (meter_read_date - meter_days)
service_end_date = format_date meter_read_date
bill_usage = latest_payment_data["Usage"]
bill_amount = latest_bill_data["Bill Amount"]
bill_due_date = latest_bill_due_date

# print latest bill data
puts "\n Latest billing info for #{account_name}:"
puts "\n#{'Service Start Date'.rjust(20)}:\t#{service_start_date}\n"
puts "#{'Service End Date'.rjust(20)}:\t#{service_end_date}\n"
puts "#{'Usage (kWh)'.rjust(20)}:\t#{bill_usage}\n"
puts "#{'Amount'.rjust(20)}:\t#{bill_amount}\n"
puts "#{'Due Date'.rjust(20)}:\t#{bill_due_date}\n\n"

driver.quit
