require 'tk'

class Screen
  def initialize(sizex, sizey, label)
    @sizex = sizex
    @sizey = sizey
    @label = label
    root = TkRoot.new do
      title label
      minsize(sizex,sizey)
    end
    root
  end
end

#-------------------------------
#
#-------------------------------
#-------------------------------
#
#----------------------------



#class Objects
#  def initialize
#    @object
#    
#  end
#end


