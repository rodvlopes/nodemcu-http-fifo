dofile('http_fifo.lua')
dofile('test_helper.lua')

print('Test suite start')

result_sequence = ''

http_fifo.get('slow', 'headers', function ( ... )
	print('1')
	result_sequence = result_sequence .. '1'
end)

http_fifo.get('slower', 'headers', function ( ... )
	print('2')
	result_sequence = result_sequence .. '2'

	http_fifo.get('normal', 'headers', function ( ... )
		print('4')
		result_sequence = result_sequence .. '4'
	end)
end)

http_fifo.get('slow', 'headers', function ( ... )
	print('3')
	result_sequence = result_sequence .. '3'

	http_fifo.get('normal', 'headers', function ( ... )
		print('5')
		result_sequence = result_sequence .. '5'

		http_fifo.get('normal', 'headers', function ( ... )
			print('6')
			result_sequence = result_sequence .. '6'
		end)
	end)
end)


uv.run() --it will wait until every timer finish


expected_result = '123456'
if result_sequence == expected_result then
	print('✓ success')
else
	print('X failed test: expected:', expected_result, 'but got:', result_sequence)
end

print('Test suite finish')
