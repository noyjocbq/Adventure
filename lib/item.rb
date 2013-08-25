####
###
## Basic Information Structure
#  Item and related Classes
##
###
#### v0.6

class Item < Object
  @@items  = []
  @@things = []
  @@rooms  = []
  @@people = []
  @@doors  = []

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
    @@items.push(self)
    self
  end
  attr_reader :item_id, :identifier, :name, :info, :look_text, :events,
                :looks, :uses, :inventory
  attr_writer :info, :look_text

#
##
###
#### Item Methods


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

####
###
##
# Add a door
#
  def add_door(id, identifier, exit, open, key=nil, name=nil, info=nil, look="There's nothing much to see...")
    door = Item.which(id, 'Door')
    if door.nil?
      door = Door.new(id, identifier, exit, open, self, key, name, info, look)
    else
      door.room = self
    end
    @inventory.add(door)
    door
  end # add_door

####
###
##
# Add a person
#
  def add_person(id, identifier, name, info, look="There's nothing much to see...")
    person = Item.which(id, 'Person')
    person = Person.new(id, identifier, name, info, look) if person.nil?
    @inventory.add(person)
    person
  end # add_person

####
###
##
# Add a thing
#
  def add_thing(id, identifier, use_with, name, info, look="There's nothing much to see...")
    thing = Item.which(id, 'Thing')
    thing = Thing.new(id, identifier, use_with, name, info, look) if thing.nil?
    @inventory.add(thing)
    thing
  end # add_person

####
###
##
# Add a room
#
  def add_room(id, identifier, exits, name, info, look="There's nothing much to see...")
    room = Item.which(id, 'Room')
    room = Room.new(id, identifier, exits, name, info, look) if room.nil?
    @inventory.add(room)
    room
  end # add_person


####
###
##
# Add an event
#
  def add_event(name, unique, condition, phrase, message)
    event = Event.new(name, unique, condition, phrase, message, self)
    @events.push(event)
    event
  end

####
###
## Methods that return all or a special kind of object
#
  def Item.allItems
    return @@items
  end # Item.all_items

  def Item.allRooms
#    myreturn = []
 #   ObjectSpace.each_object(Room){|i| myreturn.push(i)}
  #  myreturn
    return @@rooms
  end # Item.all_rooms

  def Item.allPeople
    #~ myreturn = []
    #~ ObjectSpace.each_object(Person){|i| myreturn.push(i)}
    #~ myreturn
    return @@people
  end # Item.allPeople

  def Item.allThings
    #~ myreturn = []
    #~ ObjectSpace.each_object(Thing){|i| myreturn.push(i)}
    #~ myreturn
    return @@things
  end # Item.allThings

####
###
##
# Return object with item_id specified in xml
#
  def Item.which(item_id, type = "all", inventory = nil)
    mylist = case type.downcase
      when /person/   : @@people
      when /thing/    : @@things
      when /door/     : @@doors
      when /room/     : @@rooms
      else @@items
    end
    mylist.each do |item|
      if item.item_id == item_id
        if inventory.nil? || inventory.present?(item)
          return item
        end
      end
    end
    return nil
  end # which

####
###
##
# Return object with one of the identifiers specified in xml
#
  def Item.whatis(word, type = "all", inventory = nil)
    type = "all" if type.nil?
    mylist = case type.downcase
      when /person/   : @@people
      when /thing/    : @@things
      when /door/     : @@doors
      when /room/     : @@rooms
      else @@items
    end
    mylist.each do |item|
      if (not (item.identifier.nil?)) && Regexp.new(item.identifier).=~(word) != nil
        if inventory.nil? || inventory.present?(item)
          return item
        end
      end
    end
    return nil
  end #whatis
end # class Item

####
###
##
#  Class Thing
##
###
####
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
    @@things.push(self)
  end
end

####
###
##
#  Class Door
##
###
####
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
    @@doors.push(self)
    self
  end

  attr_reader :exit, :open, :key, :room
  attr_writer :room

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
        Map.room.exits << @exit
      end
    else
      answer = @open = true
      @room.exits << @exit
    end
    answer
  end # open(object = nil)

####
###
##
# close door
#
  def close
    @open = false
    (0..(Map.room.exits.length-1)).each do |x|
      myexits << Map.room.exits[x,1] unless Map.room.exits[x,1] == @exit
    end
    Map.room.exits = myexits
    true
  end # close

end   # class Door

####
###
##
#  Class Room
##
###
####
class Room < Item
  def initialize(id, identifier, exits, name, info, look = "There's nothing much to see...")
    super(id, identifier, name, info, look)
    @visits       = 0
    @exits        = exits
    @@rooms.push(self)
  end
  attr_reader :exits, :visits, :inventory # :events, :inventory, :look_text, :looks, :info, :doors, :people
#  attr_writer :exits, :info, :visits, :inventory, :look_text, :events

#
##
###
#### Room Methods

####
###
##
# Increase number of visits
#
  def visit
    @visits += 1
    @visits
  end

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

####
###
##
# Add a room event
#
  #~ def add_event(name, unique, condition, phrase, command, object, helper, message)
    #~ event = Event.new(name, unique, condition, phrase, command, object, helper, message, self)
    #~ @events.push(event)
    #~ event
  #~ end


####
###
##
# which_door
#
  #~ def which_door(phrase)
    #~ @inventory.doors.each do |door|
      #~ return door unless Regexp.new(door.identifier).=~(phrase) == nil
    #~ end # @doors.each
    #~ nil
  #~ end # which_door(phrase)

end # class

####
###
##
#  Person Class
##
###
####
class Person < Item
  def initialize   (
    item_id,
    identifier,
    name,
    info = nil,
    look_text = "There's nothing special to see..."
  )
    super(item_id, identifier, name, info, look_text)
    @@people.push(self)
    self
  end # initialize
  attr_reader :inventory
end # class Person


