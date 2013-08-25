####
###
##
#  Inventory Class
##
###
#### v0.6

class Inventory

  def initialize
    @items = []
    @health = 10
    self
  end
#
##
###
####  Inventory Methods

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

####
###
##
# add an item using the item_id specified in xml file
#
  def add_byId(item_id)
    @items.push( Item.which(item_id) )
  end

####
###
##
# add item with a known object id
#
  def add(object)
    @items.push(object)
  end

####
###
##
# remove an item
#
  def withdraw(item)
    @items.delete(item) if @items.length > 0
  end

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

####
###
##
# Increase health
#
  def add_health
    @health += 1
    @health
  end

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

