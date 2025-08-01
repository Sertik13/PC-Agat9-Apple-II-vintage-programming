
*-------------------*
* функция  "PREADY" *
*-------------------*

; проверяет готов ли принтер на разъеме S к печати
; возвращает: "-1" если нет контроллера
;             "0"  принтер не готов (нет сигнала READY)
;             "1"  все в порядке

PREADY  DFB:10000000
        DW  PRHGR
        DFB 1,1
        DFB 0
        ASC "PREADY (S)" 
        DFB 0

PRED    JSR CH.PARH
        LDX BUF1
        CPX #2
        BCC PRSER46
        CPX #7
        BCS PRSER46
        TXA 
        ORA#$C0
        STA $02
        LDA#$C
        STA $01
        LDY#0
PRED1   LDA ($01),Y
        CMP #PAPERID
        BEQ PRED2
        LDA #$FF
        TAY
        RTS
PRED2   TXA
        ASL A
        ASL A
        ASL A
        ASL A
        TAX
        LDA #$80
        STA $C081,X
        LDA #7
        JSR WAIT
        LDA #$C0
        STA $C081,X
        LDA #20
PRED3   LDY $C082,X
        BPL PRED4
        SEC
        SBC #1
        BNE PRED3
        LDA #0
        TAY
        BEQ PRED6
PRED4   STX PAPERX
        LDA#0
        LDY#1
PRED6   RTS

PAPER2  LDA#<PERR2
        LDY#>PERR2
        JMP PAPERR

PAPER1  LDA#<PERR1
        LDY#>PERR1
PAPERR  LDX#8
        JSR DCERR
        JMP DCEXIT

PERR1   DCI "НЕТ УСТРОЙСТВА"
PERR2   DCI "ПРИНТЕР ВЫКЛЮЧЕН"

PRSER46 JMP BASERR46

*---------------------------------*
*        оператор "PRHGR"         *
*---------------------------------*
        
PRPAGE  EQU $2E0      1-ый с $2000
PRX1    EQU $2E1      0<=X1<$FF
PRY1    EQU $2E3      0<=Y1<$FF
PRX2    EQU $2E4      X1<X2<=$FF
PRY2    EQU $2E6      Y1<Y2<=$FF
PRPIXLX EQU $2E7
PRPIXLY EQU $2E8
PRLEFT  EQU $2E9
PRCOD   EQU $2EA      0 OR $80


PRHGR   DFB:00100000
        DW  0
        DFB 2,10
        DFB 0
        ASC "PRHGR S,nSCR {,X1,Y1,X2,Y2,XP,YP,XL,COD}"
        DFB 0

PRHGR1  JSR PRED
        CMP#$FF
        BEQ PAPER1
        CPY#0
        BEQ PAPER2
PRHGR1. LDA BUF1+1            PRPAGE
        BEQ PRSER46
        STA PRPAGE
        LDX XBUF1             PRX1
        CPX #3
        BCS PRHGR2
        LDA PRSTX1
        STA BUF1+2
PRHGR2  LDA BUF1+2
        CMP #$FF
PRHGR3. BCS PRSER46
        STA PRX1
        LDX XBUF1             PRY1
        CPX #4
        BCS PRHGR3
        LDA PRSTY1
        STA BUF1+3
PRHGR3  LDA BUF1+3
        CMP #$FF
PRHGR4. BCS PRHGR3.
        STA PRY1
        LDX XBUF1             PRX2
        CPX #5
        BCS PRHGR4
        LDA PRSTX2
        STA BUF1+4
PRHGR4  LDA PRX1  
        CMP BUF1+4
        BCS PRHGR4.
        LDA BUF1+4
        STA PRX2
        LDX XBUF1             PRY2
        CPX #6
        BCS PRHGR5
        LDA PRSTY2
        STA BUF1+5
PRHGR5  LDA PRY1
        CMP BUF1+5
        BCS PRHGR4.
        LDA BUF1+5
        STA PRY2
        LDX XBUF1             PRPIXLX
        CPX #7
        BCS PRHGR6
        LDA PRSTPX
        STA BUF1+6
PRHGR6  LDA BUF1+6
        STA PRPIXLX
        LDX XBUF1             PRPIXLY
        CPX #8
        BCS PRHGR7
        LDA PRSTPY
        STA BUF1+7
PRHGR7  LDA BUF1+7
        STA PRPIXLY
        LDX XBUF1             PRLEFT
        CPX #9
        BCS PRHGR8
        LDA PRSTLF
        STA BUF1+8
PRHGR8  LDA BUF1+8
        STA PRLEFT
        LDX XBUF1             PRCOD
        CPX #10
        BCS PRHGR9
        LDA PRSTCD
        STA BUF1+9
PRHGR9  LDA BUF1+9
        STA PRCOD
        LDA PAPERX
        LSR A
        LSR A
        LSR A
        LSR A
        ORA #$C0
        LDY #$90
        STA $4F
        STY $4E
        JMP ($004E)

PAPERX  DS 1    S*$10 PRINTER SLOT
PRSTX1  DFB 0
PRSTY1  DFB 0
PRSTX2  DFB $FF
PRSTY2  DFB $FF
PRSTPX  DFB 1
PRSTPY  DFB 1
PRSTLF  DFB 3
PRSTCD  DFB 0
