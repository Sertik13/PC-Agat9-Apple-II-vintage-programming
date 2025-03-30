
*-------------------*
* функция "DEFSLOT" *
*-------------------*

; определяет устройство, установленное в разъем S

; возвращает:  $10 - MEMORY CARD
;              $4B - PRINTER CARD
;              $BD - TEAC CARD
;              $F0 - SHUGART CARD
;              $EA - NET CARD
;              $00 - free slot 

DEFNSLOT  DFB:10000000
          DW TIME
          DFB 1,1
          DFB 0,0
          ASC "DEFSLOT (S)"
          DFB 0

          JSR CH.PARH
          LDA BUF1
          BEQ DERR
          CMP#1
          BEQ DERR
          CMP#7
          BCS DERR
          ORA#$C0
          STA RNDH
          LDA#$0C
          STA RNDL
          LDY#0
          LDA (RNDL),Y
          CMP RNDH
          BEQ DEFN1      нет устройства Y=0
          TAY
          AND#$F0
          BEQ RAM170     ячейка памяти
DEFN1     LDA#0
          RTS
RAM170    LDY#$10
          BNE DEFN1
          

DERR      JMP BASERR46
