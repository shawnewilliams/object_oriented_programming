# SecredFile Class
class SecretFile
  attr_reader :data, :name, :security_log

  def initialize(secret_data, name)
    @data = [secret_data]
    @name = name
    @security_log = SecurityLogger.new
    @security_log.create_log_entry(@name)
  end

  def data(name)
    @security_log.create_log_entry(name)
    @data
  end

  def add_data(new_data, name)
    @security_log.create_log_entry(name)
    @data << new_data
  end

  def display_log
    @security_log.log
  end
end

# SecurityLogger Class
class SecurityLogger
  require 'time'
  attr_reader :log

  def initialize
    @log = {}
  end

  def create_log_entry(name)
    @log[name] = [Time.new.asctime] unless @log[name]
    @log[name] = @log[name].push(Time.new.asctime)
  end
end

a = SecretFile.new('top secret', 'shawn')
p a.data('Shawn')
p a.display_log
puts

a.add_data('more secret stuff', 'Shawn')
p a.data('Shawn')
p a.display_log
puts
a.add_data('extra secret', 'Briana')
p a.display_log
