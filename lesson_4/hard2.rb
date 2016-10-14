# Moveable Module
module Moveable
  attr_accessor :speed, :heading
  attr_writer :fuel_capacity, :fuel_efficiency

  def range
    "This vehicle can travel a range of #{@fuel_capacity * @fuel_efficiency} kilometers"
  end

  def set_speed(speed)
    @speed = speed
  end

  def speed
    "#{@speed} km/hr"
  end

  def set_heading(direction)
    @heading = direction
  end

  def heading
    "Heading #{@heading}"
  end
end

# WheeledVehicle Class
class WheeledVehicle
  include Moveable

  def initialize(tire_array, km_traveled_per_liter, liters_of_fuel_capacity)
    @tires = tire_array
    self.fuel_efficiency = km_traveled_per_liter
    self.fuel_capacity = liters_of_fuel_capacity
  end

  def tire_pressure(tire_index)
    @tires[tire_index]
  end

  def inflate_tire(tire_index, pressure)
    @tires[tire_index] = pressure
  end
end

# Auto Class - Child of WheeledVehicle
class Auto < WheeledVehicle
  def initialize
    # 4 tires are various tire pressures
    super([30, 30, 32, 32], 50, 25.0)
  end
end

# Motorcycle Class - Child of WheeledVehicle
class Motorcycle < WheeledVehicle
  def initialize
    # 2 tires are various tire pressures
    super([20, 20], 80, 8.0)
  end
end

# Catamaran Class
class Catamaran
  include Moveable
  attr_accessor :propeller_count, :hull_count

  def initialize(num_propellers, num_hulls, km_traveled_per_liter, liters_of_fuel_capacity)
    self.fuel_efficiency = km_traveled_per_liter
    self.fuel_capacity = liters_of_fuel_capacity
    @propeller_count = num_propellers
    @hull_count = num_hulls
  end
end

cat = Catamaran.new(2, 2, 50, 25)
p cat.range
cat.set_heading('north')
p cat.heading

motorcycle = Motorcycle.new
p motorcycle.range
motorcycle.set_heading('south')
p motorcycle.heading
motorcycle.set_speed(100)
p motorcycle.speed

car = Auto.new
p car.range
car.set_heading('east')
p car.heading
car.set_speed(200)
p car.speed
