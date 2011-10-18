//bass
//arch=snes-cpu
mapper lorom

namespace helpers
waitblank:
-;  lda $4212
    and #$80
    bne {-}
-;  lda $4212
    and #$80
    beq {-}
    rts
