do
	local scale_factor_x = 1 / 1920
	local scale_factor_y = 1 / 1080

	function math.scale(size)
		return math.floor(size * (ScrH() * scale_factor_y))
	end

	function math.scale_x(size)
		return math.floor(size * (ScrW() * scale_factor_x))
	end

	function math.scale_size(x, y)
		return math.scale_x(x), math.scale(y)
	end

	math.scale_y      = math.scale
	math.scale_width  = math.scale_x
	math.scale_height = math.scale
end

if CLIENT then
	do
		function surface.MouseInRect(x, y, w, h)
			local mx, my = gui.MousePos()
			return (mx >= x and mx <= x + w and my >= y and my <= y + h)
		end
	end
end

do
	local color_meta = FindMetaTable("Color")

	function color_meta:Darken(amt)
		return Color(
		math.Clamp(self.r - amt, 0, 255),
		math.Clamp(self.g - amt, 0, 255),
		math.Clamp(self.b - amt, 0, 255),
		self.a
		)
	end

	function color_meta:Lighten(amt)
		return Color(
		math.Clamp(self.r + amt, 0, 255),
		math.Clamp(self.g + amt, 0, 255),
		math.Clamp(self.b + amt, 0, 255),
		self.a
		)
	end

	function color_meta:Alpha(amt)
		return ColorAlpha(self, amt or 255)
	end
end

do
	local function run_comp(key, value, t2)
		if !istable(value) then
			if value != t2[key] then
				return false
			end
		else
			if !table.equal(value, t2[key]) then
				return false
			end
		end

		return true
	end

	function table.equal(tab1, tab2)
		if !istable(tab1) or !istable(tab2) then return false end
		if tab1 == tab2 then return true end

		local t1, t2 = 0, 0

		for k, v in pairs(tab1) do
			t1 = t1 + 1

			if !run_comp(k, v, tab2) then
				return false
			end
		end

		for k, v in pairs(tab2) do
			t2 = t2 + 1

			if !run_comp(k, v, tab1) then
				return false
			end
		end

		if t1 != t2 then return false end

		return true
	end
end

function table.hash(tab)
	return tostring(tab):gsub('table: 0x', '')
end
