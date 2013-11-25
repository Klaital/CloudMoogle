require_relative '../lib/Patterns'
require_relative '../lib/Action'

class Parser

  # 
  # Parse a log line from FFXI. Optionally include the timestamp provided by 
  # Windower's Timestamp plugin. The given +line+ will be stripped of it and 
  # any chat lines.
  #
  # @param line [String] The line of text produced by FFXI
  # @param last_line_action [Action] The Action object parsed out of the last line of test. This is only needed for parsing the damage portion of a two-line Action, such as a spell or crit.
  def Parser.parse_line(line, last_line_action)
    return nil if (line.nil? || line.length == 0)

    # Remove the leading timestamp
    line.gsub!(/^\[\d\d:\d\d:\d\d\]/, '')

    # Remove party and linkshell chat lines
    line.gsub!(/^[\(<)]#{Patterns.character_name}[\)>]/, '')

    # Remove any tell chat lines
    line.gsub!(/^>>#{Patterns.character_name} : /, '')
    line.gsub!(/^#{Patterns.character_name}>> /, '')

    #
    # Find the correct parser method and execute it
    #

    # Check if we are finishing processing a multiline action
    if (!last_line_action.nil? && Patterns.respond_to?("#{last_line_action.pattern_name}_2_parse"))
      return Patterns.send("#{last_line_action.pattern_name}_2_parse", line, last_line_action)
    end
    
    # Since this is not the second line of a multiline action, we shall ignore
    # the last_line_action parameter from here out.
    Patterns.first_line_patterns.each do |pattern|
      a = Patterns.send("#{pattern}_parse", line)
      return a unless(a.nil?) # Eventually we will settle on the right pattern. 
      # unless none match...
    end

    # in which case...
    return nil
  end

end
