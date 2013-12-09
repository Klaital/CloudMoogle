
class CharacterAnalysisFormatter
  attr_accessor :stats
  def initialize(character_stats)
    @stats = character_stats
  end
  
  def report
    return @stats.to_s
  end
end
