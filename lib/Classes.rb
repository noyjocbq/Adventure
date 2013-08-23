######
####
###
##
#  This is version 0.6 of the Classes file
##1
###
####
######
require 'rexml/document'
require 'tk'
include REXML

######
####
###
##
#   class Map
##  Map file digest
###
####
######
class Map
  @@MAX_INDEX = [2,2]
  @@START_ROOM = [0,1]
  def initialize(mapfile)
    @initial = true
    @room = {}
    @events = []
    @items = []
#    @message = {}
    @messages = []
    @room_id = []
    @welcome_message = ''
    @inventory = Inventory.new
    xml = Document.new(File.open(mapfile))
    @name = xml.root.attributes["name"]

    xml.elements.each("Map/variable") do |e|
      tmp = e.attributes["value"].split(/\|/)
      case e.attributes["name"]
        when /MAX_INDEX/  : @@MAX_INDEX = [tmp[0].to_i, tmp[1].to_i]
        when /START_ROOM/ : @@START_ROOM = [tmp[0].to_i, tmp[1].to_i]
#        when /WELCOME_MESSAGE/ : @welcome_message = e.attributes["value"]
        when /WELCOME_MESSAGE/ : @welcome_message = e.text
      end
    end # xml.elements.each("Map/variable")

    xml.elements.each("Map/message") do |message|
#      @message[ message.attributes["identifier"] ] =
      mymessage = Message.new(
        message.attributes["identifier"] ,
        message.text)
      @messages.push(mymessage)
    end # xml.elements.each("Map/message")

    xml.elements.each("Map/event") do |event|
      myevent = Map.add_event(
        event.attributes["name"],
        event.text("unique"),
        event.text("condition"),
        event.text("phrase"),
        event.text("command"),
        event.text("object"),
        event.text("helper"),
        event.text("message") )
    end # xml.elements.each("Map/event")

    xml.elements.each("Map/item") do |element|
      item = Thing.new(
        element.attributes["item_id"],
        element.text("identifier"),
        element.text("use_with"),
        element.text("name"),
        element.text("info"),
        element.text("look_text") )
      @items.push(item)
      element.elements.each("event") do |event|
        item.add_event(
          event.attributes["name"],
          event.text("unique"),
          event.text("condition"),
          event.text("phrase"),
          event.text("command"),
          event.text("object"),
          event.text("helper"),
          event.text("message")  )
      end # element.elements.each("event") do |event|
    end # xml.elements.each("Map/item") do |element|

    xml.elements.each("Map/room") do |room|
      tmp = room.attributes["location"].split(/\|/)
      @room[ [tmp[0].to_i, tmp[1].to_i] ] =
        Room.new(
          room.attributes["location"],
          room.text("identifier"),
          room.text("exits"),
          room.text("name"),
          room.text("info"),
          room.text("look_text") )

      room.elements.each("event") do |event|
        @room[ [tmp[0].to_i, tmp[1].to_i] ].add_event(
          event.attributes["name"],
          event.text("unique"),
          event.text("condition"),
          event.text("phrase"),
          event.text("command"),
          event.text("object"),
          event.text("helper"),
          event.text("message") )
      end # room.elements.each("event") do |event|

      room.elements.each("item") do |item|
#        myitem = Item.which()
        @room[ [tmp[0].to_i, tmp[1].to_i] ].inventory.add_byId(item.attributes["item_id"])
      end # room.elements.each("item") do |item|

      room.elements.each("door") do |door|
        @room[ [tmp[0].to_i, tmp[1].to_i] ].add_door(
          door.attributes["door_id"],
          door.text("identifier"),
          door.text("exit"),
          door.text("open"),
          door.text("key"),
          door.text("name"),
          door.text("info"),
          door.text("look_text") )
      end # room.elements.each("door") do |door|

      room.elements.each("person") do |person|
        person_id = @room[ [tmp[0].to_i, tmp[1].to_i] ].add_person(
          person.attributes["person_id"],
          person.text("identifier"),
          person.text("name"),
          person.text("info"),
          person.text("look_text")  )
        person.elements.each("event") do |event|
          person_id.add_event(
            event.attributes["name"],
            event.text("unique"),
            event.text("condition"),
            event.text("phrase"),
            event.text("command"),
            event.text("object"),
            event.text("helper"),
            event.text("message") )
        end # person.elements.each("event") do |event|
      end # room.elements.each("person") do |person|
    end # xml.elements.each("Map/room") do |room|

    xml.elements.each("Map/start_inventory") do |item|
      @inventory.add_byId(item.text)
    end

    @room_id = @@START_ROOM
    @room[@room_id].visit
    self
  end

  attr_reader :welcome_message, :name, :initial, :inventory
  attr_writer :initial

