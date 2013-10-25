require_relative '../lib/Patterns'
require_relative '../lib/Timestamp'
require 'rubygems'
require 'json'

class Parser
    attr :stop, true
    attr :pause_duration, true
    attr :max_sleep, true
    attr :output_mode, true # one of: [s, mysql_insert, json]
    
    def initialize
        @stop = false
        @pause_duration = 1
        @max_sleep = 1200
        @output_mode = 's'
    end
    def Parser.action_to_s(act)
        return "" if(act.nil?)
        
        s = act['format'] + "\t" + act['timestamp'].to_s + "\t"
        case(act['format']) 
            when "COMBAT"
                s += [act['action'], act['actor'], act['target'], act['damage'], act['ability name']].compact.join("\t")
            when "LIGHT"
                s += act['color']
            when "KILL"
                s += [act['actor'], act['target'] ].join("\t")
        end
            
        return s
    end
    def Parser.action_to_json(act)
        return act.to_json
    end
    def Parser.action_to_mysql_insert(act, actions_tbl="actions")
        s = "INSERT INTO #{actions_tbl} VALUES (NULL, '" + act['format'] + "', '" + act['timestamp'].to_s_mysql + "', "
        
        return nil if(act.nil?)
        case(act['format'])
            when "COMBAT"
                s += "NULL, '" + act['actor'] + "', '" + act['target'] + "', '" + act['action'].split(/ /).join("', '") + "', '" + act['ability name'] + "', " + act['damage'].to_s
            when "LIGHT"
                s += "'" + act['color'] + "', NULL, NULL, NULL, NULL, NULL, NULL"
            when "KILL"
                s += "NULL, '" + act['actor'] + "', '" + act['target'] + "', NULL, NULL, NULL, NULL"
        end
        
        s += ")"
        return s
    end
    

    def Parser.parse_line(s, old_act, output_mode='s')
        line = s
        old_action = old_act
        # extract the timestamp, if any
        parse_time = Time.now
        parse_time = Timestamp.new(parse_time.year, parse_time.month, parse_time.day, parse_time.hour, parse_time.min, parse_time.sec)
        if(line =~ /^\[\d\d:\d\d:\d\d\]/)
            parse_time.hour = line[1..2].to_i
            parse_time.minute = line[4..5].to_i
            parse_time.second = line[7..8].to_i
            line = line[10..-1]
        end
        
        # strip out "Magic Burst!" if present
        if(line =~ /^Magic Burst!/)
            line = line[13..-1]
        end
            
        if(!old_action.nil? && old_action['pattern_name'] && line =~ Patterns.send(old_action['pattern_name'] + "_2"))  # half-completed action
            # look for the second line
            # run the associated parser
            old_action = Patterns.send(old_action['pattern_name'] + "_2_parse", line, old_action)
            old_action['timestamp'] = parse_time
            #~ return [Parser.action_to_s(old_action), nil]
            return [Parser.send("action_to_#{output_mode}", old_action), nil]
        end
        
        # if we read this point, then a 2-line action appeared to start on the previous line, but was not completed on this line.
        # thus, we abandon the old data by setting old_action=nil
        # then we move on to see if a new action seems to have started
        old_action = nil
        
        # look for the first line of an action
        Patterns.first_line_patterns.each_index do |i|
            # just skip it if there's no parsing method defined
            next if(!Patterns.methods.index(Patterns.first_line_patterns[i] + "_parse"))
            
            # fetch the pattern to match against
            patn = if(Patterns.first_line_patterns[i] == "weaponskill_1") 
                Patterns.send(Patterns.first_line_patterns[i], Patterns.weaponskills)
            else
                Patterns.send(Patterns.first_line_patterns[i])
            end
            
            if(line =~ patn)
                old_action = Patterns.send(Patterns.first_line_patterns[i] + "_parse", line)
                old_action['timestamp'] = parse_time
                if(Patterns.first_line_patterns[i] =~ /_1$/)
                    return ["", old_action]
                else
                    #~ return [Parser.action_to_s(old_action), nil]
                    return [Parser.send("action_to_#{output_mode}", old_action), nil]
                end
            end
        end #end first_line_patterns.each_index
        
        # if we get here, then none of the patterns matched
        return [nil, nil]
    end
        
    def start(instream, outstream)
        start_time = Time.now
        old_action = nil
        sleep_time = nil
        while(!@stop)
            # may need to wait for more lines to be written into the input stream. Sleep for a bit at a time in between as needed.
            if(instream.eof)
                if(sleep_time.nil?)
                    sleep_time = Time.now 
                elsif(Time.now - @max_sleep > sleep_time)
                    puts "# Slept too long! Quitting..."
                    @stop = true
                end
                sleep(@pause_duration)
                next
            end
            # if we make it here, that means there was data to read
            sleep_time = nil
            
            line = instream.gets.strip
            next if(line.length < 10)
            
            # if the line starts with "//" or "#", it's a comment. Pass these through (some may be commands intended for the Analyzer)
            if(line =~ /^(\/\/|#)/)
                outstream.puts line
            end
	    
            # actually parse the line!
            output_string, old_action = Parser.parse_line(line, old_action, @output_mode)
            
            # if valid output data was returned, send it along to the output stream
            if(!(output_string.nil? || output_string == ""))
                outstream.puts output_string
            end
            
        end # end while(!@stop)        
    end
end
