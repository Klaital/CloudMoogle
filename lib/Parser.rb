require_relative '../lib/Patterns'
require_relative '../lib/Action'
require_relative '../lib/configs'

# 
# The Parser class contains the logic for transforming FFXI log data into 
# a set of Action objects. This can be passed to an Analyzer object for 
# further transformation into a nice human-readable report.
class Parser

  attr_accessor :stop # used to request that the parser quit before EOF
  attr_reader :actions
  def initialize
    @actions = []
    @stop = false
  end

  # 
  # Parse a stream of FFXI log data. This can be a file object, as called by
  # #parse_file, or from $stdin if you invoked it from the commandline via
  # something like `cat logfile.log > ruby parseit.rb`
  # @param instream [IO] The data source to read FFXI log data from.
  def parse_stream(instream)
    unless(instream.respond_to?(:gets))
      puts "Unable to use the specified input stream: not responding to #gets"
      return nil
    end
    a = nil
    lines_parsed = 0
    while(!@stop)
      begin
        s=instream.gets
        next if (s.nil?)
        s = s.strip
        next if (s.length == 0) # FFXI seems to add lines with a single ' ' character between all lines
                                # Maybe it's just windower's Logger or something? TODO: look into this
        puts "Considering line: '#{s}'" if ($DEBUG)
        a = Parser.parse_line(s, a)
        puts "Got Action #{a.inspect}" if ($DEBUG)
        
        next if (a.nil?) # No action detected
        lines_parsed += 1
        if (a.complete?)
          # Action detected or completed (in the case of a two-line action)
          # Save the action, and reset the pointer to nil so that the 
          # parse_line method does not attempt further processing on it.
          puts "-Saving action" if ($DEBUG)
          @actions.unshift(a)
          a = nil
        end
      rescue StandardError => e
        LOGGER.e {"Error while parsing, halting: #{e}"}
        @stop = true
      end
    end
	
    # indicate successful completion
    return lines_parsed
  end

  #
  # Utility method: give it a filename for an FFXI logfile, and it will 
  # handle it for you.
  # TODO: add support for timestamps, party config
  # @param path [String] The path to the FFXI logfile  
  def parse_file(path)
    if (!File.exists?(path))
      LOGGER.e {"Unable to open specified file to parse: '#{path}'"}
      return nil
    end
    
    lines_parsed = 0
    File.open(path, 'r') do |f|
      t = Thread.new { lines_parsed = parse_stream(f) }
      sleep(1) until(f.eof?)
      @stop = true
      t.join
    end
    
    return lines_parsed
  end

  # 
  # Parse a log line from FFXI. Optionally include the timestamp provided by 
  # Windower's Timestamp plugin. The given +line+ will be stripped of it and 
  # any chat lines.
  #
  # @param line [String] The line of text produced by FFXI
  # @param last_line_action [Action] The Action object parsed out of the last line of test. This is only needed for parsing the damage portion of a two-line Action, such as a spell or crit.
  def Parser.parse_line(line, last_line_action=nil)
    return last_line_action if (line.nil? || line.length == 0)

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

# Run this as 'main' if the library is invoked directly
if (__FILE__ == $0 && ARGV.length > 0)
  p = Parser.new
  p.parse_file(ARGV[-1])
  puts "ActionsParsed=#{p.actions.length}"
end