#
##
###
####
###### Map Methods

######
#####
####
###
##
# go
#
  def go(direction)
    direction = direction[0,1].upcase
    goto = case direction
      when /^N/ : [ 0,-1]
      when /^S/ : [ 0, 1]
      when /^E/ : [ 1, 0]
      when /^W/ : [-1, 0]
    end
    if room.exits =~ /#{direction}/
      [0,1].each do |i|
        @room_id[i] = case
          when @room_id[i] + goto[i] > @@MAX_INDEX[i] : 0
          when @room_id[i] + goto[i] < 0 : @@MAX_INDEX[i]
          else                         @room_id[i] + goto[i]
        end
      end
      @room[ @room_id ].visit
      return true
    else
      return false
    end

  end

######
#####
####
###
##
# returns current room
#
  def room
    @room[@room_id]
  end

######
#####
####
###
##
# Add a map event
#
  def add_event(name, unique, condition, phrase, command, object, helper, message)
    event = Event.new(name, unique, condition, phrase, command, object, helper, message, self)
    @events.push(event)
    event
  end

end

######
####
###
##
#  Inventory Class
##
###
####
######
class Inventory

  def initialize
    @items = []
    @health = 10
  end
#  attr_reader :items, :health
#  attr_writer :items, :health

#
##
###
####
######  Inventory Methods

######
#####
####
###
##
# list items in inventory
#
  def list
    returnlist = []
    @items.each do |item|
      returnlist.push(item.name.to_s) if item.is_a?(Thing)
    end
    return returnlist
  end

  def items
    @items
  end

  def people
    returnlist = []
    @items.each do |item|
      returnlist.push(item) if item.is_a?(Person)
    end
    return returnlist
  end

  def rooms
    returnlist = []
    @items.each do |item|
      returnlist.push(item) if item.is_a?(Room)
    end
    return returnlist
  end

  def things
    returnlist = []
    @items.each do |item|
      returnlist.push(item) if item.is_a?(Thing)
    end
    return returnlist
  end

  def doors
    returnlist = []
    @items.each do |item|
      returnlist.push(item) if item.is_a?(Door)
    end
    return returnlist
  end

######
#####
####
###
##
# add an item using the item_id specified in xml file
#
  def add_byId(item_id)
    @items.push( Item.which(item_id) )
  end

######
#####
####
###
##
# add item with a known object id
#
  def add(object)
    @items.push(object)
  end

######
#####
####
###
##
# remove an item
#
  def withdraw(item)
    if @items.length > 0 then @items.delete(item) end
  end

######
#####
####
###
##
# check if item is in inventory (Object or item_id)
#
  def present?(item)
    answer = false
    @items.each {|i| if i == item then answer = true end }
    if answer == false
      item = Item.which(item)
      @items.each {|i| if i == item then answer = true end }
    end # if
    answer
  end

######
#####
####
###
##
# Increase health
#
  def add_health
    @health += 1
    @health
  end

######
#####
####
###
##
# decrease health
#
  def withdraw_health
    @health -= 1
    @health
  end

end # class Inventory

