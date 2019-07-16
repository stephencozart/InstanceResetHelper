----------------------------------------------------------------------
-- Namespaces
----------------------------------------------------------------------
local _, core = ...

core.irh = {
    dungeonName = nil,
    counter = 1,
    timeElapsed = 0,
    setDungeonName = function(self, dungeonName)        
        self.dungeonName = dungeonName
    end,
    resetCounter = function(self)
        self.counter = 1
    end,
    incrementCounter = function(self)    
        self.counter = self.counter + 1        
    end,
    incrementTimer = function(self)
        self.timeElapsed = self.timeElapsed + 1        
    end,
    resetTimer = function(self)
        self.timeElapsed = 0
    end,
    secondsToClock = function(self)
        local seconds = tonumber(self.timeElapsed)
      
        if seconds <= 0 then
          return { '00', '00', '00' }
        else
          hours = string.format("%02.f", math.floor(seconds/3600));
          mins = string.format("%02.f", math.floor(seconds/60 - (hours*60)));
          secs = string.format("%02.f", math.floor(seconds - hours*3600 - mins *60));
          return {
              hours,
              mins,
              secs
          }
        end
      end      
}