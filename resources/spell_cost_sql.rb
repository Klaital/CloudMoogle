
puts "INSERT INTO spells VALUES "
vals = []
File.readlines("spell_cost.txt").each do |line|
    tokens = line.strip.split(/\t/)
    vals << "(NULL, '" + tokens[0] + "', " + tokens[1] + ")"
end

puts vals.join(", \n")
