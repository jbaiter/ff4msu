//bass
//arch=snes-cpu
namespace soundtrack

define TRACK_ID $1e01

org $048004
    jml init

track_table:
// TODO: Are track numbers decimal or hex?
// $FFFF = play using original soundtrack routine
    db $ffff    // 00: Empty track
    db $0009    // 01: Final Fantasy Theme
    db $ffff    // 02: Wishing Tower
    db $ffff    // 03: Fanfare (Dummy)
    db $ffff    // 04: Yellow Chocobo
    db $ffff    // 05: Black Chocobo
    db $ffff    // 06: Underworld
    db $ffff    // 07: Zeromus
    db $0011    // 08: Victory Fanfare
    db $0008    // 09: Town
    db $0017    // 0A: Rydia
    db $ffff    // 0B: Boss Music
    db $0021    // 0C: Mt. Ordeals
    db $0035    // 0D: Overworld
    db $0041    // 0E: Big Whale
    db $ffff    // 0F: Sad Music
    db $ffff    // 10: Tent/Cabin
    db $0025    // 11: Golbez
    db $0019    // 12: Sorrow
    db $ffff    // 13: Rosa
    db $ffff    // 14: Baron Castle
    db $0003    // 15: The Prelude
    db $0024    // 16: Suspicions
    db $0039    // 17: Tower of Zot
    db $0031    // 18: Airship
    db $0034    // 19: Tower of Bab-il
    db $0015    // 1A: Fight 2
    db $0044    // 1B: Within the Giant
    db $ffff    // 1C: Cave of Summoned Monsters
    db $ffff    // 1D: Destruction
    db $ffff    // 1E: Lunar Path
    db $ffff    // 1F: Surprise!
    db $0036    // 20: Dwarf Castle
    db $0029    // 21: Palom/Porom
    db $0038    // 22: Calcobrena
    db $0023    // 23: Hurry!
    db $0026    // 24: Cid
    db $0014    // 25: Into the Darkness
    db $ffff    // 26: Dancing Music
    db $ffff    // 27: Fight 1
    db $ffff    // 28: Castle Eblan
    db $ffff    // 29: Character Joined!
    db $ffff    // 2A: Character Died
    db $ffff    // 2B: Chocobo Forest
    db $ffff    // 2C: Opening
    db $ffff    // 2D: Sad 2
    db $ffff    // 2E: Castle Fabul
    db $ffff    // 2F: Fanfare (Became a Paladin)
    db $ffff    // 30: Lard Ass Chocobo
    db $ffff    // 31: Moon's Surface
    db $ffff    // 32: Toroia
    db $ffff    // 33: Mysidia
    db $ffff    // 34: Lunar Subterrane
    db $ffff    // 35: Ending Part 1
    db $ffff    // 36: Ending Part 2
    db $ffff    // 37: Ending Part 3

// DESIGN:
//  1. Check for presence of MSU and jump to original soundcode if not
//  2. Look up corresponding track number from table
//  3. Fade out old track [RLY?]
//  4. Initialize playback of new track, fade in

init:
    rep #$20    // 8bit ACL
    lda {msu::msu_present}
    cmp #$00
    beq end
    rep #$30    // 8bit registers
    // TODO:
    //  - stop MSU playback
    //  - set empty track on SPC
    ldx {TRACK_ID}
    lda {track_table}+x // Get track number
    stz {msu::MSU_TRACK}
    sta {msu::MSU_TRACK}+1
    // TODO:
    //  - set desired volume (usually 255)
    //  - set repeat value (usually true)
    //  - set playback bit

end:
    // TODO: Add overwritten pieces of original soundcode here
    jml $048008
