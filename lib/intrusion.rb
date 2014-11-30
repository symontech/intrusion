module Intrusion
  
  # check if ip is blocked
  def ids_is_blocked?(ip)
    ids_load.each { |d| return true if d[:ip] == ip and d[:counter] > 9 }
    return false
  end
  
  def ids_counter(ip)
    ids_load.each { |d| return d[:counter] if d[:ip] == ip }
    return 0
  end
      
  # report suspicious activity
  def ids_report!(ip, block=false)
    dt = ids_load
    found = nil
    dt.each { |d| found = d if d[:ip] == ip }
    if found
	    block ? found[:counter] = 10 : found[:counter] += 1
    else
	    dt << { ip: ip, counter: block ? 10 : 1 }
	  end
	
    # update record
    return self.update_attributes(ids: dt.to_yaml)
  end

  # reset counter and stay
  def ids_unblock!(ip)
    dt = ids_load
    found = false
    dt.each { |d| found = d if d[:ip] == ip }
    
    if found
      dt.delete(found) 
    
      # update
      return self.update_attributes(ids: dt.to_yaml)

    end
    return false
  end

  # convert yaml string helper
  def ids_load
    dt = ids.blank? ? [] : YAML::load(ids) rescue []
    dt = [] unless dt.class == Array
    return dt
  end

end