######
####
###
##
# 
##
###
####
######

class Message < GeneralInfo
#  @@messages = []

######
#####
####
###
##
# new Message
# 
  def initialize (identifier, text)
    super(identifier, text, nil)
#    @@messages.push(self)
  end
#  attr_reader :message

  def Message.text(identifier)
#    @@messages.each do |message|
    ObjectSpace.each_object(Message) do |message|
      if message.name == identifier : return message.info end
    end
    return nil
  end
end

######
####
###
##
# 
##
###
####
######

class Messager

######
#####
####
###
##
# new Message Handler
# 
  def initialize
    @prompt = "-->"
    @newscreen = 30
    @message = ''
  end
  attr_reader :message

######
#####
####
###
##
# pass a message by identifier
# 
  def pass (identifier, prompt = @prompt)
    puts Message.text(identifier) + "\n"
    print prompt
  end  

######
#####
####
###
##
# pass text directly
#   
  def pass_message (text, prompt = @prompt)
    puts text
    print prompt
  end  

  def add (identifier)
#puts identifier.to_s + '~~~'
#puts Message.text(identifier).to_s + '****'
    @message = @message + Message.text(identifier).to_s + "\n"
#@message << identifier    
    @message
  end 

######
#####
####
###
##
# add text to handler text
#     
  def add_message (text)
    @message << text.to_s << "\n"
    text.to_s
  end

######
#####
####
###
##
# add message by identifier to handler text
#   
  def commit
    puts @message + "\n"
    print @prompt
    @message = ''
  end  

######
#####
####
###
##
# issue new lines
#   
  def new_screen
    @newscreen.times{puts}
  end
  
end
