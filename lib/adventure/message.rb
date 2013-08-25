######
####
###
##
# Message Class
##
###
####
###### v0.6

class Message
  @@messages = []
  def initialize (identifier, text)
    @identifier = identifier
    @text       = text
    @@messages.push(self)
    self
  end
  attr_reader :identifier, :text

####
###
##
# return text of the message identified by identifier
#
  def Message.text(identifier)
    @@messages.each do |message|
##
#DEBUG
#~ puts message.identifier + '##' + identifier
#~ puts message.text + '##++##'
      return message.text if message.identifier == identifier
    end
    return nil
  end
end

####
###
##
# Message Handler Module
##
###
####
module Messager

#  include Screen

  #~ def prompt
    #~ if @prompt.nil?
      #~ @prompt = "->"
    #~ end
    #~ @prompt
  #~ end
  @@message = ''

  def newscreen
    @newscreen = 3 if @newscreen.nil?
    @newscreen
  end

  #~ def message
    #~ @message = '' if @message.nil?
    #~ @message
  #~ end

  def pass (identifier) #, myprompt = prompt)
    Screen.message_win(Message.text(identifier) + "\n")
#    $screen_handler.message_win(Message.text(identifier) + "\n")
  #  $screen_handler.echo_win(prompt)
  end

####
###
##
# pass text directly
#
  def pass_message (text) #, prompt = prompt)
#    puts text
#    print prompt
    Screen.message_win(text)
#    $screen_handler.message_win(text)
 #   $screen_handler.input_win(prompt)
  end

####
###
##
# add message to cache by identifier
#
  def add (identifier)
#puts identifier.to_s + '~~~'
#puts Message.text(identifier).to_s + '****'
    @@message = @@message + Message.text(identifier).to_s + "\n"
#@message << identifier
    @@message
  end

####
###
##
# add text to cache
#
  def add_message (text)
    @@message << text.to_s << "\n"
    text.to_s
  end

####
###
##
# print output
#
  def commit
#    puts @message + "\n"
#    print @prompt
    Screen.message_win(@@message + "\n")
#    $screen_handler.input_win(@prompt)
    @@message = ''
  end

####
###
##
# issue new lines
#
  def new_screen
    #@newscreen.times{puts}
    Screen.message_win( "\n" * newscreen )
  end

end # module Messager
