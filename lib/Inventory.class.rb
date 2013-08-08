class Inventory

  def initialize
    @items = []
    @health = 10
  end
  attr_reader :items, :health
  attr_writer :items, :health
  
  def list
    returnlist = []
#puts @items    
    @items.each do |item|
#puts item.name
      returnlist.push(item.name)
    end
    return returnlist
  end
  
  def add_byId(item_id)
    @items.push( Item.which(item_id) )
  end
  
  def add(object)
    @items.push(object)
  end
  
  def withdraw(item)
    if @items.length > 0 then @items.delete_if {|x| x == item } end
  end
  
  def add_health
    @health += 1
    @health
  end
  
  def withdraw_health
    @health -= 1
    @health
  end

end


