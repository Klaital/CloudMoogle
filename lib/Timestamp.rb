
class Timestamp
	attr_reader :hour, :minute, :second, :year, :month, :date
	attr_writer :hour, :minute, :second, :year, :month, :date
	
	def initialize(year=2000, month=1, date=1, hour=0, minute=0, second=0)
		@hour, @minute, @second = hour, minute,second
        @year, @month, @date = year, month, date
	end
	
	def to_a
		return [ @year, @month, @date, @hour, @minute, @second ]
	end
	def Timestamp.from_a(anArray)
		return Timestamp.new( anArray[0], anArray[1], anArray[2], anArray[3], anArray[4], anArray[5] )
	end
		
    # TODO: upgrade the to_i and from_i methods to support year/month/date 
	def to_i
		return (((@hour*60)+@minute)*60) + @second
	end
	def Timestamp.from_i(anInteger)
		temp = anInteger /60
		
		second = anInteger % 60
		minute = temp % 60
		hour   = temp / 60
		date = 01
        month = 01
        year = 01
		return Timestamp.new(year, month, date, hour, minute, second)
	end
	
	def to_s(separator=":")
		return self.to_a.collect {|x| x.to_s.rjust(2).gsub(/ /, "0")}.join(":")
	end
    
    def Timestamp.from_s_mysql(s)
        # DATETIME from mysql is default formatted as "YYYY-MM-DD HH:mm:ss"
        return Timestamp.new(s.split(/[- :]/).collect {|x| x.to_i})
    end
    
    def to_s_mysql
        a = self.to_a.collect {|x| x.to_s.rjust(2).gsub(/ /, "0")}
        return "#{a[0]}-#{a[1]}-#{a[2]} #{a[3]}:#{a[4]}:#{a[5]}"
    end
    
	def Timestamp.from_s(aString, separator=":")
		if(separator == "")
			# assume two digits per element
			year = aString[0..1].to_i
			month = aString[2..3].to_i
			date = aString[4..5].to_i
            hour = aString[7..8].to_i
            minute = aString[10..11].to_i
            second = aString[13..14].to_i
			
			return Timestamp.new(year, month, date, hour, minute, second)
		else
			tokens = aString.split(separator)
            year = tokens[0].to_i
			month = tokens[1].to_i
			date = tokens[2].to_i
			hour = tokens[3].to_i
			minute = tokens[4].to_i
			second = tokens[5].to_i
			
			return Timestamp.new(year, month, date, hour, minute, second)
		end
		return nil
	end
end
