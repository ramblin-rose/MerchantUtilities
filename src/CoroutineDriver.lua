--[[
	CoroutineDriver is a singleton used for driving a coroutine.
]]
local addonName = ...
local AddOn = _G[addonName]
local CoroutineDriver = {}

local CO_SUSPENDED = "suspended"
local CO_DEAD = "dead"
--------------------------------
local function initInstance(that, frame, interval, resolution)
	that.frame = frame
	that.interval = interval or 0
	that.resolution = resolution or 1.0
	frame:SetScript("OnUpdate", function()
		that:OnUpdate()
	end)
	return that
end
--------------------------------
function CoroutineDriver:new(frame, interval, resolution)
	local ctor = {}
	setmetatable(ctor, {
		__index = self,
		__tostring = function()
			return "CoroutineDriver"
		end,
	})
	return initInstance(ctor, frame, interval, resolution)
end
--------------------------------
function CoroutineDriver:Reset()
	self.driver = nil
end
--------------------------------
-- doWorkFn
--		Must return true when all work is done
-- 		Must call yield() to defer work
-- 		Must exit with return of true immediately if yield() returns true
-- optPostProcessFn
-- 		Invoked after doWorkFn has completed.  This function runs on
-- 		the main thread of execution, unlike doWorkFn
function CoroutineDriver:Start(doWorkFn, optPostProcessFn)
	if not self:IsAlive() then
		self.stop = false
		self.driver = coroutine.create(function()
			self:Run(doWorkFn, optPostProcessFn)
		end)
	end
end
--------------------------------
function CoroutineDriver:IsAlive()
	if not self.driver then
		return false
	end
	return coroutine.status(self.driver) ~= CO_DEAD
end
--------------------------------
function CoroutineDriver:TryResume()
	if self:IsAlive() and coroutine.status(self.driver) == CO_SUSPENDED then
		coroutine.resume(self.driver, self.stop)
	end
end
--------------------------------
function CoroutineDriver:Stop()
	if self:IsAlive() then
		self.stop = true
		coroutine.resume(self.driver, true)
	end
end
--------------------------------
function CoroutineDriver:ShouldStop()
	return self.stop
end
--------------------------------
function CoroutineDriver:ShouldResume()
	if self:IsAlive() and GetTime() > self.interval then
		self.interval = GetTime() + self.resolution
		return true
	end
	return false
end
--------------------------------
function CoroutineDriver:OnUpdate()
	if self:IsAlive() and self:ShouldResume() then
		self:TryResume()
	end
end
--------------------------------
function CoroutineDriver:Run(doWork, postProcess)
	doWork()
	self:Reset()
	if postProcess then
		postProcess()
	end
end
--------------------------------
AddOn.CoroutineDriver = CoroutineDriver