######
####
###
## Basic Information Structure
#  Item Class
##
###
####
######
class Item < Object
  def initialize   (
    item_id,
    identifier,
    name,
    info = nil,
    look_text = "There's nothing special about it..."
  )
    @item_id      = item_id
    @identifier   = identifier
    @name         = name
    @info         = info
    @look_text    = look_text
    @uses         = 0
    @looks        = 0
    @events       = []
    @inventory    = Inventory.new
    self
  end
  attr_reader :item_id, :identifier, :name, :info, :look_text, :events,
                :looks, :uses, :inventory
  attr_writer :info, :look_text

#
##
###
####
###### Item Methods


######
#####
####
###
##
# use and look
#
  def use
    @uses += 1
    @uses
  end # use

  def look
    @looks += 1
    @looks
  end

######
#####
####
###
##
# Add an event
#
  def add_event(name, unique, condition, phrase, command, object, helper, message)
    @event = Event.new(name, unique, condition, phrase, command, object, helper, message, self)
    @events.push(@event)
    @event
  end

######
#####
####
###
## Methods that return all or a special kind of object
#
  def Item.allItems
    myreturn = []
    ObjectSpace.each_object(Item){|i| myreturn.push(i)}
    myreturn
  end # Item.all_items

  def Item.allRooms
    myreturn = []
    ObjectSpace.each_object(Room){|i| myreturn.push(i)}
    myreturn
  end # Item.all_rooms

  def Item.allPeople
    myreturn = []
    ObjectSpace.each_object(Person){|i| myreturn.push(i)}
    myreturn
  end # Item.allPeople

  def Item.allThings
    myreturn = []
    ObjectSpace.each_object(Thing){|i| myreturn.push(i)}
    myreturn
  end # Item.allThings

######
#####
####
###
##
# Return object with item_id specified in xml
#
  def Item.which(item_id)#, type = nil)
#    @@items.each do |item|
#    ObjectSpace.each_object(Item) do |item|
    Item.allItems.each do |item|
      if item.item_id == item_id
        return item
      end
    end
    return nil
  end

######
#####
####
###
##
# Return object with one of the identifiers specified in xml
#
  def Item.whatis(word, inventory = nil)
    ObjectSpace.each_object(Item) do |item|
#    Item.allItems.each do |item|
##
# DEBUG
#~ unless item.identifier.nil? #do
#~ puts "Whatis: word "  + word
#~ puts "Identifier: " + item.identifier
#~ puts (Regexp.new('\s(' + item.identifier + ')\s').=~(word)).to_s + "+++"
#      if not (item.identifier.nil?) && Regexp.new('(' + item.identifier + ')').=~(word) != nil
      if (not (item.identifier.nil?)) && Regexp.new(item.identifier).=~(word) != nil
#~ puts "Success: " + item.identifier + "äää" + word
#~ puts "Item ID: " + item.to_s
        if not inventory.nil?
          return item if inventory.present?(item)
        else
          return item
        end
      end # if Regexp....
    end # ObjectSpace.each_object(Item) do |item|
#~ end
    nil
  end # Item.whatis
end # class Item

######
####
###
##
#  Class Thing
##
###
####
######
class Thing < Item
  def initialize   (
    item_id,
    identifier,
    use_with,
    name,
    info = nil,
    look_text = "There's nothing special about it..."
  )
    super(item_id,
      identifier,
      name,
      info,
      look_text
    )
    @use_with = use_with
  end
end

######
####
###
##
#  Class Door
##
###
####
######
class Door < Item
   def initialize(
    door_id,
    identifier,
    exit,
    open,
    room,
    key   = nil,
    name  = nil,
    info  = nil,
    look  = "There's nothing much to see..."
  )    # Starts here
    super(door_id, identifier, name, info, look)
    @exit = exit
    @room = room
    if /true/.=~(open.downcase)
      @open = true
    else
      @open = false
    end
    @key = nil
    if (not key.nil?) && (not key == '')
      @key = Item.which(key)
    end
    self
  end

  attr_reader :exit, :open, :key

######
#####
####
###
##
# open door using object if possible
#
  def open(object = nil)
    answer = false
    if not @key.nil?
      if object == @key
        answer = @open = true
        $map.room.exits << @exit
