//bass
mapper lorom

// Entry poins for videos
org $008003         // Before title screen
    jml main::title_entry

org $019b06         // New game from title screen
    jml main::intro_entry

org $019911         // New game from save screen
    jml main::intro_entry

org $00c592
    jml main::outro_entry

incsrc "data.asm"

org $0ef100
incsrc "dma.asm"
incsrc "joypad.asm"
incsrc "handlers.asm"
incsrc "setup.asm"
incsrc "msu.asm"
incsrc "helpers.asm"
incsrc "fadeout.asm"

namespace main

define return_point $103e   // $00: title; $01: intro; $02: finale
define current_track $1040

title_entry:
    rep #$20
    lda #$0000
    sta {msu::vid_seek_bank}
    lda #$0000
    sta {msu::vid_seek_addr}
    lda #$0000
    sta {msu::audio_track}
    jsr init::backup_registers
    sep #$20
    lda #$00
    sta {return_point}
    jml main

intro_entry:
    rep #$20
    lda #$0a8e
    sta {msu::vid_seek_bank}
    lda #$f405
    sta {msu::vid_seek_addr}
    lda #$0001
    sta {msu::audio_track}
    jsr init::backup_registers
    sep #$20
    lda #$01
    sta {return_point}
    jml main

outro_entry:
    rep #$20
    lda #$0d36
    sta {msu::vid_seek_bank}
    lda #$380a
    sta {msu::vid_seek_addr}
    lda #$0002
    sta {msu::audio_track}
    jsr init::backup_registers
    sep #$20
    lda #$02
    sta {return_point}
    jml main

main:
    rep #$20
    lda #$027f  // our routines are at $0200, so we move the stack
    tcs
    sep #$20
    lda #$00    // Set direct bank to 00
    pha
    plb
    jsr msu::check
    lda {msu::msu_present}
    cmp #$00
    beq end
    stz $4200   // inhibit IRQs
    jsr init::handlers
    jsr dma::killdma
    // TODO: Why wait 10 frames?
    jsr helpers::waitblank
    jsr helpers::waitblank
    jsr helpers::waitblank
    jsr helpers::waitblank
    jsr helpers::waitblank
    // TODO: Skip this if we're not at the title video
    jsr init::snes
    lda #$01
    sta $420d   // fast cpu
    jsr init::gfx
    jsr init::colortest
    jsr init::hdma
    jsr init::screen

    // If we're playing the intro or outro, we need to tell the
    // sound engine to play the 'empty' song, else the gamesound
    // and videosound will overlap
    lda {return_point}
    cmp #$00
    beq {+}
    jsr ost_check
    lda #$05
    sta $1e01
    lda #$01
    sta $1e00
    jsl $048004

+;  sep #$20
    jsr msu::init
    cli 
    jsr msu::main
    sei
    jsr cleanup
    jmp end


cleanup:
    jsr init::clear_oam_tables
    jsr init::clear_vram
    jsr dma::killdma
    rts

end:
    jsr init::restore_registers
    rep #$10
    sep #$20
    lda {return_point}
    cmp #$00
    beq title_return
    cmp #$01
    beq intro_return
    cmp #$02
    beq finale_return
title_return:
    jml $008007
intro_return:
    jml $019b17
finale_return:
    jsl $13fffd
    jml $00c596

ost_check:
    print "ost_check {$}"
    rep #$10
    lda #$34
    sta $1e01
    sta {current_track}
    lda #$01
    sta $1e00
    jsl $048004
    ldx #$0000
    print "ost_check_2 {$}"
-;  jsr helpers::waitblank
    lda #%11100000
    sta $2122
    lda #%00000000
    sta $2122
    inx
    cpx #$04b0
    bne {-}
    print "fuckkkkrrrrr {$}"
    lda {current_track}
    inc
    sta $1e01
    sta {current_track}
    lda #$01
    sta $1e00
    jsl $048004
    ldx #$0000
    bra {-}
