//bass
//arch=snes-cpu
mapper lorom

namespace data

org $0efe3c
    incbin "../bin/spc_data.bin"

org $0efe9e
define zero_bank #$0e
define zero_addr #$fe9e
zero:
    dw $0000

// hdma_blank: write to $2100 once (mode 0)
// force blanking up to line 40 and from line 184
// (active display = 144 lines
define hdma_blank_bank #$0e
define hdma_blank_addr #$fea0
org $0efea0
hdma_blank:
    db $28      // repeat 40lines
    db $8f      // force blank on, max bright
    db $7f      // repeat 127 lines
    db $0f      // don't force blank, max bright
    db $11      // repeat 17 lines
    db $0f      // don't force blank, max bright
    db $01      // repeat 1 line
    db $8f      // force blank on, max bright
    db $00      // done

// h/vscroll: write to $210d twice, write to $210e twice (mode 3)
// adjust hscroll and vscroll to split one tilemap row into two display rows
// in conjunction with 16x16 tiles this reduces the effective tilemap size
// to 288dbes
define hdma_scroll_bank #$0e
define hdma_scroll_addr #$fea9
org $0efea9
hdma_scroll:
    db $38      // Repeat 56 times
    db $00, $00
    db $97, $01
    db $10      // Repeat 16 times
    db $00, $01
    db $87, $01
    db $10      // Repeat 16 times
    db $00, $00
    db $87, $01
    db $10      // Repeat 16 times
    db $00, $01
    db $77, $01
    db $10      // Repeat 16 times
    db $00, $00 
    db $77, $01
    db $10      // Repeat 16 times
    db $00, $01
    db $67, $01
    db $10
    db $00, $00
    db $67, $01
    db $10      // Repeat 16 times
    db $00, $01
    db $57, $01
// last row -> new tilemap
    db $10      // Repeat 16 times
    db $00, $00
    db $17, $01
    db $00      // done

// tilemap address switch: write to $2107 once (mode 0)
// last row of tilemap is located elsewhere due to size
define hdma_tilemap_bank #$0e
define hdma_tilemap_addr #$fed7
org $0efed7
hdma_tilemap:
    db $28      // Repeat for 40 lines
    db $bc      // 32x32 tilemap at 2F in VRam [???]
    db $7f      // Repeat for 127 lines
    db $bc      // 32x32 tilemap at 2F in VRam [???]
    db $01      // Repeat for 1 line
    db $bc      // 32x32 tilemap at 2F in VRam [???]
    db $01      // Repeat for 1 line
    db $fc      // 32x32 tilemap at 3F in VRam [???]
    db $00      // done
    
org $0efee0
define tilemap_bank #$0e
define tilemap_addr #$fee0
tilemap:
    dw $0000, $0000, $0002, $0004, $0006, $0008, $000a, $000c
    dw $000e, $0020, $0022, $0024, $0026, $0028, $002a, $0000

    dw $0000, $002c, $002e, $0040, $0042, $0044, $0046, $0048
    dw $004a, $004c, $004e, $0060, $0062, $0064, $0066, $0000

    dw $0000, $0068, $006a, $006c, $006e, $0080, $0082, $0084
    dw $0086, $0088, $008a, $008c, $008e, $00a0, $00a2, $0000

    dw $0000, $00a4, $00a6, $00a8, $00aa, $00ac, $00ae, $00c0
    dw $00c2, $00c4, $00c6, $00c8, $00ca, $00cc, $00ce, $0000

    dw $0000, $00e0, $00e2, $00e4, $00e6, $00e8, $00ea, $00ec
    dw $00ee, $0100, $0102, $0104, $0106, $0108, $010a, $0000

    dw $0000, $010c, $010e, $0120, $0122, $0124, $0126, $0128
    dw $012a, $012c, $012e, $0140, $0142, $0144, $0146, $0000

    dw $0000, $0148, $014a, $014c, $014e, $0160, $0162, $0164
    dw $0166, $0168, $016a, $016c, $016e, $0180, $0182, $0000

    dw $0000, $0184, $0186, $0188, $018a, $018c, $018e, $01a0
    dw $01a2, $01a4, $01a6, $01a8, $01aa, $01ac, $01ae, $0000

org $0effe0
define tilemap2_bank #$0e
define tilemap2_addr #$ffe0
tilemap2:
    dw $0000, $01c0, $01c2, $01c4, $01c6, $01c8, $01ca, $01cc
    dw $01ce, $01e0, $01e2, $01e4, $01e6, $01e8, $01ea, $0000



