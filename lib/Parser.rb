require_relative '../lib/Patterns'
require_relative '../lib/Action'

# 
# The Parser class contains the logic for transforming FFXI log data into 
# a set of Action objects. This can be passed to an Analyzer object for 
# further transformation into a nice human-readable report.
class Parser

  attr_reader :actions
  def initialize
    @actions = []
  end

  # 
  # Parse a stream of FFXI log data. This can be a file object, as called by
  # #parse_file, or from $stdin if you invoked it from the commandline via
  # something like `cat logfile.log > ruby parseit.rb`
  # @param instream [IO] The data source to read FFXI log data from.
  def parse_stream(instream)
    return nil unless(instream.respond_to?(:gets))
    a = nil
    while(s=instream.gets)
      next if (s.nil? || s.length == 0)
      a = Parser.parse_line(s, a)
      next if (a.nil?) # No action detected
      if (a.complete?)
        # Action detected or completed (in the case of a two-line action)
        # Save the action, and reset the pointer to nil so that the 
        # parse_line method does not attempt further processing on it.
        @actions.unshift(a)
        a = nil
      end
    end
  end

  #
  # Utility method: give it a filename for an FFXI logfile, and it will 
  # handle it for you.
  # TODO: add support for timestamps, party config
  # @param path [String] The path to the FFXI logfile  
  def parse_file(path)
    File.open(path, 'r') do |f|
      parse_stream(f)
    end
  end

  # 
  # Parse a log line from FFXI. Optionally include the timestamp provided by 
  # Windower's Timestamp plugin. The given +line+ will be stripped of it and 
  # any chat lines.
  #
  # @param line [String] The line of text produced by FFXI
  # @param last_line_action [Action] The Action object parsed out of the last line of test. This is only needed for parsing the damage portion of a two-line Action, such as a spell or crit.
  def Parser.parse_line(line, last_line_action=nil)
    return nil if (line.nil? || line.length == 0)

    # Remove the leading timestamp
    begin
      line.gsub!(/^\[\d\d:\d\d:\d\d\]/, '')
    rescue ArgumentError => e
      $stderr.puts "ERROR unable to remove timestamp from line '#{line}'. #{e}" if (defined?(VERBOSE) || defined?(DEBUG))
      return nil
    end

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
