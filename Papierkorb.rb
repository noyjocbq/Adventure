    File.open(mapfile) do |map_file|
      map_file.each do |line|
        line = line.chomp
        if line =~ /\|/ and line !~ /^\#/
          data = line.split(/\|/)
          if line =~ /MAX_INDEX/ 
            @@MAX_INDEX  = [ data[1].to_i, data[2].to_i ] 
          elsif line =~ /START_ROOM/
            @@START_ROOM = [ data[1].to_i, data[2].to_i ]
          else
            @room[ [data[0].to_i, data[1].to_i] ] = Room.new(data[2], data[3])
          end
        end
      end
    end
#-------------------------------
#
#-------------------------------
##
#puts event.class
#
#    puts @condition
#    puts "Zu manipulierendes Objekt: #{@object}"
#    puts "Wert von Associated: #{@associated}"
#    puts "Ich: #{self}"
#    puts "Wert, den ich haben will:" + @associated.info
#    puts "Versuch, den zu kriegen: " + eval ('@associated.' + @object)
#    puts "Condition: #{@condition}"



#    if eval('@associated.' + @condition)
#puts "Still alive"
#puts @command
#      answer = case 
#      if @command == "replace" 
#        eval('@associated.' + @object + ' = ' + @second_object).to_s
#        puts '@associated.' + @object + " = %q{" + @second_object + "} "
#        puts eval ('@associated.' + @object + " = %q{" + @second_object + "} ")
#        puts "Answer: ###" + answer.to_s + "***"
#      end
#    end
    
  



