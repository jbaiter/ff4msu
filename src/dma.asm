//bass
//arch=snes-cpu
mapper lorom

namespace dma

define isr_flag $1012

macro upload mode, len, a_bank, a_addr, b_reg
    lda {mode}
    sta $4300
    lda {b_reg}
    sta $4301
    ldx {a_addr}
    lda {a_bank}
    stx $4302
    sta $4304
    ldx {len}
    stx $4305
    lda #$01
    sta $420b
endmacro

killdma:
    stz $420b
    stz $420c
    stz $4310
    stz $4311
    stz $4312
    stz $4313
    stz $4314
    stz $4320
    stz $4321
    stz $4322
    stz $4323
    stz $4324
    stz $4330
    stz $4331
    stz $4332
    stz $4333
    stz $4334
    stz $4340
    stz $4341
    stz $4342
    stz $4343
    stz $4344
    stz $4350
    stz $4351
    stz $4352
    stz $4353
    stz $4354
    stz $4360
    stz $4361
    stz $4362
    stz $4363
    stz $4364
    rts
