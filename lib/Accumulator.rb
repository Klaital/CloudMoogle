require_relative '../lib/Action'

class Accumulator
  attr_reader :min, :max, :mean, :count, :sum
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

class ActionAccumulator
  attr_reader :data

  def initialize
    @data = {}
  end

  #
  # Add a data element to the named set.
  #
  # @param datum [Integer] Data point to be added to the set.
  # @param key [String] Name of the dataset the element is to be added to.
  def add(datum, key='')
    if (@data.keys.include?(key))
      @data[key].unshift(datum)
    else
      @data[key] = [datum]
    end
  end

  # 
  # Generate a basic Accumulator using the data in each set whose name matches all of the filters
  #
  # @param filters [Array] Set of filters to apply against the dataset keys.
  #
  # @return [Accumulator] A plain accumulator containing the statistics as computed for the datasets whose keys match the filters
  def select(filters = {})
    a = Accumulator.new
    @data.each_pair do |key, action|
      a.add(action.damage) if (CombatAccumulator.matches_all_filters?(key, filters))
    end

    return a
  end

  #
  # Helper method: Return the Minimum value for the set of data matching all of the filters.
  # Calling each of these statistic-computation methods directly on the CombatAccumulator is much less
  # efficient than calling select, saving that Accumulator, and reading the various statistics from that.
  #
  # @param filters [Array] Set of filters to apply against the dataset keys.
  # 
  # @return [Integer] The minimum value from the matching datasets.
  def min(filters=[])
    self.select(filters).min
  end
  
  #
  # Helper method: Return the Maximum value for the set of data matching all of the filters.
  # Calling each of these statistic-computation methods directly on the CombatAccumulator is much less
  # efficient than calling select, saving that Accumulator, and reading the various statistics from that.
  #
  # @param filters [Array] Set of filters to apply against the dataset keys.
  # 
  # @return [Integer] The maximum value from the matching datasets.
  def max(filters=[])
    self.select(filters).max
  end
  
  #
  # Helper method: Return the Mean value for the set of data matching all of the filters.
  # Calling each of these statistic-computation methods directly on the CombatAccumulator is much less
  # efficient than calling select, saving that Accumulator, and reading the various statistics from that.
  #
  # @param filters [Array] Set of filters to apply against the dataset keys.
  # 
  # @return [Integer] The mean value of the matching datasets.
  def mean(filters=[])
    self.select(filters).mean
  end

  #
  # Helper method: Return the number of data for the set of data matching all of the filters.
  # Calling each of these statistic-computation methods directly on the CombatAccumulator is much less
  # efficient than calling select, saving that Accumulator, and reading the various statistics from that.
  #
  # @param filters [Array] Set of filters to apply against the dataset keys.
  # 
  # @return [Integer] The data count from all of the matching datasets.
  def count(filters=[])
    self.select(filters).count
  end
  
  #
  # Helper method: Return the sum of the set of data matching all of the filters.
  # Calling each of these statistic-computation methods directly on the CombatAccumulator is much less
  # efficient than calling select, saving that Accumulator, and reading the various statistics from that.
  #
  # @param filters [Array] Set of filters to apply against the dataset keys.
  # 
  # @return [Integer] The sum of the matching datasets.
  def sum(filters=[])
    self.select(filters).sum
  end

  def ActionAccumulator.matches_all_filters?(action, filters)
    filters.each_pair do |element, pattern|
      return false unless(action.data.keys.include?(element))
      return false if (action.data[element] !~ pattern)
    end

    return true
  end
end
