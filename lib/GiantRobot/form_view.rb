require 'watir'
require 'webdrivers'

module GiantRobot

  class FormView
    class FormViewError < Exception; end

    PAGE = 'https://csb-idv4r.netlify.com/'

    def initialize
      @browser = Watir::Browser.new
    end

    def home
      @browser.goto PAGE
    end

    # Setting code

    TEXT_NAMES = {
        addr1: 'address1',
        addr2: 'address2',
        city: 'city',
        zip: 'zipCode',
        phone: 'phone',
        email: 'email',
        dob_month: 'dobMonth',
        dob_day: 'dobDay',
        dob_year: 'dobYear',
    }



    def set_text(attr, value)
      @browser.text_field(name: TEXT_NAMES[attr]).set value
    end

    def set_state(value)
      @browser.select(name: 'state').select value
    end

    def set(attributes)
      TEXT_NAMES.keys.each do |text_key|
        set_text(text_key, attributes[text_key]) if attributes.key? text_key
      end

      if attributes.key? :state
        set_state attributes[:state]
      end
    end

    def submit
      @browser.button(type: 'submit').click
    end

    # Validation

    LOCATORS = {
        addr1: 'Address 1',
        addr2: 'Address 2',
        city: 'City',
        state: 'State',
        zip: 'Zip Code',
        phone: 'Phone',
        email: 'Email',
        dob_month: 'Dob Month',
        dob_day: 'Dob Day',
        dob_year: 'Dob Year',
    }

    def get_text_value(locator)
      all_text = @browser.h4(text: locator).parent.text
      (selector_match, value) = all_text.split("\n")
      return value if selector_match.downcase == locator.downcase
      raise FormViewError.new("get_value helper is broken looking for #{selector} got #{selector_match}")
    end

    def get
      model = {}
      LOCATORS.keys.each do |key|
        model[key] = get_text_value(LOCATORS[key])
      end
      model
    end

    # Continue and return true if it was saved
    def continue
      @browser.button(text: 'Continue').click
      @browser.h1(text: 'Success!').present?
    end

    def start_over
      #browser.button(text: 'Start over').click
    end

  end
end