######
####
###
##
#  Room Class
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
    @inventory    = Inventory.new
  end
  attr_reader :exits, :visits, :events, :inventory, :look_text, :looks, :info
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
    @event = Event.new(name, unique, condition, command, object, second_object, message, self)
    @events.push(@event)
    @event
  end
 
######
#####
####
###
##
# Add a possible direction for the "go" command
#
  def open_door(direction)
    if @exits !~ /#{direction}/
      @exits << direction
    end
  end 

end

