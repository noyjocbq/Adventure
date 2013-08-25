####
###
##
#  Command Module
## Accept a command and digest it
###
#### v0.6

module Command

  def standardise(data)
    data.shift
    data.each{|x| x = x.downcase}
    return data
  end

  def digest(command)
    data = command.chomp.split(/ /)
    if Map.initial?
      data = [ "look" ]
    end
    if data[0].nil?
      Messager.add('nocommand')
    else
      case
      when data[0].length == 1 && data[0] =~ /(N|E|W|S)/
        Command.go(data[0])
      when data[0].length == 1 && data[0] =~ /I/
        Command.inventory
      when data[0].length == 1 && data[0] =~ /Q/
        Command.quit
      when data[0].downcase =~ /^go/
        Command.go(data[1])
      when data[0].downcase =~ /^inven/
        Command.inventory
      when data[0].downcase =~ /^(quit|exit)/
        Command.quit
      when data[0].downcase =~ /^(get|fetch|grab|take)/
        data = standardise(data)
        Command.take(data)
      when data[0].downcase =~ /^(look|exam)/
        data = standardise(data)
        Command.look(data)
      when data[0].downcase =~ /^use/
        data = standardise(data)
        Command.use(data)
      when data[0].downcase =~ /^(drop|throw)/
        data = standardise(data)
        Command.drop(data)
      when data[0].downcase =~ /^give/
        data = standardise(data)
        Command.give(data)
      when data[0].downcase =~ /^open/
        data = standardise(data)
        Command.open(data)
      when data[0].downcase =~ /^say/
        data = standardise(data)
        Command.say(data)
      when data[0].downcase =~ /^loca/
        Command.locate
      else Messager.add('nocommand')
      end
    end
    Map.events.each {|e| check} unless Map.events.nil?
    Messager.commit
  end

#
##
###
#### Commands

  def locate
    Messager.add_message(Map.room.item_id)
  end

####
###
##
# look (at)
#
  def look_at(object)
    object.look
    Messager.new_screen
    Messager.add('look_looking')
    if object.look_text.nil? || object.look_text == ''
      Messager.add_message(object.info)
    else
      Messager.add_message(object.look_text)
    end
    object.events.each{|e| e.check} unless object.events.nil?
  end

  def look(data)
    if data[0].nil? || data[0] == ''
      look_at(Map.room)
    else
      if data[0] =~ /at/
        data[0] = data[1]
      end
      myobject = Item.whatis(data[0].to_s)
      if myobject.nil? || myobject == ''
        Messager.add('look_noobject')
      else
        if Map.inventory.present?(myobject) || Map.room.inventory.present?(myobject)
          look_at(myobject)
        else
          Messager.add('look_nolook')
        end
      end
    end
  end

####
###
##
# go
#
  def Command.go(direction)
    direction = direction[0,1].upcase
    if direction =~ /(N|E|W|S)/
      answer = Map.go(direction)
      if answer
        Messager.new_screen
        Messager.add_message(
          Message.text('go_going') +
          case direction
            when /N/: Message.text('go_north')
            when /S/: Message.text('go_south')
            when /E/: Message.text('go_east')
            when /W/: Message.text('go_west')
          end + '...'
        )
        Map.room.events.each{|e| e.check} unless Map.room.events.nil?
        Messager.add_message(Map.room.info)
      else
        Messager.add('go_nogo')
      end # if answer
    else
      Messager.add('go_nogo')
    end # if direction =~ /(N|E|W|S)/
  end # go

####
###
##
# inventory
#
  def Command.inventory
    Messager.new_screen
    Messager.add('inventory')
    Messager.add_message(Map.inventory.list.join("\n"))
  end # inventory

####
###
##
# take
#
  def take(data)
    myobject = Item.whatis(data[0], 'Thing')
    Messager.new_screen
    if myobject.nil? || myobject == ''
      Messager.add('take_noobject')
    else
      if Map.inventory.present?(myobject)
        Messager.add('take_already_taken')
      elsif not Map.room.inventory.present?(myobject)
        Messager.add('take_noobject')
      else
        Messager.add_message(Message.text('take_taking') + ' ' + myobject.name)
        Map.inventory.add(myobject)
        Map.room.inventory.withdraw(myobject)
      end
    end
  end # take

