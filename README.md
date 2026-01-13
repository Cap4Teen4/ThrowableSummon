# ThrowableSummon
## Palworld Throwable Sphere Summon Mod

**A client-side mod for Palworld that allows you to summon and throw spheres to spawn your Pals in a fun, 
interactive way.
main.lua = Proper Mod!**

- **Istall Path:
"Palworld\Pal\Binaries\Win64\ue4ss\Mods\"
Make Folder Named - **ThrowableSummon** - Drag main.lua into it**

Testing-main.lua = Walk Speed Playing with..(Dont Need to Worry Unless Dev Helping)
---

### Overview

I’ve been tinkering with this mod to figure out how to make it work on both single-player and dedicated server setups. This started as a personal project, but my wife dared me to get it working for our server—so here we are!

- I have Default Palworld Summon Keybind: E (Swapped with Z)
- Setup: Stripped-down version for building/testing dedicated server support
- Works on a 2-person dedicated server (me & my wife)
- Also tested with Server of 12, Thanks to a Friend
- Client-side only; the other player doesn’t need the mod installed

---

### Updates ✨

- Press E → Sphere appears in hand
- Throw sphere → Spawn your Pal
- Press 1 or 2 → Swap active Pals
- Press Shift + E → Reset movement speed while holding sphere
- Scroll wheel → Swap weapons without issues

---

### Features ✅ / Bugs 🐞/ How It Works 🎮

- Step 1 → [Press E] → Bring the sphere into your hand
- Step 2 → [LeftClick] Throw sphere → Spawn your Pal at the target location
- Step 3 → [Press 1] or [Press 2] → Swap active Pals
- Step 4 → [Press Shift + E] → Reset movement speed while holding the sphere
- Step 5 → [Scroll wheel Up or Down] → Swap weapons → Removes Sphere From Hand!

**Note** 
- If Scroll Wheeled to get weapons [Start Loop From Step 1 - 4 ] For the Sphere In Hand again
- Your Alternative What you Swapped [Default Palworld Summon Keybind:] [Into Z] 

- Cant Re Equip Sphere if Same Pet is Selected Via 1 - 2 that you have Summoned! 
- Example: I Spwaned NiteWing, If i Scroll Wheel and get a gun.. and then want the Sphere you must have a Different one Selected
- ONLY WAY AROUND THAT (Press your Default Set Palworld Keybind you Picked for Spawning/Recalling Pals. Recall NightWing
(i use Z or I) - (Depends What im Doing)

- Works on a dedicated server without lag

⚠️ The summon key (E) cannot currently be the same as the Sphere Summon Key must assign a different key. ⚠️

---

### Known Issues ⚠️

- Weapon/Ball not removed from hand: When you summon/throw a sphere, the attached weapon/ball remains in your hand.
- Keybind limitations: Summon key (E) doesn’t work if it matches the Throw Summon key—you must assign a different key.
- Other player visibility:
  - Other players see the Pal spawn far away and see the throw animation.
  - They do not see the sphere in the air.
  - Mod is client-side only; they don’t need it installed.

---

### Current Setup 🔧

- Tested on 2-player dedicated server
- Client-side only, works without lag for both host and client
- Supports keybind swapping between default Palworld keys and mod-specific keys

---

Notes 🗒️

- Work-in-progress mod!
- Some fixes may need revisiting due to a pause in development!
- Contributions and suggestions are welcome! Reach out @ - Discord: oreos5285

---

Links 🔗
- Old Paste Bin:
- (Pastebin): https://pastebin.com/R23K8Uer

- Discord: oreos5285
