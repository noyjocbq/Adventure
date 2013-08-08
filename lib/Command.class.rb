class Command

## 
# Accept a command and digest it to verb, object and second object

  def initialize (command)
    @verb = ""
    @object = ""
    @helper = ""
    data = command.split(/ /)
    unless data[0].length >> 0 
      raise "Please enter a command..."
    end
    @verb, @object, @helper = case 
    when data[0].length == 1 && data[0] =~ /(N|E|W|S)/  
      ['go', data[0], nil]
    when data[0].length == 1 && data[0] =~ /I/
      ['inventory', nil, nil]
    when data[0].length == 1 && data[0] =~ /Q/
      ['quit', nil, nil]
    when data[0].downcase =~ /^go/
      ['go', data[1], nil ]
    when data[0].downcase =~ /^inven/
      ['inventory', nil, nil ]
    when data[0].downcase =~ /^(quit|exit)/
      ['quit', nil, nil]
    when data[0].downcase =~ /^(get|fetch|grab|take)/
      ['take', data[1].downcase, nil ]
    when data[0].downcase =~ /^look/
      ['look', data[1], nil]
    when data[0].downcase =~ /^help/ || data[0].downcase =~ /^command/
      ['help', 'help_command', nil]
    else
      ['unknown', nil, nil]
    end 
  rescue 
    return false
  end
  attr_reader :verb, :object, :helper
  attr_writer :verb, :object, :helper

  def execute
    answer = case @verb
    when 'look'
  	  #puts @object
      $message_handler.pass_message(@object.look_text)
    end
    answer
  end

end
