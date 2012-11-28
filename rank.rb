require 'csv'
require 'pp'

csv_path = ARGV.first

exit if csv_path.nil?

csv = CSV.read(csv_path)

head = csv.shift

hashes = []

csv.each do |line|
  hash = {}
  head.each_with_index do |key, index|
    hash[key] = line[index]
  end

  hashes << hash
end

grades = {}


hashes.each do |note|
  grade = 0

  # loan_amnt
  bonus = 0
  amount = note['loan_amnt'].to_i

  bonus += if amount < 25000

  grade += bonus

  # int_rate
  bonus = 0
  rate = note['int_rate'].to_f

  bonus += 1 if rate > 10
  bonus += 1 if rate > 12
  bonus += 1 if rate > 13
  bonus = 0 if rate > 14.5

  grade += bonus

  # sub_grade
  sub_grade = note['sub_grade']
  bonus = 0

  bonus += 1 if sub_grade < 'E'
  bonus += 1 if sub_grade < 'D'
  bonus += 1 if sub_grade < 'C'
  bonus += 1 if sub_grade < 'B'
  bonus += 1 if sub_grade < 'A'
  bonus = 0  if sub_grade >= 'E'

  # emp_length
  bonus = 0
  emp_length = note['emp_length']

  emp_length = 0 if emp_length == '< 1 year' || emp_length == 'n/a'
  emp_length = emp_length.to_i

  bonus += emp_length/2 # ints floor

  # home_ownership
  bonus = 0
  home_ownership = note['home_ownership']

  bonus += 2 if home_ownership == 'OWN'
  bonus += 1 if home_ownership == 'MORTGAGE'

end
