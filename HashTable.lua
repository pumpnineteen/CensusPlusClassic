
local HashTable = {}
HashTable.__index = HashTable
HashTable.__len = function(self)
    return self.count
end

function HashTable.new()
    local self = setmetatable({}, HashTable)
    self.items = {}
    self.count = 0
    return self
end

HashTable.__newindex = function(self, key, value)
    if value == nil then
        self:remove(key)
    else
        self:set(key, value)
    end
end

HashTable.__tostring = function(self)
    local parts = {}
    for k,v in pairs(self.items) do
        table.insert(parts, string.format("%s=%s", tostring(k), tostring(v)))
    end
    return "HashTable{" .. table.concat(parts, ", ") .. "}"
end

function HashTable:set(key, value)
    if key == nil then
        error("HashTable key cannot be nil")
    end
    if self.items[key] == nil then
        self.count = self.count + 1
    end
    self.items[key] = value
end

function HashTable:remove(key)
    if self.items[key] ~= nil then
        self.items[key] = nil
        self.count = self.count - 1
    end
end

function HashTable:get(key)
    return self.items[key]
end

function HashTable:len()
    return self.count
end

function HashTable:pairs()
    return pairs(self.items)
end

function HashTable:clear()
    self.items = {}
    self.count = 0
end

function HashTable:has(key)
    return self.items[key] ~= nil
end

function HashTable:keys()
    local keys = {}
    for k, _ in pairs(self.items) do
        table.insert(keys, k)
    end
    return keys
end

function HashTable:values()
    local values = {}
    for _, v in pairs(self.items) do
        table.insert(values, v)
    end
    return values
end

function HashTable:clone()
    local clone = HashTable.new()
    for k, v in pairs(self.items) do
        clone:set(k, v)
    end
    return clone
end

function HashTable:update(other)
    for k, v in other:pairs() do
        self:set(k, v)
    end
    return self
end

function HashTable:find(value)
    for k, v in pairs(self.items) do
        if v == value then
            return k
        end
    end
    return nil
end

function HashTable:filter(predicate)
    local result = HashTable.new()
    for k, v in pairs(self.items) do
        if predicate(k, v) then
            result:set(k, v)
        end
    end
    return result
end

function HashTable:map(transform)
    local result = HashTable.new()
    for k, v in pairs(self.items) do
        result:set(k, transform(v))
    end
    return result
end

function HashTable:ifilter(predicate)
    local iter, state, var = pairs(self.items)
    return function()
        local k, v
        repeat
            k, v = iter(state, var)
            var = k
            if k == nil then return nil end
        until predicate(k, v)
        return k, v
    end
end

function HashTable:imap(transform)
    local iter, state, var = pairs(self.items)
    return function()
        local k, v = iter(state, var)
        if k == nil then return nil end
        return k, transform(v)
    end
end

return HashTable
