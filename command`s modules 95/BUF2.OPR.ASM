

*==========================*
* ОПЕРАТОР: BUF2 P1,P2..PN *
*==========================*

; буферизирует переданные параметры (младшие байты)
; служит для расширения количества параметров
; других команд


BUFER    DFB 0
         DW RESET
         DFB 0,16
         DFB 0,0
         ASC "BUF2 p1,p2...pN"
         DFB 0

         JSR CH.PARH
BUF2.OP  LDX #0
         LDY #0
BUF20    CPX XBUF1
         BEQ BUF21
         LDA BUF1,X
         STA BUF2,Y
         INX
         INY
         BNE BUF20
BUF21    STY XBUF2
         RTS

BUF2     DS  16   буфер параметров
XBUF2    DS  1    флаг количества параметров

