class NMEA
  class AppCrashed < StandardError; end
  class CommandFailed  < StandardError; end
end

class NMEA::Parser
  def Struct(hash)
    Struct.new(*hash.keys).new(*hash.values.map{|s| Hash === s ? Struct(s) : s})
  end
  
  def checksum(line)
    buf = line.split("*")
    target = buf[1]
    string = buf[0].gsub("$","")
    i = r = 0
    
    while i < string.size
      r ^=  string[i].bytes.to_a[0]
      i += 1
    end
    return target.to_s == r.to_s(16)
  end
    
    
  NMEA_ID = {:gpgga => "$GPGGA", :gpgll => "$GPGLL", :gpgsa => "$GPGSA",
             :gpgsv => "$GPGSV", :gprmc => "$GPRMC", :gpvtg => "$GPVTG"}
           
  def get_nmea_from_line(nmea_line)
    nmea_array = nmea_line.split(",")
    raise CommandFailed unless NMEA_ID.has_value?(nmea_array[0])    
    
    if nmea_array[0] == NMEA_ID[:gprmc]
      return Struct({:my => "my"})
    end
    
  end
end

n = NMEA::Parser.new

p n.get_nmea_from_line("$GPRMC,ljl,kjljk,").my
p n.checksum("$GPVTG,0.000,T,0,M,2.160,N,4.000,K*51")