#        $message_handler.add('door_opens')
#      else
#        $message_handler.add('door_noopen')
      end
    else
      answer = @open = true
#      $map.room.exits << @exit
      @room.exits << @exit
#      $message_handler.add('door_opens')
    end
    answer
  end # open(object = nil)

######
#####
####
###
##
# close door
#
  def close
    @open = false
    (0..($map.room.exits.length-1)).each do |x|
      myexits << $map.room.exits[x,1] unless $map.room.exits[x,1] == @exit
    end
    $map.room.exits = myexits
    true
  end # close

######
#####
####
###
##
# which & whatis
#
  def Door.whatis(phrase)
    ObjectSpace.each_object(Door) do |door|
      return door unless Regexp.new(door.identifier).=~(phrase) == nil
    end # ObjectSpace.each_object(Door)
    nil
  end # Door.whatis

  def Door.which(name)
    ObjectSpace.each_object(Door) do |door|
      return door if door.name == name
    end # ObjectSpace.each_object(Door)
    nil
  end # Door.which

end   # class Door

######
####
###
##
#  Class Room
##
###
####
######
class Room < Item
  def initialize(id, identifier, exits, name, info, look = "There's nothing much to see...")
    super(id, identifier, name, info, look)
    @visits       = 0
    @exits        = exits
  end
  attr_reader :exits, :visits, :inventory # :events, :inventory, :look_text, :looks, :info, :doors, :people
#  attr_writer :exits, :info, :visits, :inventory, :look_text, :events

#
##
###
####
###### Room Methods

######
#####
####
###
##
# Increase number of visits
#
  def visit
    @visits += 1
    @visits
  end

######
#####
####
###
##
# Return Room with given location
# (location is stored in Room object as item_id)
  def Room.which(location)
#    ObjectSpace.each_object(Room) do |room|
    Item.allRooms.each do |room|
      return room if room.item_id == location
    end
    nil
  end

######
#####
####
###
##
# Are there people present?
#
  def people?
    if @inventory.people.length > 0
      return true
    end # if @people.length > 0
    false
  end # people?

######
#####
####
###
##
# Is a specific Item present (item_id)
#
  def present?(id)
    if @inventory.items.include?(Item.which(id))
      return true
    end
    false
  end # present?

######
#####
####
###
##
# Add a room event
#
  def add_event(name, unique, condition, phrase, command, object, helper, message)
    event = Event.new(name, unique, condition, phrase, command, object, helper, message, self)
    @events.push(event)
    event
  end

######
#####
####
###
##
# Add a door
#
  def add_door(id, identifier, exit, open, key=nil, name=nil, info=nil, look="There's nothing much to see...")
    door = Door.new(id, identifier, exit, open, self, key, name, info, look)
    @inventory.add(door)
    door
  end # add_door

######
#####
####
###
##
# which_door
#
  def which_door(phrase)
    @inventory.doors.each do |door|
      return door unless Regexp.new(door.identifier).=~(phrase) == nil
    end # @doors.each
    nil
  end # which_door(phrase)

######
#####
####
###
##
# Add a person
#
  def add_person(person_id, identifier, name, info, look="There's nothing much to see...")
    person = Person.new(person_id, identifier, name, info, look)
    @inventory.add(person)
    person
  end # add_person


end # class

######
####
###
##
#  Person Class
##
###
####
######
class Person < Item
  def initialize   (
    item_id,
    identifier,
    name,
    info = nil,
    look_text = "There's nothing special to see..."
  )
    super(item_id, identifier, name, info, look_text)
    self
  end # initialize
  attr_reader :inventory
end # class Person

######
####
###
##
#  Class for the screen
##
###
####
######
class Screen
  @message = ''
  @input = ''
  def initialize(titel = 'Untitled')
    messagefont = TkFont.new("family" => 'Times',
                             "size" => 12,
                             "weight" => 'bold')
    inputfont =   TkFont.new("family" => 'Helvetica',
                             "size" => 12)
    echofont =    TkFont.new("family" => 'Helvetica',
                             "size" => 10,
                             "weight" => 'bold')
    @root = TkRoot.new() {
      title(titel)
#      minsize(400, 400)
    }

