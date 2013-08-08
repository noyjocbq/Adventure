class Item

  @@items = []

## 
# Create item

  def initialize (item_id, name, identifier, look_text = "There's nothing special about it...")
    @item_id      = item_id
    @name         = name
    @look_text    = look_text
    @identifier   = identifier
    @@items.push(self)
  end
  attr_reader :item_id, :name, :look_text, :identifier

##
# Return object with item_id specified in xml

  def Item.which (item_id)
    @@items.each do |item| 
      if item.item_id == item_id 
        return item
      end
    end
    return nil
  end

##
# Return object with one of the identifiers specified in xml

  def Item.whatis (word)
    @@items.each do |item|
      if Regexp.new( '(' + item.identifier + ')' ).=~(word) != nil
        return item
      end
    end
    nil
  end
end

