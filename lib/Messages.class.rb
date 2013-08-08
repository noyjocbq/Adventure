class Message
  @@messages = []
 
  def initialize (identifier, text)
    @identifier = identifier
    @text = text
  end
#  attr_reader :message

  def Message.text(identifier)
    @@messages.each do |message|
      if @identifier == identifier : return @text
      end
    end
    return nil
  end
end


class Messager
  def initialize
    @prompt = "-->"
    @newscreen = 30
    @message = ''
  end
  attr_reader :message

  def pass (identifier)
    puts Message.text(identifier)
    print @prompt
  end  

  
  def pass_message (text)
    puts text
    print @prompt
  end  

  def add (identifier)
    @message << Message.text(identifier)
    @message
  end 
    
  def add_message (text)
    @message << text.to_s << "\n\n"
    text.to_s
  end

  def commit
    puts @message
    print @prompt
    @message = ''
  end  
  
  def new_screen
    @newscreen.times{puts}
  end
  
end
