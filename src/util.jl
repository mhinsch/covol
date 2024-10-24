# TODO move to util
"""Sigmoid with f(0) = 1, f-> for higher x. Steepness determines slope of decrease, 
offset width of curve. f(offset) = 0.5"""
function sigmoid(x, steepness, offset)
    xs = x^steepness
    1 - xs/(offset^steepness + xs)
end


#"Sigmoid with f(0)=0, f(1)=1. Linear for steepness=offset=1; higher offset increases (f^-1)(1/2)."
#function sigmoid(x, steepness, offset)
#    xs = x^(steepness * offset)
#    xs/(xs + (1-xs^offset)^steepness)
#end


function remove_unsorted!(cont, obj)
    for (i, el) in enumerate(cont)
        if el == obj
            remove_unsorted_at!(cont, i)
            return
        end
    end

    error("obj not found!")
end

function remove_unsorted_at!(cont, idx)
    cont[idx] = cont[end]
    pop!(cont)
end

sq_dist(x1, y1, x2, y2) = (x2-x1)^2 + (y2-y1)^2
distance(x1, y1, x2, y2) = sqrt(sq_dist(x1, y1, x2, y2))

n_instances(T) = length(instances(T))

# For some reason Julia can *write* Rational, but not read it...
"parse Rational from an AbstractString"
function Base.parse(::Type{Rational{T}}, s::AbstractString) where {T}
    nums = split(s, "//")
    Rational{T}(parse(T, nums[1]), parse(T, nums[2]))
end

# based on this code:
# https://stackoverflow.com/questions/40273880/draw-a-line-between-two-pixels-on-a-grayscale-image-in-julia
function bresenham(f :: Function, x1::Int, y1::Int, x2::Int, y2::Int)
	#println("b: ", x1, ", ", y1)
	#println("b: ", x2, ", ", y2)
	# Calculate distances
	dx = x2 - x1
	dy = y2 - y1

	# Determine how steep the line is
	is_steep = abs(dy) > abs(dx)

	# Rotate line
	if is_steep == true
		x1, y1 = y1, x1
		x2, y2 = y2, x2
	end

	# Swap start and end points if necessary 
	if x1 > x2
		x1, x2 = x2, x1
		y1, y2 = y2, y1
	end
	# Recalculate differentials
	dx = x2 - x1
	dy = y2 - y1

	# Calculate error
	error = round(Int, dx/2.0)

	if y1 < y2
		ystep = 1
	else
		ystep = -1
	end

	# Iterate over bounding box generating points between start and end
	y = y1
	for x in x1:x2
		if is_steep == true
			coord = (y, x)
		else
			coord = (x, y)
		end

		f(coord[1], coord[2])

		error -= abs(dy)

		if error < 0
			y += ystep
			error += dx
		end
	end

end


macro static_var(init)
  var = gensym()
  Base.eval(__module__, :(const $var = $init))
  quote
    global $var
    $var
  end |> esc
end


