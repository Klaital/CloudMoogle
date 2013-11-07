
class Accumulator
  def initialize(data=[])
    @min = 9999999999999999999999
    @max = 0
    @mean = 0
    @count = 0
    @sum = 0

    data.each {|datum| self.add(datum)}
  end
  def add(datum)
    if (datum.kind_of?(Array))
      # Recurse! Add each element in turn if an Array was passed in
      datum.each {|d| self.add(d)}
    else
      @count += 1
      @min = datum if (datum < @min)
      @max = datum if (datum > @max)
      @sum += datum
      @mean = @sum / @count.to_f
    end
  end
end

class CombatAccumulator
  attr_reader :data

  def initialize
    @data = {}
  end

  def add(datum, key='')
    if (@data.keys.include?(key))
      @data[key].unshift(datum)
    else
      @data[key] = [datum]
    end
  end

  # 
  # Generate a basic Accumulator using the data in each set whose name matches all of the filters
  def select(filters = [])
    a = Accumulator.new
    @data.each_pair do |key, data|
      a.add(data) if (CombatAccumulator.matches_all_filters?(key, filters))
    end
  end

  def CombatAccumulator.matches_all_filters?(name, filters)
    filters.each do |filter|
      return false if (name !~ /#{filter}/)
    end

    return true
  end
end
