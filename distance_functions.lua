-------------
--Functions--
-------------

-- vec3 p, float f
function f_minus(p, f)
	return {p[1] - f, p[2] - f, p[3] - f}
end

-- vec3 p, float f
function f_add(p, f)
	return {p[1] + f, p[2] + f, p[3] + f}
end

-- vec3 p1, vec3 p2
function vec_minus(p1, p2)
	return {p1[1] - p2[1], p1[2] - p2[2], p1[3] - p2[3]}
end

-- vec3 p1, vec3 p2
function vec_add(p1, p2)
	return {p1[1] + p2[1], p1[2] + p2[2], p1[3] + p2[3]}
end

-- vec3 p
function length(p)
	local x = p[1]
	local y = p[2]
	local z = p[3]
	return math.sqrt(x*x + y*y + z*z)
end

-- vec3 p
function vec_abs(p)
	return {abs(p[1]),abs(p[2]),abs(p[3])}
end

-- vec3 p1, vec3 p2
function vec_max(p1, p2)
	return {max(p1[1],p2[1]), max(p1[2],p2[2]), max(p1[3],p2[3])}
end

-- vec3 p, float f
function f_max(p, f)
	return vec_max(p,{f,f,f})
end

-- float f, vec3 p
function f2_max(f, p)
	return vec_max(p,{f,f,f})
end

-- vec3 p1, vec3 p2
function vec_min(p1, p2)
	return {min(p1[1],p2[1]), min(p1[2],p2[2]), min(p1[3],p2[3])}
end

-- vec3 p, float f
function f_min(p, f)
	return vec_min(p,{f,f,f})
end

-- float f, vec3 p
function f2_min(f, p)
	return vec_min(p,{f,f,f})
end

-- float f1, float f2
function min(f1, f2)
	return math.min(f1,f2)
end

-- float f1, float f2
function max(f1, f2)
	return math.max(f1,f2)
end

--------------
--Primitives--
--------------
--Each Distance Field Function returns a float

-- vec3 p, float s
function sdSphere(p, s)
	return min(length(p),s)
end

-- vec3 p, vec3 b
function udBox(p, b)
	return length(f_max(vec_minus(vec_abs(p),b),0.0))
end

-- vec3 p, vec3 b, float r
function udRoundBox(p, b, r)
	return f_minus(length(f_max(vec_minus(vec_abs(p),b))),r)
end

-- vec3 p, vec3 b
function sdBox(p, b)
	local d = vec_minus(vec_abs(p),b)
	return min(max(d[1],max(d[2],d[3])),0.0) + length(f_max(d,0))
end