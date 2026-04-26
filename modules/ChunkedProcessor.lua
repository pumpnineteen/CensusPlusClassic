local MAJOR, MINOR = "LibChunkedProcessor-1.0", 1
local lib = LibStub:NewLibrary(MAJOR, MINOR)
if not lib then return end

lib.DEFAULT_CHUNK_SIZE = 500

local C_Timer = C_Timer
local type    = type
local pairs   = pairs
local assert  = assert

lib.processes = lib.processes or {}

function lib:ProcessLargeTable(t, config)
    assert(type(t) == "table",              "ProcessLargeTable: t must be a table")
    assert(type(config) == "table",         "ProcessLargeTable: config must be a table")
    assert(type(config.computation) == "function", "ProcessLargeTable: config.computation must be a function")

    local computation = config.computation
    local chunkSize   = config.chunkSize or lib.DEFAULT_CHUNK_SIZE
    local onDone      = config.onDone  -- optional, function(job)

    local job = {}
    job.status = "idle"

    local iter, state, initial = config.iterator and config.iterator(t) or pairs(t)

    local co = coroutine.create(function()
        local count = 0
        for k, v in iter, state, initial do
            computation(k, v)
            count = count + 1
            if count % chunkSize == 0 then
                coroutine.yield()
            end
        end
    end)

    local function _cleanup()
        if config.processName then
            lib.processes[config.processName] = nil
        end
    end

    local function step()
        if job.status ~= "running" then return end  -- paused or cancelled, stop ticking

        local ok, err = coroutine.resume(co)
        if not ok then
            job.status = "cancelled"
            _cleanup()
            error("ProcessLargeTable coroutine error: " .. tostring(err))
        end

        if coroutine.status(co) == "dead" then
            job.status = "completed"
            _cleanup()
            if onDone then onDone(job) end
        else
            C_Timer.After(0, step)
        end
    end

    function job:start()
        if self.status ~= "idle" then
            print("|cffff9900Warning:|r ProcessLargeTable job:start() called on a non-idle job (status: " .. self.status .. ")")
            return
        end
        self.status = "running"
        step()
    end

    function job:pause()
        if self.status ~= "running" then
            print("|cffff9900Warning:|r ProcessLargeTable job:pause() called on a non-running job (status: " .. self.status .. ")")
            return
        end
        self.status = "paused"
        -- step() will naturally stop ticking since it checks status at the top
    end

    function job:resume()
        if self.status ~= "paused" then
            print("|cffff9900Warning:|r ProcessLargeTable job:resume() called on a non-paused job (status: " .. self.status .. ")")
            return
        end
        self.status = "running"
        step()  -- re-enter the tick loop
    end

    function job:cancel()
        if self.status ~= "running" and self.status ~= "paused" then
            print("|cffff9900Warning:|r ProcessLargeTable job:cancel() called on a non-active job (status: " .. self.status .. ")")
            return
        end
        self.status = "cancelled"
        _cleanup()
        if onDone then onDone(self) end
    end

    if config.processName then
        if lib.processes[config.processName] then
            print("|cffff9900Warning:|r ProcessLargeTable job with name '" .. config.processName .. "' already exists!")
            return nil
        end
        lib.processes[config.processName] = job
    end

    return job
end

function lib:GetProcess(processName)
    return lib.processes[processName]
end

function lib:CancelProcess(processName)
    local job = lib.processes[processName]
    if job then
        job:cancel()
    end
end

function lib:PauseProcess(processName)
    local job = lib.processes[processName]
    if job then
        job:pause()
    end
end

function lib:ResumeProcess(processName)
    local job = lib.processes[processName]
    if job then
        job:resume()
    end
end


-- Usage example (flat table):
--
-- local job = lib:ProcessLargeTable(MyAddon.myTable, {
--     processName = "myJob",
--     chunkSize   = 200,
--     computation = function(k, v)
--         -- your work here
--     end,
--     onDone = function(job)
--         if job.status == "completed" then
--             print("Done!")
--         elseif job.status == "cancelled" then
--             print("Cancelled.")
--         end
--     end,
-- })
-- job:start()


-- Usage example (deep table: realm->faction->race->class->name):
--
-- local function deepIterator(t)
--     local co = coroutine.wrap(function()
--         for realm, factions in pairs(t) do
--             for faction, races in pairs(factions) do
--                 for race, classes in pairs(races) do
--                     for class, names in pairs(classes) do
--                         for name, data in pairs(names) do
--                             coroutine.yield(name, data)
--                         end
--                     end
--                 end
--             end
--         end
--     end)
--     return co, nil, nil
-- end
--
-- local job = lib:ProcessLargeTable(MyAddon.myDeepTable, {
--     processName = "deepJob",
--     iterator    = deepIterator,
--     computation = function(name, data)
--         -- your work here
--     end,
--     onDone = function(job)
--         print("Status: " .. job.status)
--     end,
-- })
-- job:start()