//bass
//arch=snes-cpu
mapper lorom

namespace joypad
define joy1raw $101e
define joy2raw $1020
define joy1press $1022
define joy2press $1024
define joy1held $1026
define joy2held $1028

main:
    lda $4212   // Auto-read joypad status
    and #$01
    bne main    // Read is done when 0

    rep #$30    // All registers to 16bit
    
    // player1
    // TODO: Is all that storing, logging, etc, really neccesary?
    //       Why not just read the joypad during VBlank and be done with it?
    ldx {joy1raw}   // Load log of last frame's raw read of $4218
            // Will be 0 the first time read, ofc 
    lda $4218   // Read current frame's raw joypad data
    sta {joy1raw}   // Save it for next frame
    txa     // Transfer last frame input from x to a
    eor {joy1raw}   // XOR last frame input with current frame input
            //   - shows the changes in input
            //   - buttons just pressed or just released become set.
            //   - held or unactive buttons are 0
    and {joy1raw}   // AND changes to current frame's input
            // This ends up leaving you with the only buttons
            //  that are pressed... MAGIC!
    sta {joy1press} // store just pressed buttons
    txa     // Transfer last frame input from x to a, again
    and {joy1raw}   // Find buttons that are still held
    sta {joy1held}  // ...by storing only buttons pressed in both frames
    
    // player2
    ldx {joy2raw}
    lda $421a   // Read joypad2 regs
    sta {joy2raw}
    txa
    eor {joy2raw}   // find just triggered buttons
    and {joy2raw}
    sta {joy2press}
    txa
    and {joy2raw}
    sta {joy2held}

    // are only standard joypads connected?
    // TODO: Can't we skip this shit?
    sep #$20
    ldx #$0000  // we'll clear recorded input if pad is invalid
    lda $4016   // joypad1 - now we read this (after we stored
            //   a 0 to it earlier)
    bne check2  // $4016 returns 0 if not connected, 1 if connected
    stx {joy1raw}   // otherwise clear all recorded input
    stx {joy1press}
    stx {joy1held}

check2:
    lda $4017   // joypad2
    bne done    // 0=not connected
    stx {joy2raw}
    stx {joy2press}
    stx {joy2held}

done:
    rts
