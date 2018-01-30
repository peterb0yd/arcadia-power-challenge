require 'mechanize'

agent = Mechanize.new

ap_link = 'https://www.dominionenergy.com'

agent.get(ap_link) do |home_page|

  puts home_page.title

  form = home_page.form_with(action: "/")

  form.user = '###'
  form.password = '###'

  user_page = form.submit

  pp user_page.body

  # pull data

end
