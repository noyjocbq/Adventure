######
####
###
##
#  Item Class
##
###
####
######

class Item < GeneralInfo
  def initialize   (
    item_id, 
    identifier,
    name, 
    info = nil,
    look_text = "There's nothing special about it..."
  )
    @item_id      = item_id
    @identifier   = identifier
    @uses = 0
    @events = []
    super(name, info, look_text)
  end
  attr_reader :item_id, :name, :look_text, :identifier

######
####
###
##
#  Item Methods
##
###
####
######


######
#####
####
###
##
# Add an event
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
# Return object with item_id specified in xml
#
  def Item.which (item_id)
#    @@items.each do |item| 
    ObjectSpace.each_object(Item) do |item|
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
  def Item.whatis (word)
#puts word + '+#+#'  
#    @@items.each do |item|
    ObjectSpace.each_object(Item) do |item|
      if Regexp.new( '(' + item.identifier + ')' ).=~(word) != nil
        return item
      end
    end
    nil
  end
end

