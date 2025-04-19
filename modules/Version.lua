local addon_name, CPp = ...

-- Version information
local CensusPlus_Version_Major = "0" -- changing this number will force a saved data purge
local CensusPlus_Version_Minor = "8" -- changing this number will force a saved data purge
local CensusPlus_Version_Maint = "4"
local CensusPlus_SubVersion = ""
local CensusPlus_VERSION = CensusPlus_Version_Major.."."..CensusPlus_Version_Minor.."."..CensusPlus_Version_Maint
local CensusPlus_VERSION_FULL = CensusPlus_VERSION -- .."."..CensusPlus_SubVersion
local CensusPlus_PTR = GetCVar("portal") == "public-test" and "PTR" -- enable true for PTR testing enable false for live use

-- Make constants available to addon
CPp.CensusPlus_VERSION = CensusPlus_VERSION
CPp.CensusPlus_VERSION_FULL = CensusPlus_VERSION_FULL 
CPp.CensusPlus_PTR = CensusPlus_PTR
