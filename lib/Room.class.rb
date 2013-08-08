class Room

## 
# Create new room 

  def initialize(exits, info, look = "There's nothing much to see...")
    @visits       = 0
    @looks        = 0
    @exits        = exits
    @info         = info
    @events       = []
    @look_text    = look
    @inventory    = Inventory.new
  end
  attr_reader :exits, :visits, :events, :inventory, :look_text, :looks
  attr_writer :exits, :info, :visits, :inventory, :look_text, :events
##
# Returns room info (xml)
# followed by description text of itmes (xml) present in room inventory

  def info
    returnstring = @info + "\n"
    @inventory.items.each {|item| returnstring += ("You see" + item.name) }
    returnstring
  end

##
# Increase number of visits

  def visit
    @visits += 1
    @visits
  end
  
  def look
    @looks += 1
    @looks
  end

##
# Add a room event

  def add_event(name, condition, command, object, second_object, message)
    @event = Event.new(name, condition, command, object, second_object, message, self)
    @events.push(@event)
    @event
  end
 
##
# Add a possible direction for the "go" command

  def open_door(direction)
    if @exits !~ /#{direction}/
      @exits << direction
    end
  end 

end

