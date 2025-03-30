
*------------------*
* функция "HEX$"(n)*
*------------------*

; преобразует аргумент n в диапазоне 0-65535
; в шестнадцатиричную текстовую строку


HEX      DFB:10010000
         DW  RAM
         DFB 1,1
         DFB 0,0
         ASC "HEX$ (n)"
         DFB 0

BUFHEX   EQU $06
HEXS     EQU $2A

         LDA BUF1         преобразовать аргумент
         JSR TREOR        из буфера
         STA BUFHEX+3     младший
         STY BUFHEX+2
         LDA BUF11        старший
         JSR TREOR
         STA BUFHEX+1
         STY BUFHEX
         LDX#4            убрать лидирующие нули
         LDY#0            ----------------------
HEXC     LDA BUFHEX,Y     X-счетчик цифр
         CMP#$30          это ноль?
         BNE HEXRET
         DEX              да, пропустить
         INY
         CPY#4
         BNE HEXC
         DEY
         INX              ноль тоже цифра!
HEXRET   TYA
         STA HEXS         вернуть параметр обработчику
         LDA#>BUFHEX      функций
         CLC
         ADC HEXS
         TAY
         LDA#<BUFHEX
         ADC#0
         RTS
         
TREOR    JSR TRHEX
         EOR#$80
         PHA
         TYA
         EOR#$80
         TAY
         PLA      
         RTS

TRHEX    PHA
         LSR A
         LSR A
         LSR A
         LSR A
         JSR TRBYTE
         TAY
         PLA
         AND#:00001111
TRBYTE   ORA#$B0
         CMP#$BA
         BCC TREND
         ADC#6
TREND    RTS
