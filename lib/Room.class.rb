######
####
###
##
#  Classes for Rooms
##
###
####
######

class Door < GeneralInfo
  def initialize(name, exit, open, object, info=nil, look="There's nothing much to see...")
    super(name, info, look)
    @exit = exit
    if /true/.=~(open.downcase)
      @open = true
    else
      @open = false
    end
    @object = object
  end
  attr_reader :exit
######
#####
####
###
##
# open door using object if possible
#
  def open(object)
    answer = false
    if not @object.nil?
      if object == @object
        answer = @open = true
        self.parent.exits << @exit
        $message_handler.add('door_opens')
      else
        $message_handler.add('door_noopen')
      end
    else
      answer = @open = true
      self.parent.exits << @exit
      $message_handler.add('door_opens')
    end
    answer
  end

######
#####
####
###
##
# close door
#
  def close
    @open = false
    (0..self.parent.exits.length-1).each do |x| 
      myexits << self.parent.exits[x,1] unless self.parent.exits[x,1] == @exit
    end
    self.parent.exits = myexits
    true
  end  
end    

######
####
###
##
#  Class Room
##
###
####
######

class Room < GeneralInfo
  def initialize(exits, name, info, look = "There's nothing much to see...")
    @visits       = 0
    @exits        = exits
    super(name, info, look)
    @events       = []
    @doors        = []
    @inventory    = Inventory.new
  end
  attr_reader :exits, :visits, :events, :inventory, :look_text, :looks, :info, :doors
  attr_writer :exits, :info, :visits, :inventory, :look_text, :events

######
####
###
##
#  Room Methods
##
###
####
######

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
# Add a room event
#
  def add_event(name, unique, condition, command, object, second_object, message)
    event = Event.new(name, unique, condition, command, object, second_object, message, self)
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
  def add_door(name, exit, open, object=nil, info=nil, look="There's nothing much to see...")
    door = Door.new(name, exit, open, object, info, look)
    @doors.push(door)
    door
  end
 
end
