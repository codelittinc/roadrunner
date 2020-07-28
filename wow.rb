require 'date'

end_date = DateTime.now.next_day(128)

start_date = DateTime.now

n = 0.0
(start_date..end_date).each do |d|
  n += 2 unless [0, 1, 6].include?(d.wday)
end

puts start_date
puts end_date

puts (n + 5) / 30
