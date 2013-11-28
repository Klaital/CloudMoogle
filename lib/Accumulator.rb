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

  def to_xml(opts={})
    name = opts[:name]
    parent_sum = opts[:parent_sum]
    
    name_clause = (name.nil?) ? '' : " name=\"#{name}\""

    pct_share_clause = (!parent_sum.nil? && parent_sum > 0) ? "<pct_share>#{@sum * 100.0 / parent_sum}</pct_share>" : ''
    "<stats#{name_clause}><sum>#{self.sum}</sum><count>#{self.count}</count><min>#{self.min}</min><max>#{self.max}</max><mean>#{self.mean}</mean>#{pct_share_clause}<stats>"
  end

  alias :damage_total :sum
end

class ActionAccumulator
  attr_reader :data

  def initialize
    @data = []
  end

  #
  # Add a data element or  to the named set.
  # @param datum [Action] Data point to be added to the set.
  def add(datum)
    if (datum.kind_of?(Array))
      datum.each {|x| @data.unshift(x)}
    else
      @data.unshift(datum)
    end
  end
  alias :add_action :add
  alias :add_actions :add

  def stats_by_type(type)
    stats = Accumulator.new
    stats.add (@data.collect {|d| ((d.type == type) ? d.damage : nil)}.compact)
    return stats
  end
  def stats_by_subtype(subtype)
    stats = Accumulator.new
    stats.add (@data.collect {|d| ((d.subtype == subtype) ? d.damage : nil)}.compact)
    return stats
  end

  # Convert the statistics to an XML report
  # @param overall_damage [Integer] Optionally, pass in the overall damage done in this category and we can compute extra stats based off of that, such as % share.
  # @return [String] XML document describing the accumulator's statistics
  def to_xml(overall_damage=nil)
    types = @data.collect {|d| d.subtype}.uniq
    overall = Accumulator.new
    overall.add(@data.collect {|d| d.damage}.compact)
    my_dmg = self.damage_total

    xml = "<ActionStats>#{overall.to_xml({:name => 'overall'})}"
    types.each do |type|
      xml += stats_by_subtype(type).to_xml({:name => type, :parent_sum => my_dmg})
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
