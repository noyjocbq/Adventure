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
  
        when data[0].downcase =~ /^look/ :
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
        when data[0].downcase =~ /^help/ || data[0].downcase =~ /^command/
          ['help', 'help_command', nil]
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
#puts "Still alive 01"    
    $message_handler.add('look_looking')
    $message_handler.add_message(object.look_text)
    object.events.each{|e| e.check}
#    answer = $message_handler.commit
#    answer
  end
#    $message_handler.pass_message(@object.look_text)

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
      $message_handler.new_screen
      $message_handler.add_message($map.go(direction))
      $map.room.events.each{|e| e.check}
      $message_handler.add_message($map.room.info)
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
    exit  
  end

end
