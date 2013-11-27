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
      # Iterate! Add each element in turn if an Array was passed in
      datum.each {|d| self.add(d)}
    else
      @count += 1
      @min = datum if (datum < @min)
      @max = datum if (datum > @max)
      @sum += datum
      @mean = @sum / @count.to_f
    end
  end

  def to_xml(name=nil)
    name_clause = (name.nil?) ? '' : " name=\"#{name}\""
    xml = "<stats#{name_clause}><sum>#{self.sum}</sum><count>#{self.count}</count><min>#{self.min}</min><max>#{self.max}</max><mean>#{self.mean}</mean><stats>"
  end

  alias :damage_total :sum
end

class ActionAccumulator
  attr_reader :data

  def initialize
    @data = []
  end

  #
  # Add a data element to the named set.
  # @param datum [Action] Data point to be added to the set.
  def add(datum)
    @data.unshift(datum)
  end
  alias :add_action :add

  def stats_by_subtype(subtype)
    stats = Accumulator.new
    stats.add (@data.collect {|d| ((d.subtype == subtype) ? d.damage : nil)}.compact)
    return stats
  end

  # Convert the statistics to an XML report
  # @return [String] XML document describing the accumulator's statistics
  def to_xml
    subtypes = @data.collect {|d| d.subtype}.uniq
    overall = Accumulator.new
    overall.add(@data.collect {|d| d.damage}.compact)

    xml = "<ActionStats>#{overall.to_xml('overall')}"

    subtypes.each do |subtype|
      xml += stats_by_subtype(subtype).to_xml(subtype)
    end

    xml += "</ActionStats>"

    return xml
  end

  def damage_total
    a = Accumulator.new
    a.add(@data.collect {|d| d.damage}.compact)
    return a.sum
  end
  def count 
    @data.length
  end
end