####
###
##
# drop
#
  def drop(data)
    myobject = Item.whatis(data[0].thing)
    Messager.new_screen
    if myobject.nil? || myobject == ''
      Messager.add('drop_noobject')
    else
      if not Map.inventory.present?(myobject)
        Messager.add('drop_notpresent')
      else
        Messager.add_message(Message.text('drop_dropping') + ' ' + myobject.name)
        Map.inventory.withdraw(myobject)
        Map.room.inventory.add(myobject)
      end
    end
  end # drop

####
###
##
# give
#
  def give(data)
    if data[1] =~ /to/
      data[1] = data[2]
    end
    Messager.new_screen
    myreceiver = Item.whatis(data[1], 'Person', Map.room.inventory)
    myobject = Item.whatis(data[0], 'Thing')
    if myobject.nil? || myobject == ''
      Messager.add('give_noobject')
    else # myobject.nil? || myobject == ''
      if myreceiver.nil? || myreceiver == ''# || (not myreceiver.class =~ /Person/)
        Messager.add('give_noreceiver')
      else #
        if not Map.inventory.present?(myobject)
          Messager.add('give_notpresent')
        else
          Messager.add_message(
            Message.text('give_giving') +
            ' ' +
            myobject.name +
            ' ' +
            Message.text('give_giving_to') +
            ' ' +
            myreceiver.name )
          Map.inventory.withdraw(myobject)
          myreceiver.inventory.add(myobject)
          Messager.commit
          myobject.events.each{|e| e.check} unless myobject.events.nil?
          myreceiver.events.each{|e| e.check} unless myreceiver.events.nil?
        end # if not $inventory.present?(myobject)
      end # if myreceiver.nil? || myreceiver == ''
    end # if myobject.nil? || myobject == ''
  end # give

####
###
##
# use
#
  def use(data)
    Messager.new_screen
    if data[1] =~ /^(with|on|at)/
      data[1] = data[2]
    end
    if data[0].nil?
      Messager.add('use_noobject')
    else
      if data[1].nil?
        Messager.add('use_nohelper')
      else
        myobject = Item.whatis(data[0], nil, Map.inventory)
        if myobject.nil?
          Messager.add('use_object_unknown')
        else
          if not Item.whatis(data[1], 'Door').nil?
            Command.open([data[1], data[0]])
          end
        end
      end
    end

  end

####
###
##
# open a door (with an object)
#
  def open(data)
    Messager.new_screen
    if data[1] =~ /^(with|using)/
      data[1] = data[2]
    end
#    door = Map.room.which_door(data[0])
    door = Item.whatis(data[0], 'Door')
    if door.nil? || door == ''
      Messager.add('open_noobject')
    else
      if (not data[1].nil?) && (not data[1] == '')
        object = Item.whatis(data[1], 'Thing')
        if object.nil?
          Messager.add('open_nohelper')
        end # if object.nil?
      end # if (not data[1].nil?) && (not data[1] == '')
      answer = door.open(object)
      if answer == true
        Messager.add_message(Message.text('door_opens') + door.name)
#        Messager.add('door_opens')
     else
        Messager.add('door_noopen')
      end
    end # if door.nil? || door == ''
  end # open(data)

####
###
##
# say
#
  def say(data)
    Messager.new_screen
    if data[0].nil?
      Messager.add('say_nowords')
    else # if data[0].nil?
      if data.length > 1
        phrase = data.join(" ")
      else # if data.length > 1
        phrase = data[0]
      end # if data.length > 1
      Messager.pass_message('* "' + phrase.capitalize + '"' + ("\n"*2))
      if Map.room.people?
        dont_answer = false
        Map.room.inventory.people.each do |person|
          person.events.each do |event|
            myanswer = event.check(phrase)
            if myanswer
              dont_answer = true
            end # if myanswer
          end # person.events.each
        end # $map.room.people.each
        Messager.add('say_noreaction') unless dont_answer
      else # if $map.room.people?
        Messager.add('say_nopeople')
      end # if $map.room.people?
    end # if data[0].nil?
  end # use

####
###
##
# quit
#
  def quit
    Messager.pass_message(Message.text('quit'))
    exit
  end

end # class Command

