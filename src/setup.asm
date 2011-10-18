//bass
//arch=snes-cpu
mapper lorom

namespace init

define return_db $013F
define return_stack $0140
define return_nmi_addr $0142
define return_nmi_bank $0144
define return_irq_addr $0145
define return_irq_bank $0147

//TODO: How much of this do we actually need?
snes:
    sep #$20        // 8-bit accumulator
    rep #$10        // 16-bit index
    stz $4016       // enable joypad reading
    stz $4200
    lda #$ff
    sta $4201
    stz $4202
    stz $4203
    stz $4204
    stz $4205
    stz $4206
    stz $4207
    stz $4208
    stz $4209
    stz $420a
    stz $420b
    stz $420c
    stz $420d       // FAAAAAAST
    lda #$8f
    sta $2100       // INIDISP: force blank
    stz $2101
    stz $2102
    stz $2103
    stz $2105
    stz $2106
    stz $2107
    stz $2108
    stz $2109
    stz $210a
    stz $210b
    stz $210c
    stz $210d
    stz $210d
    stz $210e
    stz $210e
    stz $210f
    stz $210f
    stz $2110
    stz $2110
    stz $2111
    stz $2111
    stz $2112
    stz $2112
    stz $2113
    stz $2113
    stz $2114
    stz $2114
    lda #$80        // VRAM addr increment after high byte
    sta $2115
    stz $2116
    stz $2117
    stz $211a
    stz $211b
    lda #$01
    sta $211b
    stz $211c
    stz $211c
    stz $211d
    stz $211d
    stz $211e
    sta $211e
    stz $211f
    stz $211f
    stz $2120
    stz $2120
    stz $2121
    stz $2123
    stz $2124
    stz $2125
    stz $2126
    stz $2127
    stz $2128
    stz $2129
    stz $212a
    stz $212b
    stz $212c
    stz $212d
    stz $212e
    stz $212f
    stz $2130
    stz $2131
    lda #$e0        // clear fixed color
    sta $2132
    stz $2133
    rts


gfx:
    stz $4200
    stz $420b
    stz $420c
    jsr clear_vram
    jsr copy_low_tilemap
    jsr copy_high_tilemap
    jsr clear_oam_tables
    rts

clear_vram:
    sep #$20
    rep #$10
    ldx #$0000
    stx $2116   // VRAM Register lo
    {dma::upload #$09, #$0000, {data::zero_bank}, {data::zero_addr}, #$18}
    rts

copy_low_tilemap:
    sep #$20
    rep #$10
    ldx #$3F80  // VRAM Register lo == 8-bit address $7F00
    stx $2116
    {dma::upload #$01, #$0100, {data::tilemap_bank}, {data::tilemap_addr}, #$18}
    rts

copy_high_tilemap:
    sep #$20
    rep #$10
    ldx #$7F80  // VRAM Register lo == 8-bit address $FF00
    stx $2116
    {dma::upload #$01, #$0020, {data::tilemap2_bank}, {data::tilemap2_addr}, #$18}
    rts

clear_oam_tables:
    sep #$20
    rep #$10
    ldx #$0000
    stx $2102   // OAM Register lo
    {dma::upload #$08, #$0220, {data::zero_bank}, {data::zero_addr}, #$04}
    rts

colortest:
    sep #$20
    rep #$10
    stz $2130
    rts

handlers:
    sep #$20
    rep #$10
    lda #$5C    // JML
    sta $0200
    sta $0204
    lda #$0e    // nmi+irq bank
    sta $0203
    sta $0207
    ldx #$f1c0  // nmi addr
    stx $0201
    ldx #$f1cd  // irq addr
    stx $0205
    rts

screen:
    sep #$20        // 8-bit accumulator
    rep #$10        // 16-bit index
    lda #$13        // mode 3, 16x16
    sta $2105
    lda #$3C        // Tilemap addr 0x7800, 32x32
    sta $2107       // for BG1
    lda #$00        // chr base addr:
    sta $210b       // BG1=0x0000, BG2=0x0000
    lda #$01        // enable BG1
    sta $212c       // BG Main
    lda #$01        // enable none
    sta $212d       // BG Sub
    lda #$20        // Window 1 for color
    sta $2125       // Color window
    lda #$10        // cut off 16 pixels left
    sta $2126
    lda #$ef        // cut off 16 pixels right
    sta $2127
    lda #$40        // enable clipping outside window
    sta $2130
    stz $2121       // reset CGRAM ptr
    lda #$0f
    sta $2100       // screen on, full brightness
    rts

backup_registers:
    rep #$20    // 16bit acl
    sep #$10    // 8bit x/y

    tsc
    sta {return_stack}
    lda $0201
    sta {return_nmi_addr}
    lda $0205
    sta {return_irq_addr}
    sep #$20
    lda $0203
    sta {return_nmi_bank}
    lda $0207
    sta {return_irq_bank}
    phb
    pla
    sta {return_db}

    rts

restore_registers:
    rep #$10    // 8bit acl
    sep #$20    // 16bit x/y

    ldx {return_nmi_addr}
    stx $0201
    lda {return_nmi_bank}
    sta $0203
    ldx {return_irq_addr}
    stx $0205
    lda {return_irq_bank}
    sta $0207
    lda {return_db}
    pha
    plb
    ply     // we backup the jump-pointer, as it will get lost otherwise
    ldx {return_stack}
    txs
    plx     // we delete the old jump-pointer...
    phy     // and replace it with our own
    rts

hdma:
    sep #$20
    rep #$10
    stz $420b
    stz $420c

    lda #$00        // A to B; direct; 1x single reg
    sta $4310       // ch. 1 for blanking
    lda #$00        // 2100 = inidisp
    sta $4311
    lda {data::hdma_blank_bank}
    ldy {data::hdma_blank_addr}
    sty $4312
    sta $4314

    lda #$00        // A to B; direct; 1x single reg
    sta $4320       // ch. 2 for tilemap switch
    lda #$07        // 2107 = BG1 Tilemap Address
    sta $4321
    lda {data::hdma_tilemap_bank}
    ldy {data::hdma_tilemap_addr}
    sty $4322
    sta $4324

print "hdma scroll: {$}"
    lda #$03        // A to B; direct; 2x 2x single reg
    sta $4330       // ch. 3 for scroll
    lda #$0d        // 210d = BG1HOFS
    sta $4331
    lda {data::hdma_scroll_bank}
    ldy {data::hdma_scroll_addr}
    sty $4332
    sta $4334

    ldx #$00b9      // Set IRQ trigger to line 185
    stx $4209
    lda #$0e
    sta $420c
    rts