# Message window
    @message = TkText.new(@root) {
      height 20
      font messagefont
      takefocus 0
    }
    @message.pack("side"=>"top", "fill"=>"x")
    @message.grid("columnspan"=>2, "sticky"=>"nsew")
    @message.configure("state"=>"normal")
    @message.insert('end', $map.welcome_message)
    @message.configure("state"=>"disabled")

# Input echo window
    @echo = TkText.new(@root) {
      height 5
      font echofont
      takefocus 0
      foreground 'darkgrey'
    }
    @echo.pack("side"=>"top", "fill"=>"x")
    @echo.grid("columnspan"=>2, "sticky"=>"nsew")
    @echo.configure("state"=>"disabled")

# Input line window
    myprompt = TkLabel.new(@root) {
      text ">"
      width 2
      height 1
      font inputfont
      takefocus 0 }
    myprompt.grid("column"=>0, "row"=>2, "sticky"=>"ew")
    @input = TkText.new(@root) {
      height 1
      font inputfont
      takefocus 1 }
    @input.pack("side"=>"bottom")
    @input.grid("column"=>1, "row"=>2, "sticky"=>"ew")
    @input.insert('end', "Press Return...")
    @input.bind('KeyPress-Return') {
      return_pressed
    }
    TkGrid.columnconfigure @root, 0, :weight=>0
    TkGrid.columnconfigure @root, 1, :weight=>1
    TkGrid.rowconfigure @root, 0, :weight=>5
    TkGrid.rowconfigure @root, 1, :weight=>1
    TkGrid.rowconfigure @root, 2, :weight=>0
    @input.focus
    return @root
  end # initialize

#
##
###
####
###### Screen methods

######
#####
####
###
##
# what to do when return key was pressed
  def return_pressed
    phrase = @input.get("1.0", "end").chomp.sub(Regexp.new($message_handler.prompt), '').sub("\n", '')
      $command_handler.digest(phrase)
#      while @input.index("end - 1 line").split('.')[0].to_i > 4
      echo_win(phrase + "\n")
      @input.delete("1.0", "end")
#      @input.insert("1.0", $message_handler.prompt)
#      end #while
  end #  return_pressed

######
#####
####
###
##
# pass message text to the message window
  def message_win(message)
    @message.configure("state"=>"normal")
    @message.insert('end', message)
    while @message.index("end - 1 line").split('.')[0].to_i > 20
      @message.delete(1.0, 2.0)
    end
    @message.configure("state"=>"disabled")
    message
  end # message_win

######
#####
####
###
##
# pass message text to the echo window
  def echo_win(message)
    @echo.configure("state"=>"normal")
    @echo.insert('end', "#{message}")
    while @echo.index("end - 1 line").split('.')[0].to_i > 5
      @echo.delete(1.0, 2.0)
    end
    @echo.configure("state"=>"disabled")
    message
  end # input_win --> now "echo_win"

end #class


######
####
###
##
#  Event Class
##
###
####
######
class Event
  def initialize (name, unique, condition, phrase, command, object, helper, message, associated)
    @name             = name
    @triggered        = 0
    if unique.nil? || /true/.=~(unique.downcase)
      @unique         = true
    else
      @unique         = false
    end
    @condition        = condition
    @phrase           = phrase
    @command          = command
    @object           = object
    @helper           = helper
    @message          = message
    @associated       = associated
#    @@events.push(self)
  end
attr_reader :name, :condition, :command, :object, :helper,
  :message, :triggered, :associated, :unique

#
##
###
####
###### Event Methods

######
#####
####
###
##
# trigger
#
  def trigger
    @triggered += 1
    @triggered
  end

