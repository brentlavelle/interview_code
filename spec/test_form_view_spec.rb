require 'rspec'
require_relative '../lib/GiantRobot/form_view'

DEFALT_MODEL = {
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
      @robot_form.set DEFALT_MODEL
      @robot_form.submit
      expect(@robot_form.get).to eq(DEFALT_MODEL)
      expect(@robot_form.continue).to be true
    end

    it 'omit address 2' do
      model = DEFALT_MODEL
      model.delete :addr2
      @robot_form.set DEFALT_MODEL
      @robot_form.submit
      expect(@robot_form.get).to eq(DEFALT_MODEL)
      expect(@robot_form.continue).to be true
    end
  end
end