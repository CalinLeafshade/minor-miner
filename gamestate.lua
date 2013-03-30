--Gamestate.lua
require('datadumper')

GameState = {}

function GameState:new(slot)
    o = {}
    setmetatable(o, self)
    self.__index = self
    o.Slot = slot
    o.Room = "CA8"
    o.Map = {}
    o.Visited = {}
    return o
end

function GameState:Filename()
    return "slot" .. self.Slot .. ".lua"
end

function GameState:Save()
    -- collect data
    self.Room = Room.Current.Name
    self.MaxHP = Game.Player.MaxHP
    self.PlayerX, self.PlayerY = Game.Player.Collider:center()
    
    local data, err = DataDumper(self, nil, true, 0)
    love.filesystem.write(self:Filename(), data)
    return true
end

function GameState.Load(Slot)
    local f = "slot" .. Slot .. ".lua"
    local data = love.filesystem.load(f)
    
    local state = data()
    setmetatable(state, GameState)
    state.__index = GameState
    return state
end