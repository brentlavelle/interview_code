require 'rspec'
require_relative '../lib/GiantRobot/form_view'
require 'time'
require 'faker'

DEFAULT_MODEL = {
    addr1:     '1100 Congress Ave',
    addr2:     'unit B',
    city:      'Austin',
    state:     'TX',
    zip:       '78701',
    phone:     '512-555-1212',
    email:     'name@example.com',
    dob_month: '01',
    dob_day:   '01',
    dob_year:  '2000',
}

describe 'TestFormView' do
  before do
    @robot_form = GiantRobot::FormView.new
    @robot_form.home
  end

  after do
    # @robot_form.close_browser
  end

  context 'positive tests' do
    it 'works with default model' do
      @robot_form.set DEFAULT_MODEL
      @robot_form.submit
      expect(@robot_form.get).to eq(DEFAULT_MODEL)
      expect(@robot_form.continue).to be true
    end

    it 'omit address 2' do
      model = DEFAULT_MODEL.clone
      model.delete :addr2
      @robot_form.set model
      @robot_form.submit
      expect(@robot_form.get).to eq(model)
      expect(@robot_form.continue).to be true
    end

    it 'leap day' do
      model             = DEFAULT_MODEL.clone
      model[:dob_month] = '2'
      model[:dob_day]   = '29'
      model[:dob_year]  = '2016'
      @robot_form.set model
      @robot_form.submit
      expect(@robot_form.get).to eq(model)
      expect(@robot_form.continue).to be true
    end

    it 'oldest allowed' do
      model             = DEFAULT_MODEL.clone
      model[:dob_month] = '1'
      model[:dob_day]   = '1'
      model[:dob_year]  = '1900'
      @robot_form.set model
      @robot_form.submit
      expect(@robot_form.get).to eq(model)
      expect(@robot_form.continue).to be true
    end

    it 'leading zeros in month and day' do
      model             = DEFAULT_MODEL.clone
      model[:dob_month] = '02'
      model[:dob_day]   = '04'
      model[:dob_year]  = '1950'
      @robot_form.set model
      @robot_form.submit
      expect(@robot_form.get).to eq(model)
      expect(@robot_form.continue).to be true
      # This should probably fail as the dates should be normalized
    end

    it 'can be used 3 times in a row' do
      # Possibly obsolete due to phone number tests below
      model = DEFAULT_MODEL.clone
      3.times do |time|
        model[:addr1] = "#{time} Main St"
        model[:email] = Faker::Internet.email
        @robot_form.set model
        @robot_form.submit
        expect(@robot_form.get).to eq(model)
        expect(@robot_form.continue).to be true
        @robot_form.start_over
      end
    end

    it 'can have a long addr1' do
      model         = DEFAULT_MODEL.clone
      model[:addr1] = '1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890'
      @robot_form.set model
      @robot_form.submit
      expect(@robot_form.get).to eq(model)
      expect(@robot_form.continue).to be true
    end

    it 'allows zip+4' do
      model         = DEFAULT_MODEL.clone
      model[:addr1] = '11 Wall St'
      model[:city]  = 'New York'
      model[:state] = 'NY'
      model[:zip]   = '10005-1905'
      @robot_form.set model
      @robot_form.submit
      expect(@robot_form.get).to eq(model)
      expect(@robot_form.continue).to be true
    end

    it 'allows odd characters' do
      # Note that there is not normalization
      model         = DEFAULT_MODEL.clone
      model[:addr1] = 'Mo-Pac 学中文 а, и, м, т, щ Expressway'
      @robot_form.set model
      @robot_form.submit
      expect(@robot_form.get).to eq(model)
      expect(@robot_form.continue).to be true
    end

    it 'allows for some phone number formats' do
      model         = DEFAULT_MODEL.clone
      model[:phone] = '(512)555-9876'
      @robot_form.set model
      @robot_form.submit
      expect(@robot_form.get).to eq(model)
      expect(@robot_form.continue).to be true
      @robot_form.start_over

      model[:phone] = '2125551234'
      @robot_form.set model
      @robot_form.submit
      expect(@robot_form.get).to eq(model)
      expect(@robot_form.continue).to be true
      @robot_form.start_over

      model[:phone] = '212 555 1234'
      @robot_form.set model
      @robot_form.submit
      expect(@robot_form.get).to eq(model)
      expect(@robot_form.continue).to be true

    end
  end

  context 'negative tests' do
    it 'omit address 1 and cannot submit' do
      model         = DEFAULT_MODEL.clone
      model[:addr1] = ' '
      @robot_form.set model
      expect(@robot_form.list_errors).to eq(['Please enter a valid address 1.'])
      @robot_form.submit
      expect(@robot_form.list_errors).to eq(['Please enter a valid address 1.'])
      expect(@robot_form.home?).to be(true)
    end

    it 'future birthday' do
      model            = DEFAULT_MODEL.clone
      model[:dob_year] = Time.new.year + 1
      @robot_form.set model
      expect(@robot_form.list_errors).to eq(['Please enter a valid date of birth.'])
      @robot_form.submit
      expect(@robot_form.home?).to be(true)
    end

    it 'a day too old' do
      model             = DEFAULT_MODEL.clone
      model[:dob_month] = 12
      model[:dob_day]   = 31
      model[:dob_year]  = 1899
      @robot_form.set model
      expect(@robot_form.list_errors).to eq(['Please enter a valid date of birth.'])
      @robot_form.submit
      expect(@robot_form.home?).to be(true)
    end

    it 'no letters in zip' do
      model       = DEFAULT_MODEL.clone
      model[:zip] = '1234a'
      @robot_form.set model
      expect(@robot_form.list_errors).to eq(['Please enter a zip code.'])
      @robot_form.submit
      expect(@robot_form.home?).to be(true)
    end

    it 'does not work with Puerto Rico' do
      model         = DEFAULT_MODEL.clone
      model[:addr1] = '188 Calle Estación, Boquerón'
      model[:city]  = 'Cabo Rojo'
      model[:state] = 'PR'
      model[:zip]   = '00622'

      expect { @robot_form.set model }.to raise_error(GiantRobot::FormView::FormViewError)
      @robot_form.submit
      expect(@robot_form.list_errors).to eq(['Please enter a valid state.'])
      expect(@robot_form.home?).to be(true)
    end

    it 'validates phone information missing area code' do
      model         = DEFAULT_MODEL.clone
      model[:phone] = '5559876'
      @robot_form.set model
      expect(@robot_form.list_errors).to eq(['Please enter a valid mobile phone number.'])
    end

    it 'validates phone information text' do
      model         = DEFAULT_MODEL.clone
      model[:phone] = 'I do not have one'
      @robot_form.set model
      expect(@robot_form.list_errors).to eq(['Please enter a valid mobile phone number.'])
    end

    it 'validates phone information too long' do
      model         = DEFAULT_MODEL.clone
      model[:phone] = '12355512345'
      @robot_form.set model
      expect(@robot_form.list_errors).to eq(['Please enter a valid mobile phone number.'])
    end

    it 'does not allow international numbers' do
      model         = DEFAULT_MODEL.clone
      model[:phone] = '+1 5125553434'
      @robot_form.set model
      expect(@robot_form.list_errors).to eq(['Please enter a valid mobile phone number.'])
    end

    it 'does not like an empty form - multiple errors' do
      model = {addr1: ' '}
      @robot_form.set model
      @robot_form.submit
      errors          = @robot_form.list_errors
      expected_errors = [
          'Please enter a valid address 1.',
          'Please enter a valid city.',
          'Please enter a valid state.',
          'Please enter a zip code.',
          'Please enter a valid mobile phone number.',
          'Please enter a valid email.',
          'Please enter a valid date of birth.',
      ]

      expect(errors).to match_array(expected_errors)

      @robot_form.submit
      expect(@robot_form.home?).to be(true)

    end

  end
end