require 'csv'
require 'pp'
states_income = {"AL"=>42590,
 "AK"=>57431,
 "AZ"=>48621,
 "AR"=>41302,
 "CA"=>53367,
 "CO"=>58629,
 "CT"=>65415,
 "DE"=>54660,
 "FL"=>45105,
 "GA"=>45973,
 "HI"=>59047,
 "ID"=>47459,
 "IL"=>50637,
 "IN"=>44445,
 "IA"=>50219,
 "KS"=>46147,
 "KY"=>39856,
 "LA"=>40658,
 "ME"=>49693,
 "MD"=>68876,
 "MA"=>63313,
 "MI"=>48879,
 "MN"=>57820,
 "MS"=>41090,
 "MO"=>45774,
 "MT"=>40277,
 "NE"=>55616,
 "NV"=>47043,
 "NH"=>65880,
 "NJ"=>62338,
 "NM"=>41982,
 "NY"=>50636,
 "NC"=>45206,
 "ND"=>56361,
 "OH"=>44648,
 "OK"=>48455,
 "OR"=>51526,
 "PA"=>49910,
 "RI"=>49033,
 "SC"=>40084,
 "SD"=>47223,
 "TN"=>42279,
 "TX"=>49047,
 "UT"=>55493,
 "VT"=>51862,
 "VA"=>62616,
 "WA"=>56850,
 "WV"=>41821,
 "WI"=>52058,
 "WY"=>54509}


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

  bonus += 1 if amount < 25000

  grade += bonus

  # int_rate
  bonus = 0
  rate = note['int_rate'].to_f

  bonus += 2 if rate > 10
  bonus += 2 if rate > 12
  bonus += 3 if rate > 13
  bonus = 0 if rate > 14.5

  grade += bonus

  # sub_grade
  sub_grade = note['sub_grade']
  bonus = 0

  bonus -= 1 if sub_grade < 'E'
  bonus += 2 if sub_grade < 'D'
  bonus += 3 if sub_grade < 'C'
  bonus += 2 if sub_grade < 'B'
  bonus -= 5 if sub_grade < 'A'
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

  # annual_inc
  bonus = 0
  annual_inc = note['annual_inc'].to_f
  state = note['addr_state']

  inc_ratio = annual_inc / states_income[state].to_f
  bonus += 1 if inc_ratio >= 1
  bonus += 2 if inc_ratio >= 1.5
  bonus += 3 if inc_ratio >= 2
  bonus += 5 if inc_ratio >= 3
  bonus -= 5 if inc_ratio < 1
  grade += bonus

  # acc_now_delinq
  acc_now_delinq = note['acc_now_delinq'].to_i

  grade = -1000 if acc_now_delinq > 0

  # delinq_2yrs
  delinq_2yrs = note['delinq_2yrs'].to_i

  grade -= 10 if delinq_2yrs > 0

  # fico_range_low / fico_range_high
  fico_range_low = note['fico_range_low'].to_f
  fico_range_high = note['fico_range_high'].to_f
  fico_range_mean = ((fico_range_high + fico_range_low)/2.0).to_i
  bonus = 0

  bonus = -10 if fico_range_mean < 675
  bonus += 3 if fico_range_mean >= 675
  bonus += 1 if fico_range_mean >= 700
  bonus += 1 if fico_range_mean >= 750

  grade += bonus

  grades[note['id']] = grade
end

pp grades.sort_by{|k, v| v}
