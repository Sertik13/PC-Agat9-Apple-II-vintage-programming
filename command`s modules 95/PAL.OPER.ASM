
                       
*====================*
* ОПЕРАТОР: PAL {CL} *
*====================*

PALITRA  DFB 0
         DW  HEX   
         DFB 0,1
         DFB 0,0
         ASC "PAL {num}"
         DFB 0
         
; включает цветовую палитру в формате Т.О.-4
; с номерами 1,2,3,4
; команда без параметра включает следущую
; (текущая запоминается в CURPAL)

         JSR CH.PARH
         LDX XBUF1     Если не было ни одного параметра,
         BEQ NEXTPAL   то включить следующую палитру.
         LDX BUF1
         BEQ PALERR    0 запрещен как параметр
         CPX #5
         BCS PALERR    значение параметра от 1 до 4
         DEX      
         TXA
SETPAL   AND #3
         STA CURPAL    Записать в текущий номер палитры
         PHA
         AND #1
         TAY
         STA $C058,Y   Включить палитру
         PLA
         LSR A
         TAY
         STA $C05A,Y
         RTS

NEXTPAL  LDY CURPAL    Увеличить текущую палитру на 1
         INY
         TYA
         BNE SETPAL    JMP

CURPAL   DFB 0         Текущее значение палитры
PALERR   JMP BASERR46

