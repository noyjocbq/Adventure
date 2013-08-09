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
  attr_reader :items, :health
  attr_writer :items, :health
######
####
###
##
#  Inventory Methods
##
###
####
######  


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
      returnlist.push(item.name.to_s)
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
    if @items.length > 0 then @items.delete_if {|x| x == item } end
  end

######
#####
####
###
##
# check if item is in inventory
#
  def present?(item)
    answer = false
    @items.each {|i| if i == item then answer = true end }
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

end


