
*-------------------*
* процедура "SOUND" *
*-------------------*

; Воспроизводит звук с частотой f и длительностью t
; (по Мымрину)


SOUND    DFB 0
         DW  PLAY
         DFB 2,2
         DFB 0,0
         ASC "SOUND f,t"
         DFB 0


         JSR CH.PARH
SOUNDS   LDY#0
SOUND0   LDX BUF1
         LDA $C030
SOUND1   DEY
         BNE SOUND2
         DEC BUF1+1
         BEQ SOUND3
SOUND2   DEX
         BNE SOUND1
         BEQ SOUND0
SOUND3   RTS

