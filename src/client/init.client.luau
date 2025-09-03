local QuadTree = require(game.ReplicatedStorage.Shared.QuadTree)

local a = Instance.new("Part")
a.Parent = workspace
a.Anchored = true
a.CanCollide = false
a.CanQuery =false
a.Size = Vector3.one
a.Position = Vector3.new(0, 0, 0)

local tree = QuadTree.new(Vector3.zero, Vector3.new(100,200,0), Vector3.new(10,10,0))

while true do
    tree:Clear()
    tree:Insert(a.Position, true)
    task.wait()
end
