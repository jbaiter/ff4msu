//bass
//arch=snes-cpu
mapper lorom

namespace fadeout

define fadestep $102A
define hdma_fadeout_blank $102B
define hdma_fadeout_l1_bright $102E
define hdma_fadeout_l2_bright $1030

main:
    rep #$20    // 16bit accumulator
    sep #$10    // 8bit x/y


    // Upload fadeout HDMA blanking table to RAM
    // TODO: Do this via DMA, saves some cycles
    ldx #$00
    lda #$8f28  // turn off line 1-40
    sta {hdma_fadeout_blank}
    inx
    inx
    lda #$0f7f  // turn on line 41-247
    sta {hdma_fadeout_blank}+x
    inx
    inx
    lda #$0f11  // turn on line 247-264
    sta {hdma_fadeout_blank}+x
    inx
    inx
    lda #$8f01  // turn off rest of the lines
    sta {hdma_fadeout_blank}+x
    inx
    inx
    lda #$0000  // done
    sta {hdma_fadeout_blank}+x

    sep #$20    // 8bit accumulator
    rep #$10    // 16bit x/y
    stz $420c   // Disable HDMA
    // Setup HDMA blanking (ch1)
    lda #$00        // A to B; direct; 1x single reg
    sta $4310       // ch. 1 for blanking
    lda #$00        // 2100 = inidisp
    sta $4311
    lda #$00
    ldy #{hdma_fadeout_blank}
    sty $4312
    sta $4314
    lda #$0e
    sta $420c   // Enable HDMA ch1-3

    sep #$30    // 8bit registers
    ldy  #$0f       // max brightness

    loop:
    ldx #$06    // fade out length in frames per step
    stx {fadestep}
    // lower brightness
    dec {hdma_fadeout_l1_bright}
    dec {hdma_fadeout_l2_bright}
    // lower volume
    lda {msu::current_volume}
    sec
    sbc #$10    // decrease by 16
    sta {msu::current_volume}
    sta {msu::MSU_VOLUME}


    wait:
    lda $4210   // vertical blank active?
    and #$80
    beq wait    // if no wait
    dec {fadestep}  // if yes
    ldx {fadestep}
    cpx #$00
    bne wait
    ldy {hdma_fadeout_l2_bright}
    cpy #$00    // are we at lowest brightness yet?
    bne loop
    dark:
    lda $4210   // vertical blank active?
    and #$80
    beq dark
    rts

