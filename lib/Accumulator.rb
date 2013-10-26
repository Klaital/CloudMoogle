
class Accumulator
  attr_accessor :name
  attr_reader :stats

  def initialize(name='dataset name')
    @name = name
    @stats = {:count => 0, :sum => 0, :mean => 0.0, :min => 99999999, :max => 0}
  end

  def add_datum(datum)
    @stats[:min] = datum if (@stats[:min] > datum)
    @stats[:max] = datum if (@stats[:max] < datum)
    @stats[:sum] += datum
    @stats[:count] += 1
    @stats[:mean] = @stats[:sum] / @stats[:count].to_f
  end
end