-- =========================
-- Advanced Logging System
-- =========================

-- Config for logging
local config = {
    Verbosity = 8,          -- up to DEBUG4 (0=NONE, 9=MAX)
    CascadingLogs = true,  -- show all levels <= Verbosity
    DebugDeluxe = true     -- show function names
}

-- Log levels
local LogLevel = { 
    NONE        = 0,
    ERROR       = 1,
    ESSENTIAL   = 2,
    EVENT       = 3,
    INFO        = 4,
    DEBUG1      = 5,
    DEBUG2      = 6,
    DEBUG3      = 7,
    DEBUG4      = 8,
    MAX         = 9
}

-- Internal advanced logger
local function AdvancedLog(Mod, Level, Msg)
    local CurrentVerbosity = config.Verbosity or 0

    if config.CascadingLogs then
        if Level > CurrentVerbosity then return end
    else
        if Level ~= CurrentVerbosity then return end
    end

    local LevelName = "UNKNOWN"
    for name, num in pairs(LogLevel) do
        if num == Level then LevelName = name break end
    end

    if config.DebugDeluxe then
        local info = debug.getinfo(3, "n")
        local FuncName = info and info.name or "Unknown"
        print(string.format("[%s][%s][%d][%s] %s", Mod, LevelName, Level, FuncName, Msg))
    else
        print(string.format("[%s][%s][%d] %s", Mod, LevelName, Level, Msg))
    end
end

-- Compatibility wrapper (keeps existing Log() calls unchanged)
local function Log(Mod, Level, Msg)
    if type(Level) == "string" then
        AdvancedLog(Mod, LogLevel[Level] or LogLevel.INFO, Msg)
    else
        AdvancedLog(Mod, Level, Msg)
    end
end

-- =========================
-- MOD CODE (UNCHANGED)
-- =========================

local ModName = "Dual-Throw_SphereSummon"

local WorldIsActive, ModInitialized = false, false
local IsSummoning, OtomoThrowActive, sphereActor = false, false, nil
local CachedPC, CachedChar, CachedHolder, CachedShooter = nil, nil, nil, nil
local isPalActive, APalIsSummoned, WasThrowKeyPressed = false, false, false
local previousWeapon = nil


local SummonKeyKBM = "E" -- mod summon key

-- Cache player context
local function UpdateContextCache()
    if not CachedPC or not CachedPC:IsValid() then
        CachedPC = FindFirstOf("PalPlayerController")
    end
    if CachedPC and CachedPC:IsValid() then
        CachedChar = CachedPC.Character
        CachedHolder = FindFirstOf("BP_OtomoPalHolderComponent_C")
        CachedShooter = CachedChar.ShooterComponent
    end
    return CachedPC and CachedPC:IsValid() and CachedChar and CachedChar:IsValid()
end

-- Start the summon aim (sphere in hand)
local function InitiateSummonAim(ctx)
    local selector = ctx.Char.LoadoutSelectorComponent
    local ball = selector and selector.ThrowOtomoPalWeapon
    if not ball or not ball:IsValid() then return end

    -- Save previous weapon safely (only once, and never sphere)
    if not previousWeapon then
        local current = ctx.Shooter:GetHasWeapon()
        if current and current:IsValid() and current ~= ball then
            previousWeapon = current
            Log(ModName, "DEBUG1", "Saved previous weapon")
        end
    end

    ctx.Shooter:AttachWeapon(ball, false)
    ctx.Shooter:SetAiming(1, false)

    IsSummoning = true
    OtomoThrowActive = true
    Log(ModName, "INFO", "Summon aim started (sphere in hand)")
end


-- Handle releasing the throw
local function ExecuteThrowRelease(ctx)
    if not OtomoThrowActive then return end
    ctx.Shooter:EndAim(false)
    IsSummoning = false
    Log(ModName, "INFO", "Summon throw released")
    OnInternalThrow()
end

-- Handle key press for summon/recall
local function tickButtonPress()
    if not WorldIsActive or not ModInitialized then return end
    if not UpdateContextCache() then return end

    local ctx = { PC=CachedPC, Char=CachedChar, Holder=CachedHolder, Shooter=CachedShooter }

    local Pressed = ctx.PC:WasInputKeyJustPressed({KeyName=FName(SummonKeyKBM)})
    local Released = ctx.PC:WasInputKeyJustReleased({KeyName=FName(SummonKeyKBM)})

    if Pressed then
        -- If a Pal is already out, recall it
        if ctx.Holder:IsActivatedSelectOtomo() then
            ctx.Holder:RecallOtomo()
            ctx.PC:SendServerRequest("/Server/PalRequest", {action="Recall"})
            return
        end

        -- Start summon aim
        if not IsSummoning then
            InitiateSummonAim(ctx)
        end
    end

    if Released and IsSummoning then
        ExecuteThrowRelease(ctx)
    end
end

-- When sphere spawns, handle server communication and cleanup
local function OnInternalThrow()
    if not OtomoThrowActive then return end

    local spheres = FindAllOf("BP_PalSphere_ThrowObject_C")
    if spheres and #spheres > 0 then
        sphereActor = spheres[#spheres]
        OtomoThrowActive = false

        ExecuteWithDelay(50, function()
            if not sphereActor or not sphereActor:IsValid() then return end

            local pos = sphereActor:K2_GetActorLocation()
            local rot = sphereActor:K2_GetActorRotation()

            -- Destroy sphere locally
            ExecuteWithDelay(500, function()
                if sphereActor and sphereActor:IsValid() then
                    sphereActor:K2_DestroyActor()
                end
                sphereActor = nil
            end)
        end)
    end
end
-- =========================
-- Cleanup / Shutdown
-- =========================
local function Cleanup()
    Log(ModName, "ESSENTIAL", "Cleanup triggered.")

    -- Safely stop aiming & restore weapon
    if CachedShooter and CachedShooter:IsValid() then
        CachedShooter:EndAim(false)

        if previousWeapon and previousWeapon:IsValid() then
            CachedShooter:AttachWeapon(previousWeapon, false)
        end
        
    end

    -- Reset primary state
    WorldIsActive, ModInitialized = false, false

    -- Summon state
    IsSummoning = false
    OtomoThrowActive = false
    WasThrowKeyPressed = false

    -- Actor references
    sphereActor = nil
    previousWeapon = nil

    -- Cached references
    CachedPC = nil
    CachedChar = nil
    CachedHolder = nil
    CachedShooter = nil

    -- Pal state flags
    isPalActive = false
    APalIsSummoned = false
end
-- Initialization
local function OnInitialize(context)
    ModInitialized, WorldIsActive = true, true
    Log(ModName, "ESSENTIAL", "Mod Initialized and Ready")

    if not _G.SummonHooksRegistered then
        RegisterHook("/Game/Pal/Blueprint/Controller/BP_PalPlayerController.BP_PalPlayerController_C:ReceiveTick", tickButtonPress)
        RegisterHook("/Game/Pal/Blueprint/Weapon/BP_CapturePrism.BP_CapturePrism_C:OnThrowInternal", OnInternalThrow)
        RegisterHook("/Game/Pal/Blueprint/Character/Player/Female/BP_Player_Female.BP_Player_Female_C:ReceiveEndPlay",Cleanup)
        _G.SummonHooksRegistered = true
    end
end

RegisterHook("/Script/Pal.PalPlayerCharacter:OnCompleteInitializeParameter", OnInitialize)
Log(ModName, "ESSENTIAL", "Throw Sphere Summon Mod Loaded")
