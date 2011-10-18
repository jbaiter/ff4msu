//bass
//arch=snes-cpu
mapper lorom

namespace msu
// MSU1 constants
// .read
define MSU_STATUS $2000
define MSU_READ $2001
define MSU_ID $2002
// .write
define MSU_SEEK_OFFSET $2000
define MSU_SEEK_BANK $2002
define MSU_TRACK $2004
define MSU_VOLUME $2006
define MSU_CONTROL $2007

// General variables
define msu_present $103f
define vid_seek_addr $1036
define vid_seek_bank $103a
define audio_track $103c
define current_volume $1035

// Video variables
define dispcnt $1000
define stddur $1002 // standard picture duration in fields
define altdur $1004 // alternate picture duration in fields
define altcnt $1006 // use alternate picture duration every n frames
define curdur $1008 // current valid duration
define curcnt $100a // current frame count for picture duration
define numframes $100c
define firstframe $100e
define charptr $1010

check:
print "msu::check: {$}"
    sep #$20
    lda {MSU_ID}
    cmp #$53    // 'S'
    bne skip        // Stop checking if it's wrong
    lda {MSU_ID}+1
    cmp #$2D    // '-'
    bne skip
    lda {MSU_ID}+2
    cmp #$4D    // 'M'
    bne skip
    lda {MSU_ID}+3
    cmp #$53    // 'S'
    bne skip
    lda {MSU_ID}+4
    cmp #$55    // 'U'
    bne skip
    lda {MSU_ID}+5
    cmp #$31    // '1'
    bne skip
    lda #$ff
    sta {msu_present}
    rts

skip:
    stz {msu_present}
    rts


print "msu::init: {$}"
init:
    sep #$20
    rep #$10
    ldx {vid_seek_addr}
    stx {MSU_SEEK_OFFSET}   // Select video start offset
    ldx {vid_seek_bank}
    stx {MSU_SEEK_BANK}
-;  bit {MSU_STATUS}    // Wait until MSU1 is ready
    bmi {-}

    ldx {audio_track}
    stx {MSU_TRACK}     // Select audio track
-;  bit {MSU_STATUS}    // Wait until MSU1 is ready
    bvs {-}
    ldx #$0000
    stx $2116       // Set VRAM Address low byte [word address!]

    lda #$04
    sta {charptr}
    sta $210b       // Set BG1/2 char address

    // prepare DMA
    ldx #{MSU_READ}     // Set source address
    stx $4302       // offset
    stz $4304       // bank

    lda #$01
    sta {firstframe}

    rts


main:
print "msu::main: {$}"
    sep #$20
    rep #$10
-;  bit {MSU_STATUS}
    bmi {-}
    stz {dispcnt}       // set field_count to 0
    lda {MSU_READ}
    sta {numframes}     // get #frames_1
    lda {MSU_READ}
    sta {numframes}+1   // get #frames_2
    lda {MSU_READ}
    sta {curdur}
    sta {stddur}        // get duration
    lda {MSU_READ}
    sta {altdur}        // get alternation duration [?]
    lda {MSU_READ}
    sta {altcnt}        // get alternation count [?]
    lda #$01
    sta {curcnt}    

    ldx {numframes}
    dex         // decrement #frames
        lda #$21                // V-Count IRQ + Auto Joypad Read
        sta $4200

loop:
    lda {dma::isr_flag} // Wait until IRQ sets DMA_ISR flag
    beq loop
    stz {dma::isr_flag} // Reset DMA_ISR flag
    lda {dispcnt}       // load field count
    cmp #$02        // if >= 2 don't draw anymore
    bpl {+}

    //load half picture
    lda #$18

    sta $4301       // Set port for DMA0 to 00:2118
    lda #$09        // Set DMA transfer parameters
                //    direction: cpu_mem -> ppu
                //    do not increment address
    sta $4300       //    transfer mode: 2 registers write once
    ldy #$3f80
    sty $4305       //    transfer size: 16,256bytes
    lda #$01
print "dma transfer star: {$}"
    sta $420b       //    Start DMA transfer!!!

+;  inc {dispcnt}       // inc field count
    lda {dispcnt}       // and compare with current duration

    cmp {curdur}        // if not reached...
    bne loop        // ...wait another field

    lda {firstframe}    // first frame ready for display?
    beq {+}

    lda #$01        // then start audio
    sta {MSU_CONTROL}
    lda #$FF
    sta {MSU_VOLUME}
    sta {current_volume}
    stz {firstframe}

+;  lda {curcnt}
    cmp {altcnt}    // compare with alternation frequency
    bne {+}     // if reached...
    stz {curcnt}    // ...reset current frame count
    lda {altdur}    // use alternate duration for next frame
    bra skipcountreset
+;  lda {stddur}    // else use normal duration
    inc {curcnt}    // and inc current frame count
skipcountreset:
    sta {curdur}    // store in current duration
    stz {dispcnt}   // reset field counter
    dex     // decrement framecount
    beq stop    // stop if end of movie
    lda {joypad::joy1raw}+1 // Read joy1 log
    cmp #$10
    beq fade

    //load palette
    stz $2121
    lda #$22
    sta $4301
    lda #$08
    sta $4300
    ldy #$0200
    sty $4305
    lda #$01
    sta $420b
    lda {charptr}
    bne ptr2


ptr1:
    lda #$04
    sta $210b
    sta {charptr}
    ldy #$0000
    sty $2116
    jmp loop


ptr2:
    stz $210b
    stz {charptr}
    ldy #$4000
    sty $2116
    jmp loop


stop:
    stz {MSU_CONTROL}
    rts

fade:
    jsr fadeout::main
    bra stop
