file = File.read(ARGV[0])
puts file.gsub(/ |\t|\n/, " " => "ふ", "\t" => "え", "\n" => "ぇ")

