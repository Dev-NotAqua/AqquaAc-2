-- Copyright (C) 2019 - 2023  NotSomething

-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.

-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.

-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <https://www.gnu.org/licenses/>.

-- Simple logging utility for AqquaAC
log = {
    info = function(message)
        print('^2[INFO]^7 ' .. tostring(message))
    end,
    
    warn = function(message)
        print('^3[WARN]^7 ' .. tostring(message))
    end,
    
    error = function(message)
        print('^1[ERROR]^7 ' .. tostring(message))
    end,
    
    trace = function(message)
        local logLevel = GetConvarInt('vac:internal:log_level', 1)
        if logLevel >= 2 then
            print('^5[TRACE]^7 ' .. tostring(message))
        end
    end
}