######
#####
####
###
##
# check condition and/or phrase and take necessary action
#
  def check_phrase(phrase) # -1, 0 or 1
    if (@phrase.nil? || @phrase == '')
      return 0
    elsif (phrase.nil? || phrase=='') || (Regexp.new(@phrase).=~(phrase)).nil?
      return -1
    else
      return 1
    end
  end # check_phrase

  def check_condition # -1, 0 or 1
    if (@condition.nil? || @condition == '')
      return 0
    elsif eval('@associated.' + @condition)
      return 1
    else
      return -1
    end
  end # check_condition

  def check(phrase = nil)
    answer = false

    if (check_condition + check_phrase(phrase)) > 0 &&
    ((not @unique) || @triggered == 0) # execute

      self.trigger
      case @command

        when /replace_object_by_helper/:
          eval('@associated.' + @object + " = %q{" + @helper + "} ")

        when /add_helper_to_object/ :
          eval('@associated.' + @object + " << %q{" + @helper + "} ")

        when /add_item_to_inventory/:
          @associated.inventory.add_byId(@object)

        when /add_item_to_player_inventory/:
          $map.inventory.add_byId(@object)

        when /add_item_to_room_inventory/:
          Room.which(@helper).inventory.add_byId(@object)

        when /add_to_info_of_object/:
          (Item.which(@object)).info << @helper

        when /open_door_by_id/:
          (Item.which(@object)).open

      end # case @command

      if not @message.nil?
        $message_handler.new_screen
        $message_handler.pass_message(@message)
        answer = true
      end # if not @message.nil?

    end # if "execute"

    answer
   end # check

end # class Event

######
####
###
##
# Command Class
##
###
####
######
class Command
  def initialize
    self
  end
    attr_reader :verb, :object, :helper
  attr_writer :verb, :object, :helper

#
##
###
####
###### Command Methods

######
#####
####
###
##
# Accept a command and digest it

  def digest(command)
    data = command.chomp.split(/ /)
    if $map.initial
      $map.initial = false
      data = [ "look" ]
    end
##
#DEBUG
#$message_handler.pass_message('##' + data[0].to_s + '**')
#
##
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
        data.shift
        data.each {|x| x = x.downcase }
        self.take(data)
      when data[0].downcase =~ /^(look|exam)/
        data.shift
        data.each {|x| x = x.downcase }
        self.look(data)
      when data[0].downcase =~ /^use/
        data.shift
        data.each{|x| x = x.downcase }
        self.use(data)
      when data[0].downcase =~ /^(drop|throw)/
        data.shift
        data.each{|x| x = x.downcase }
        self.drop(data)
      when data[0].downcase =~ /^give/
        data.shift
        data.each{|x| x = x.downcase }
        self.give(data)
      when data[0].downcase =~ /^open/
        data.shift
        data.each{|x| x = x.downcase }
        self.open(data)
      when data[0].downcase =~ /^say/
        data.shift
        data.each{|x| x = x.downcase}
        self.say(data)
#        when data[0].downcase =~ /^help/ || data[0].downcase =~ /^command/
#          ['help', 'help_command', nil]
      else $message_handler.add('nocommand')
      end
    end
#    $map.events.each {|e| check} unless $map.events.nil?
    $message_handler.commit
  end

#
##
###
####
###### Commands

######
#####
####
###
##
# look (at)
#
  def look_at(object)
    object.look
    $message_handler.new_screen
    $message_handler.add('look_looking')
    if object.look_text.nil? || object.look_text == ''
      $message_handler.add_message(object.info)
    else
      $message_handler.add_message(object.look_text)
    end
    object.events.each{|e| e.check} unless object.events.nil?
  end

  def look(data)
    if data[0].nil? || data[0] == ''
      look_at($map.room)
    else
      if data[0] =~ /at/
        data[0] = data[1]
      end
