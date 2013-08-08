=begin
=end
from_file = 'map.txt'
to_file = 'map.xml'

input = File.open(from_file)
output = File.open(to_file, 'w')
output.write <<EOF
<Map name = "Testmap">
EOF
indata = input.read()
indata.each do |line|
  outline = "";
  line = line.chomp
  if line =~ /\|/ and line !~ /^\#/
    data = line.split(/\|/)
    if line =~ /MAX_INDEX/ 
      outline << <<EOF
<variable name=\"MAX_INDEX\" value = \"#{data[1]}|#{data[2]}\"\/>
EOF
    elsif line =~ /START_ROOM/
      outline << <<EOF
<variable name = "START_ROOM" value = "#{data[1]}|#{data[2]}"/>
EOF
    else 
      outline << <<EOF
<room location = "#{data[0]}|#{data[1]}">
  <exits>#{data[2]}</exits>
  <info>#{data[3]}</info>
</room>
EOF
    end
    output.write(outline)
  end
end
output.write <<EOF
</Map>
EOF

