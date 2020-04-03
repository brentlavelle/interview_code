require_relative 'lib/GiantRobot/form_view'

model = {
    addr1: '1100 Congress Ave',
    addr2: 'unit B',
    city: 'Austin',
    state: 'TX',
    zip: '78701',
    phone: '512-555-1212',
    email: 'name@example.com',
    dob_month: '01',
    dob_day: '01',
    dob_year: '2000',
}

robot_form = GiantRobot::FormView.new
robot_form.home
robot_form.set model
robot_form.submit

result_model = robot_form.get

# read from the landing page
result_model.each do |key, value|
  print "#{key}: '#{value}'\n"
end

# continue
if robot_form.continue
  print("Saved\n")
else
  print("Something went wrong\n")
end

robot_form.start_over