##
#DEBUG
#$message_handler.pass_message('Still alive ###' + data[0].to_s)
#
##
      myobject = Item.whatis(data[0].to_s)
      if myobject.nil? || myobject == ''
        $message_handler.add('look_noobject')
      else
        if $map.inventory.present?(myobject) || $map.room.inventory.present?(myobject)
          look_at(myobject)
        else
          $message_handler.add('look_nolook')
        end
      end
    end
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
        $map.room.events.each{|e| e.check} unless $map.room.events.nil?
        $message_handler.add_message($map.room.info)
      else
        $message_handler.add('go_nogo')
      end # if answer
    else
      $message_handler.add('go_nogo')
    end # if direction =~ /(N|E|W|S)/
  end # go

######
#####
####
###
##
# inventory
#
  def inventory
    $message_handler.new_screen
    $message_handler.add('inventory')
    $message_handler.add_message($map.inventory.list.join("\n"))
#    $message_handler.commit
  end # inventory

######
#####
####
###
##
# take
#
  def take (data)
    myobject = Item.whatis(data[0])
    $message_handler.new_screen
    if myobject.nil? || myobject == ''
      $message_handler.add('take_noobject')
    else
      if $map.inventory.present?(myobject)
        $message_handler.add('take_already_taken')
      elsif not $map.room.inventory.present?(myobject)
        $message_handler.add('take_noobject')
      else
        $message_handler.add_message(Message.text('take_taking') + ' ' + myobject.name)
        $map.inventory.add(myobject)
        $map.room.inventory.withdraw(myobject)
      end
    end
  end # take

######
#####
####
###
##
# drop
#
  def drop (data)
    myobject = Item.whatis(data[0])
    $message_handler.new_screen
    if myobject.nil? || myobject == ''
      $message_handler.add('drop_noobject')
    else
      if not $map.inventory.present?(myobject)
        $message_handler.add('drop_notpresent')
      else
        $message_handler.add_message(Message.text('drop_dropping') + ' ' + myobject.name)
        $map.inventory.withdraw(myobject)
        $map.room.inventory.add(myobject)
      end
    end
  end # drop

######
#####
####
###
##
# give
#
  def give (data)
    if data[1] =~ /to/
      data[1] = data[2]
    end
    $message_handler.new_screen
    myreceiver = Item.whatis(data[1], $map.room.inventory)
    myobject = Item.whatis(data[0])
#######
#DEBUG
#~ $message_handler.pass_message("DO: " + data[0] + '++')
#~ $message_handler.pass_message("IO: " + data[1] + '++')
#~ $message_handler.pass_message("DO2: " + myobject.to_s + '++')
#~ $message_handler.pass_message("IO2: " + myreceiver.to_s + '++')
########
    if myobject.nil? || myobject == ''
      $message_handler.add('give_noobject')
    else # myobject.nil? || myobject == ''
      if myreceiver.nil? || myreceiver == ''# || (not myreceiver.class =~ /Person/)
        $message_handler.add('give_noreceiver')
      else #
        if not $map.inventory.present?(myobject)
          $message_handler.add('give_notpresent')
        else
          $message_handler.add_message(
            Message.text('give_giving') +
            ' ' +
            myobject.name +
            ' ' +
            Message.text('give_giving_to') +
            ' ' +
            myreceiver.name )
          $map.inventory.withdraw(myobject)
          myreceiver.inventory.add(myobject)
          $message_handler.commit
          myobject.events.each{|e| e.check} unless myobject.events.nil?
          myreceiver.events.each{|e| e.check} unless myreceiver.events.nil?
        end # if not $inventory.present?(myobject)
      end # if myreceiver.nil? || myreceiver == ''
    end # if myobject.nil? || myobject == ''
  end # give

######
#####
####
###
##
# use
#
  def use(data)
    $message_handler.new_screen
    if data[1] =~ /^(with|on|at)/
      data[1] = data[2]
    end
    if data[0].nil?
      $message_handler.add('use_noobject')
    else
      if data[1].nil?
        $message_handler.add('use_nohelper')
      else
        myobject = Item.whatis(data[0], $map.inventory)
        if myobject.nil?
          $message_handler.add('use_object_unknown')
