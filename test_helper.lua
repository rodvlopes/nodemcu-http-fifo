uv = require('luv') --luarocks install luv

function set_timeout(timeout, callback)
  local timer = uv.new_timer()
  local function ontimeout()
    uv.timer_stop(timer)
    uv.close(timer)
    callback()
  end
  uv.timer_start(timer, timeout, 0, ontimeout)
  return timer
end

-- stub http.get
http = {
	get = function(url, headers, cb)
		delay = { normal = 100, slow = 200, slower = 300 }
		set_timeout(delay[url], cb)
	end
}