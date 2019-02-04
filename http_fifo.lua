http_fifo = {
	fifo = {}
}

function tprint(t)
	for k,v in pairs(t) do print(k,v) end
end

http_fifo.get = function (url, headers, cb)
	local wrapper_get = function ()
		http.get(url, headers, function( ... )
			cb( ... )
			http_fifo.next()
		end)
	end
	table.insert(http_fifo.fifo, wrapper_get)

	http_fifo.run()
end

http_fifo.run = function ()
	if #http_fifo.fifo == 1 then
		http_fifo.fifo[1]()
	end
end

http_fifo.next = function ()
	table.remove(http_fifo.fifo, 1)
	if #http_fifo.fifo > 0 then
		http_fifo.fifo[1]()
	end
end
