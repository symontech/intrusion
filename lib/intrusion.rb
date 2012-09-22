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
    found = false
    dt.each { |d| found = d if d[:ip] == ip }
    if found
	    block ? found[:counter] = 10 : found[:counter] += 1
    else
      initial_counter = block ? 10 : 1
	    dt << { :ip => ip, :counter => initial_counter }
	  end
	
    # update
    self.ids = dt.to_yaml
    return self.save
  end

  # reset counter and stay
  def ids_unblock!(ip)
    dt = ids_load
    found = false
    dt.each { |d| found = d if d[:ip] == ip }
    
    if found
      dt.delete found 
    
      # update
	    self.ids = dt.to_yaml
	    return self.save
    end
    return false
  end

  # convert yaml string helper
  def ids_load
    dt = []
    dt = YAML::load(ids) if ids
    return dt
  end

end