#        else
#          if data[1] =~ /^door/
#            if $map.room.doors.length == 0
#              $message_handler.add('door_nodoor')
#            else
#              answer = $map.room.doors[0].open(myobject)
#            end
#          end
        end
      end
    end

  end

######
#####
####
###
##
# open a door (with an object)
#
  def open(data)
    $message_handler.new_screen
    if data[1] =~ /^(with|using)/
      data[1] = data[2]
    end
    door = $map.room.which_door(data[0])
    if door.nil? || door == ''
      $message_handler.add('open_noobject')
    else
      if (not data[1].nil?) && (not data[1] == '')
        object = Item.whatis(data[1])
        if object.nil?
          $message_handler.add('open_nohelper')
        end # if object.nil?
      end # if (not data[1].nil?) && (not data[1] == '')
      answer = door.open(object)
      if answer == true
        $message_handler.add('door_opens')
      else
        $message_handler.add('door_noopen')
      end
    end # if door.nil? || door == ''
  end # open(data)

######
#####
####
###
##
# say
#
  def say(data)
    $message_handler.new_screen
    if data[0].nil?
      $message_handler.add('say_nowords')
    else # if data[0].nil?
      if data.length > 1
        phrase = data.join(" ")
      else # if data.length > 1
        phrase = data[0]
      end # if data.length > 1
      if $map.room.people?
        $message_handler.pass_message('* "' + phrase.capitalize + '"' + ("\n"*2))
        dont_answer = false
        $map.room.inventory.people.each do |person|
          person.events.each do |event|
            myanswer = event.check(phrase)
            if not myanswer.nil?
              dont_answer = true
            end # if myanswer
          end # person.events.each
        end # $map.room.people.each
        $message_handler.add('say_noreaction') unless dont_answer
      else # if $map.room.people?
        $message_handler.add('say_nopeople')
      end # if $map.room.people?
    end # if data[0].nil?
  end # use

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

end # class Command

######
####
###
##
# Message Class
##
###
####
######
class Message
  def initialize (identifier, text)
    @identifier = identifier
    @text       = text
    self
  end
  attr_reader :identifier, :text
######
#####
####
###
##
# return text of the message identified by identifier
#
  def Message.text(identifier)
    ObjectSpace.each_object(Message) do |message|
##
#DEBUG
#~ puts message.identifier + '##' + identifier
#~ puts message.text + '##++##'
      return message.text if message.identifier == identifier
    end
    return nil
  end
end

######
####
###
##
# Message Handler Class
##
###
####
######
class Messager

  def initialize
    @prompt = "->"
    @newscreen = 3
    @message = ''
    self
  end
  attr_reader :message, :newscreen, :prompt

#
##
###
####
###### Message Handler Methods

######
#####
####
###
##
# pass a message by identifier
#
  def pass (identifier, prompt = @prompt)
#    puts
#    print prompt
    $screen_handler.message_win(Message.text(identifier) + "\n")
  #  $screen_handler.echo_win(prompt)
  end

######
#####
####
###
##
# pass text directly
#
  def pass_message (text, prompt = @prompt)
#    puts text
#    print prompt
    $screen_handler.message_win(text)
 #   $screen_handler.input_win(prompt)
  end

######
#####
####
###
##
# add message to cache by identifier
#
  def add (identifier)
#puts identifier.to_s + '~~~'
#puts Message.text(identifier).to_s + '****'
    @message = @message + Message.text(identifier).to_s + "\n"
#@message << identifier
    @message
  end

######
#####
####
###
##
# add text to cache
#
  def add_message (text)
    @message << text.to_s << "\n"
    text.to_s
  end

######
#####
####
###
##
# print output
#
  def commit
#    puts @message + "\n"
#    print @prompt
    $screen_handler.message_win(@message + "\n")
#    $screen_handler.input_win(@prompt)
    @message = ''
  end

######
#####
####
###
##
# issue new lines
#
  def new_screen
    #@newscreen.times{puts}
    $screen_handler.message_win( "\n" * @newscreen )
  end

end # class Messager
