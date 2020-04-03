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
      model = DEFAULT_MODEL
      model.delete :addr2
      @robot_form.set DEFAULT_MODEL
      @robot_form.submit
      expect(@robot_form.get).to eq(DEFAULT_MODEL)
      expect(@robot_form.continue).to be true
    end

    it 'leap day' do
      model             = DEFAULT_MODEL
      model[:dob_month] = 2
      model[:dob_day]   = 29
      model[:dob_year]  = 2016
      @robot_form.set DEFAULT_MODEL
      @robot_form.submit
      expect(@robot_form.get).to eq(DEFAULT_MODEL)
      expect(@robot_form.continue).to be true
    end

    it 'oldest allowed' do
      model             = DEFAULT_MODEL
      model[:dob_month] = 1
      model[:dob_day]   = 1
      model[:dob_year]  = 1900
      @robot_form.set DEFAULT_MODEL
      @robot_form.submit
      expect(@robot_form.get).to eq(DEFAULT_MODEL)
      expect(@robot_form.continue).to be true
    end

    it 'can be used 3 times in a row' do
      model = DEFAULT_MODEL
      3.times do |time|
        model[:addr1] = "#{time} Main St"
        model[:email] = Faker::Internet.email
        @robot_form.set DEFAULT_MODEL
        @robot_form.submit
        expect(@robot_form.get).to eq(DEFAULT_MODEL)
        expect(@robot_form.continue).to be true
        @robot_form.start_over
      end
    end

    it 'can have a long addr1' do
      model         = DEFAULT_MODEL
      model[:addr1] = '1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890'
      @robot_form.set DEFAULT_MODEL
      @robot_form.submit
      expect(@robot_form.get).to eq(DEFAULT_MODEL)
      expect(@robot_form.continue).to be true
    end

    it 'allows zip+4' do
      model         = DEFAULT_MODEL
      model[:addr1] = '11 Wall St'
      model[:city]  = 'New York'
      model[:state] = 'NY'
      model[:zip]   = '10005-1905'
      @robot_form.set DEFAULT_MODEL
      @robot_form.submit
      expect(@robot_form.get).to eq(DEFAULT_MODEL)
      expect(@robot_form.continue).to be true
    end

    it 'allows odd characters' do
      model         = DEFAULT_MODEL
      model[:addr1] = 'Mo-Pac 学中文 а, и, м, т, щ Expressway'
      @robot_form.set DEFAULT_MODEL
      @robot_form.submit
      expect(@robot_form.get).to eq(DEFAULT_MODEL)
      expect(@robot_form.continue).to be true
    end
  end
end