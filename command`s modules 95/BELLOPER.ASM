

*===============================*
* ОПЕРАТОР: BELL                *
* (Нагло выдрано из PRINT SHOP) *
*===============================*

BELL     DFB 0
         DW  SOUND
         DFB 0,0
         DFB 0,0
         ASC "BELL"
         DFB 0

         LDY #4
BELS1    TYA 
         PHA
         LDA BELNOTE,Y
         STA BELS2+1
         LDA BELLONG,Y
BELS2    LDX #0
BELS3    INY
         BNE BELS4
         SBC #1
         BMI BELS5
BELS4    DEX
         BNE BELS3
         STA $C030
         BEQ BELS2
BELS5    PLA
         TAY
         DEY
         BPL BELS1
         RTS

BELNOTE  DFB $5E,$4C,$80,$72,$80
BELLONG  DFB $60,$30,$30,$18,$18 
