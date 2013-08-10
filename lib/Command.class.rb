class Command

######
#####
####
###
##
# Accept a command and digest it 

  def initialize (command)
    data = command.split(/ /)
    if data[0].nil? 
      $message_handler.add('nocommand')
    else
      case
      when data[0].length == 1 && data[0] =~ /(N|E|W|S)/  
        self.go(data[0])
      when data[0].length == 1 && data[0] =~ /I/
        self.inventory
      when data[0].length == 1 && data[0] =~ /Q/
        self.quit
      when data[0].downcase =~ /^go/
        self.go(data[1])
      when data[0].downcase =~ /^inven/
        self.inventory
      when data[0].downcase =~ /^(quit|exit)/
        self.quit
      when data[0].downcase =~ /^(get|fetch|grab|take)/
        myobject = Item.whatis(data[1].downcase)
        if myobject.nil? || myobject == ''
          $message_handler.add('take_noobject')
        else
          if $inventory.present?(myobject)
            $message_handler.add('take_already_taken')
          elsif not $map.room.inventory.present?(myobject)
            $message_handler.add('take_noobject')
          else
            self.take(myobject)
          end
        end

      when data[0].downcase =~ /^(look|exam)/ 
        data.each {|x| x = x.downcase}
        if data[1].nil? || data[1] == ''
          self.look($map.room)
        else
          if data[1].downcase =~ /at/ 
            data[1] = data[2]
          end
          myobject = Item.whatis(data[1].to_s)
          if myobject.nil? || myobject == ''
            $message_handler.add('look_noobject')
          else
            if $inventory.present?(myobject)
              self.look(myobject)
            else
              $message_handler.add('look_nolook')
            end
          end
        end
      when data[0].downcase =~ /^use/
        data.each{|x| x = x.downcase}
        if data[2] =~ /^(with|on|at)/
          data[2] = data[3]
        end
        if data[1].nil?
          $message_handler.add('use_noobject')
        else
          if data[2].nil?
            $message_handler.add('use_nohelper')
          else
            myobject = Item.whatis(data[1])
            if myobject.nil?
              $message_handler.add('use_object_unknown')
            else
              if data[2] =~ /^door/
                if $map.room.doors.length == 0
                  $message_handler.add('door_nodoor')
                else
                  answer = $map.room.doors[0].open(myobject)
                end
              end
            end
          end
          
        end
 
#        when data[0].downcase =~ /^help/ || data[0].downcase =~ /^command/
#          ['help', 'help_command', nil]
      else $message_handler.add('nocommand')
      end 
    end
    $message_handler.commit
  end
  attr_reader :verb, :object, :helper
  attr_writer :verb, :object, :helper

######
####
###
##
# Commands
##
###
####
######

######
#####
####
###
##
# look
#
  def look(object)
    answer = nil
    object.look
    if object.look_text.nil? || object.look_text == ''
      object.look_text = object.info
    end
    $message_handler.add('look_looking')
    $message_handler.add_message(object.look_text)
    object.events.each{|e| e.check}
    true
  end

######
#####
####
###
##
# go
#
  def go(direction)
    direction = direction[0,1].upcase
    if direction =~ /(N|E|W|S)/
      answer = $map.go(direction)
      if answer
        $message_handler.new_screen
        $message_handler.add_message(
          Message.text('go_going') +
          case direction
            when /N/: Message.text('go_north')
            when /S/: Message.text('go_south')
            when /E/: Message.text('go_east')
            when /W/: Message.text('go_west')
          end + '...'
        )
        $map.room.events.each{|e| e.check}
        $message_handler.add_message($map.room.info)
      else
        $message_handler.add('go_nogo')
      end
    else
      $message_handler.add('go_nogo')
    end
  end

######
#####
####
###
##
# inventory
#
  def inventory
#    $message_handler.new_screen
    $message_handler.add('inventory')
    $message_handler.add_message($inventory.list.join("\n"))
#    $message_handler.commit
  end

######
#####
####
###
##
# take
# 

  def take (object)
#puts object.to_s  
#    $message_handler.new_screen
    $message_handler.add_message(Message.text('take_taking') + ' ' + object.name)
    $inventory.add(object)
    $map.room.inventory.withdraw(object)
  end

  
######
#####
####
###
##
# quit
#
  def quit
    $message_handler.pass_message(Message.text('quit'), '')
    exit  
  end

end
