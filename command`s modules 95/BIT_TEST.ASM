
*---------------------*
* FUNCTION "BIT_TEST" *
*---------------------*

BIT_TEST   DFB $80
           DW  DEFNSLOT
           DFB 2,2
           DFB 0,0
           ASC "BIT_TEST (hadr,nbit)"
           DFB 0
           
BIT_1      LDA BUF11+1     проверить старший байт
           BNE BIT_ERR1    параметра "номер бита" (0-7)
           LDX BUF1+1
           CPX#8           если больше, то "ОШ.ЗНАЧЕНИЕ"
           BCS BIT_ERR1
           LDY BUF1
           LDA BUF11       hadr -> в MEM
           STY MEM
           STA MEM+1
           LDA#1
           LDX BUF1+1      номер бита проверки 0 ?
           BEQ BIT_4       да, сдвигать не надо
BIT_2      ASL A           нет!, сдвинуть до маски
           DEX
           BNE BIT_2
BIT_4      STA RNDL        маска в RNDL
           LDY#0
           LDA (MEM),Y     взять байт проверки
           AND RNDL        AND с маской 
           BEQ BIT_3
           LDY#1           в бите nbit содержится 1
           DFB $2C
BIT_3      LDY#0           нет, там 0
           LDA#0
           RTS

BIT_ERR1   JMP BASERR46    
