# ITERATION 0
# puts 'Event Manager Initialized!'

# if File.exist?('event_attendees.csv')
#   # contents = File.read('event_attendees.csv')
#   # puts contents
#   lines = File.readlines('event_attendees.csv')
#   lines.each_with_index do |line,index|
#     next if index == 0
#     columns = line.split(",")
#     name = columns[2]
#     puts name
#   end
# end

# ITERATION 1
# require 'csv'
# puts 'EventManager initialized.'

# contents = CSV.open(
#   'event_attendees.csv',
#   headers: true,
#   header_converters: :symbol
# )

# contents.each do |row|
#   name = row[:first_name]
#   zipcode = row[:zipcode]
#   puts "#{name} #{zipcode}"
# end

# ITERATION 2

# require 'csv'

# def clean_zipcode(zipcode)
#   zipcode.to_s.rjust(5, '0')[0..4]
# end

# puts 'EventManager initialized.'

# contents = CSV.open(
#   'event_attendees.csv',
#   headers: true,
#   header_converters: :symbol
# )

# contents.each do |row|
#   name = row[:first_name]

#   zipcode = clean_zipcode(row[:zipcode])

#   puts "#{name} #{zipcode}"
# end

# ITERATION 3

# require 'csv'
# require 'google/apis/civicinfo_v2'


# def clean_zipcode(zipcode)
#   zipcode.to_s.rjust(5, '0')[0..4]
# end

# def legislators_by_zipcode(zip)
#   civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
#   civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

#   begin
#     legislators = civic_info.representative_info_by_address(
#       address: zip,
#       levels: 'country',
#       roles: ['legislatorUpperBody', 'legislatorLowerBody']
#     )
#     legislators = legislators.officials
#     legislator_names = legislators.map(&:name)
#     legislator_names.join(", ")
#   rescue
#     'You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials'
#   end
# end

# puts 'EventManager initialized.'

# contents = CSV.open(
#   'event_attendees.csv',
#   headers: true,
#   header_converters: :symbol
# )

# contents.each do |row|
#   name = row[:first_name]

#   zipcode = clean_zipcode(row[:zipcode])

#   legislators = legislators_by_zipcode(zipcode)

#   puts "#{name} #{zipcode} #{legislators}"
# end

# ITERATION 4

require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5,"0")[0..4]
end

def clean_phone(phone)
  phone.to_s
  if phone.length == 10
    phone
  elsif phone.length == 11 && phone[0] == "1"
    phone.slice!(0)
  else
    "0000000000"
end

def legislators_by_zipcode(zip)
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

  begin
    civic_info.representative_info_by_address(
      address: zip,
      levels: 'country',
      roles: ['legislatorUpperBody', 'legislatorLowerBody']
    ).officials
  rescue
    'You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials'
  end
end

def save_thank_you_letter(id,form_letter)
  Dir.mkdir('output') unless Dir.exist?('output')

  filename = "output/thanks_#{id}.html"

  File.open(filename, 'w') do |file|
    file.puts form_letter
  end
end

puts 'EventManager initialized.'

contents = CSV.open(
  'event_attendees.csv',
  headers: true,
  header_converters: :symbol
)

template_letter = File.read('form_letter.erb')
erb_template = ERB.new template_letter

contents.each do |row|
  id = row[0]
  name = row[:first_name]
  zipcode = clean_zipcode(row[:zipcode])
  legislators = legislators_by_zipcode(zipcode)

  form_letter = erb_template.result(binding)

  save_thank_you_letter(id,form_letter)
end
