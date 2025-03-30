

*----------------------------------*
* Инициализация драйвера 'SPEAKER' *
*----------------------------------*

INITSAY    JSR DIALOG      только в диалоге
           BCS INITSAY1
           LDA#<TXTSAY1    сказать "Приятной работы!"
           LDY#>TXTSAY1
           LDX#18         
           STX SAYSTRL
           STA $02              
           STY $01 
           LDA#1
           STA BUF1+2
           LDA#6
           STA $00
           JSR SAY4
INITSAY1   RTS
