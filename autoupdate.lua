-- manifest file is a json list, wahre the firt item is a timestamp, for example:
-- ['1293103912', init.lua', 'file.txt']

-- usage example:
-- upload the files to your server with the manifest in the root
-- scp manifest *.lua user@server:/var/www/files/wemos-02/
--
--in the your program, call autoupdate.get_files_from('http://server/files/wemos-02')


-- TODO
-- 1. make it resilient to fails after restart()
-- 2. automatically restart after update (if manifest specify so)
autoupdate = {}

-- it will save (and overwrite) all files listed in the url/manifest 
autoupdate.get_files_from = function(url)
	print('get_manifest from', url)
	http_fifo.get(url.."/manifest", nil, 
	function (code, data)
		if (code < 0 or code >= 400) then
			print("get_manifest: HTTP request failed or manifest not found.", code)
		else
			print('get_manifest: success', code)
			local manifest = sjson.decode(data)
			
			if autoupdate.is_uptodate(manifest) then
				print('files are uptodate')
			else
				-- the sabebkp is consuming all available mememory
				autoupdate.update_files(url, manifest)
				autoupdate.save_last_manifest(data)
			end
		end
	end)
end

-- update_files accepts a table: {'1549579887', 'init.lua', 'main.lua'}
-- where the first argument is the timestamp of the upadate
autoupdate.update_files = function(url, manifest)
	for i,fname in pairs(manifest) do
		if i > 1 then
			autoupdate.update_single_file(url, fname)
		end
	end
end

-- read a file from the server and write it to the fs
autoupdate.update_single_file = function (url, fname)
	print('update_single_file: ', fname)
	http_fifo.get(url.."/"..fname, nil, 
	function (code, data)
		if (code < 0 or code >= 400) then
  			print("update_single_file: HTTP request failed or fname not found.", code)
		else
  			print('update_single_file: success', fname, code)
  			if file.open(fname, "w+") then
				file.write(data)
				file.close()
			end
		end
	end)
end

-- based on the timestamp inside the manifest, it will tell if
-- it's already up to date.
autoupdate.is_uptodate = function (manifest)
	local timestamp = manifest[1]
	if file.open('manifest.last', "r") then
		local data = file.read(500)
		file.close()
		local last_manifest = sjson.decode(data)
		local last_timestamp = last_manifest[1]
		return timestamp == last_timestamp
	else
		return false
	end
end

autoupdate.save_last_manifest = function (data_json)
	if file.open('manifest.last', "w+") then
		file.write(data_json)
		file.close()
	end
end
