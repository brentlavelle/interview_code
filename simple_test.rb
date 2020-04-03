require 'watir'
require 'webdrivers'

module Helper
  def Helper.get_value(browser, selector)
    all_text = browser.h4(text: selector).parent.text
    (selector_match, value) = all_text.split("\n")
    return value if selector_match.downcase == selector.downcase
    raise Exception.new("get_value helper is broken looking for #{selector} got #{selector_match}")
  end
end

PAGE = 'https://csb-idv4r.netlify.com/'

browser = Watir::Browser.new

# Navigate
browser.goto PAGE

# Fill out form
browser.text_field(name: 'address1').set '1100 Congress Ave'
browser.text_field(name: 'address2').set 'unit B'
browser.text_field(name: 'city').set 'Austin'
browser.select(name: 'state').select 'TX'
browser.text_field(name: 'zipCode').set '78701'
browser.text_field(name: 'phone').set '512-555-1212'
browser.text_field(name: 'email').set 'name@example.com'
browser.text_field(name: 'dobMonth').set '01'
browser.text_field(name: 'dobDay').set '01'
browser.text_field(name: 'dobYear').set '2000'
browser.button(type: 'submit').click

# read from the landing page

[
    'Address 1',
    'Address 2',
    'City',
    'State',
    'Zip Code',
    'Phone',
    'Email',
    'Dob Month',
    'Dob Day',
    'Dob Year',
].each do |attr|
  value = Helper::get_value(browser, attr)
  print "#{attr}: '#{value}'\n"
end

# leave the page
browser.button(text: 'Continue').click

# make sure it was saved
if browser.h1(text: 'Success!').visible?
  print("Saved\n")
else
  print("Something went wrong\n")
end
browser.button(text: 'Start over').click


browser.close
