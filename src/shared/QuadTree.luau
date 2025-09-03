--!strict
local QuadTree = {}
QuadTree.__index = QuadTree

export type Quad = {
	Origin: Vector3,
	Size: Vector3,
	NW: Quad? | Leaf?,
	NE: Quad? | Leaf?,
	SW: Quad? | Leaf?,
	SE: Quad? | Leaf?,
}

export type Leaf = {
	[Vector3]: { [any]: any },
}

local parts = {}

local function makePart(Origin, Size, DepthPercent)
	local p = Instance.new("Part")
	p.CanCollide = false
	p.CanQuery = false
	p.Anchored = true
	p.Position = Origin
	p.Size = Size
	table.insert(parts, p)
	p.Transparency = 0.8
	p.Color = Color3.new(0, 0, 1):Lerp(Color3.new(1, 0, 0), DepthPercent)
	p.Parent = workspace
end
task.spawn(function()
	while true do
		task.wait()
		for i, v in parts do
			v:Destroy()
		end
		table.clear(parts)
	end
end)

local function makeQuad(Origin, Size): Quad
	return {
		Origin = Origin,
		Size = Size,
	}
end

local function getQuadAt(Quad: Quad, Index: "NW" | "NE" | "SW" | "SE")
	if Quad[Index] then
		return Quad[Index]
	else
		local scale = Vector3.new(Index:sub(2, 2) == "E" and 0.25 or -0.25, Index:sub(1, 1) == "N" and 0.25 or -0.25)
		local Position = Quad.Origin + Quad.Size * scale
		local Size = Quad.Size / 2
		Quad[Index] = makeQuad(Position, Size)
		return Quad[Index]
	end
end

function QuadTree.new(Origin: Vector3, Size: Vector3, Resolution: Vector3)
	local self = setmetatable({}, QuadTree)

	self.Root = makeQuad(Origin, Size)

	-- calculate max recursion depth
	local v = Size / Resolution
	self.MaxDepth = math.min(v.X, v.Y) - 1

	return self
end

function QuadTree:Insert(Position: Vector3, Data: any)
	local Key = Vector3.new(Position.X, Position.Y)
	local tailQuad: Quad = self.Root
	local Leaf: Leaf

	--check if position lies out of root quad
	if
		Position.X > tailQuad.Origin.X + tailQuad.Size.X
		or Position.X < tailQuad.Origin.X - tailQuad.Size.X
		or Position.Y > tailQuad.Origin.Y + tailQuad.Size.Y
		or Position.Y < tailQuad.Origin.Y - tailQuad.Size.Y
	then
		return
	end

	local Depth = 0
	--traverse tree to find where to insert the data
	while true do
		makePart(tailQuad.Origin, tailQuad.Size, Depth / self.MaxDepth)
		Depth += 1
		-- break when found quad is smaller than the resolution

		local index = "" :: any
		if Position.Y > tailQuad.Origin.Y then
			index ..= "N"
		else
			index ..= "S"
		end
		if Position.X > tailQuad.Origin.X then
			index ..= "E"
		else
			index ..= "W"
		end

		if Depth == self.MaxDepth then
			Leaf = tailQuad[index] or {}
			if Leaf[Position] then
				table.insert(Leaf[Position], Data)
			else
				Leaf[Position] = { Data }
			end
			break
		end

		tailQuad = getQuadAt(tailQuad, index)
	end
end

function QuadTree:Clear()
	self.Root = makeQuad(self.Root.Origin, self.Root.Size)
end

return QuadTree
