


*=================*
* ОПЕРАТОР: TURBO *
*=================*

TURBO    DFB 0
         DW  PREADY
         DFB 1,1
         DFB 0,0
         ASC "TURBO n"
         DFB 0

         JSR CH.PARH
         LDA BUF1
TURBOPTR LDX #3
         AND #$F
         BNE TURB2
TURB1    LDA NORMV,X
         STA $36,X
         DEX
         BPL TURB1
         RTS

TURB2    LDA TURBV,X
         STA $36,X
         DEX
         BPL TURB2
         RTS

NORMV    DFB $88,$04,$85,$04
TURBV    DFB $E4,$FD,$11,$FD
