//bass
//arch=snes-cpu
mapper lorom

namespace handlers
nmi:
    pha
    sep #$20
    lda $4210   // ack interrput
    lda #$0e
    sta $420c   // enable HDMA ch1-3
    pla
    rti

irq:
//FIXME: Somehow this handler screws up the stack and returns to the wrong place
    pha
    phx
    phy
    php
    sep #$20
    lda #$01
    sta {dma::isr_flag}
    jsr joypad::main
    lda $4211   // ack irq
    plp
    ply
    plx
    pla
    rti
