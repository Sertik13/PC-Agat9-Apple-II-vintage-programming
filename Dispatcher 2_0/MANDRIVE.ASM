
***********************************
* ------------------------------- *
* ДИСПЕТЧЕР РЕЗИДЕНТНЫХ ДРАЙВЕРОВ *
* ------------------------------- *
* Friends' software 1995 v 2.00   *
* by Serkov S.V. 07.09.95         *
* for Basic-Master'95             *
***********************************

ADRL      EQU $06
ADRH      EQU $07
SLUL      EQU $08
SLUH      EQU $09
SLU1      EQU $4F

SYSERR    EQU $1844
VEKTPROC  EQU $3F5
VEKTFUN   EQU $3E8
KOLDRIV   EQU 10        максимальное кол-во драйверов 

          DSECT

          ORG $1900     

QUANTYDR  DS 1          кол-во драйверов в системе 
DRINUM    DS 1          номер активного драйвера
MANTABL   DFB $58,$FF   первые 2-байта - RTSPZU
          DS KOLDRIV*2  для векторов драйверов
          DS 2          два ограничительных нуля
               
          DEND 
               
          ORG $F700
          OBJ $8000


*-------------------------*
* ТОЧКИ ВХОДА В ДИСПЕТЧЕР *
*-------------------------*

DISP      EQU *

INSET     JMP SET
INEXIT    JMP EXIT
INWORK    JMP WORK


*----------------------------------------------------*
* ВХОД "SET":A,Y - адрес обработчика команд драйвера *
*----------------------------------------------------*

SET       LDX QUANTYDR
          CPX #KOLDRIV
          BCS INSET1     нет места в таблице  
          JSR SEEK
          BCS INSET2     адрес уже есть в таблице
          LDA ADRL
          STA (SLUL),Y
          INY
          LDA ADRH
          STA (SLUL),Y
          LDA#0
          INY
          STA (SLUL),Y
          INY
          STA (SLUL),Y
          INC QUANTYDR
          INX
          BNE INWORK2  (JMP) установить драйвер активным
          
INSET1    LDX #69         C=1,X=69  ошибка "мало памяти"
          DFB $2C
INSET2    LDX #200        C=1,X=200 ошибка: "уже есть"
          RTS 


*-----------------------------------------------------*
* ВХОД "EXIT":A,Y - адрес обработчика команд драйвера *
*-----------------------------------------------------*

EXIT      LDX QUANTYDR
          JSR SEEK
          BCC INEXIT6      адрес вектора не найден
          DEX
          JSR INWORK2      установить предыдущий драйвер
INEXIT0   DEY
INEXIT1   INY
          LDA (SLUL),Y
          TAX
          BEQ EXCHECK
          INY
          LDA (SLUL),Y
INEXIT2   DEY
          DEY
          STA (SLUL),Y
          DEY
          TXA
          STA (SLUL),Y
          INY
          INY
          INC SLUL
          JMP INEXIT1

EXCHECK   INY
          LDA (SLUL),Y
          BNE INEXIT2
INEXIT4   DEY   
          DEY
          STA (SLUL),Y
          DEY
          STA (SLUL),Y
          DEC QUANTYDR
INEXIT5   CLC              успешное завершение выхода 
          DFB @44
INEXIT6   SEC              адрес обработчика не найден
          RTS              (передано ошибочное значение)


*----------------------------*
* ВХОД "WORK" X=NUMBER DRIVE *
*----------------------------*
                    
WORK      TXA
          BNE INWORK1
          
; Очистка таблицы "Диспетчера" по DR=0
 
INITMAN   LDY#KOLDRIV*2+2-1
INITMAN1  STA MANTABL+2,Y    A=0
          DEY
          BPL INITMAN1
          STA QUANTYDR

INWORK1   CPX QUANTYDR
          BCS INWORK3
INWORK2   TXA
          STA DRINUM
          ASL A
          TAX
          LDA MANTABL,X      ML
          STA VEKTPROC+1  
          STA ADRL
          LDA MANTABL+1,X    ST
          STA VEKTPROC+2
          STA ADRH
FUNCTION  CPX#0
          BEQ FUNCTION1
          LDA#3
          CLC
          ADC ADRL
          TAX
          LDA#0
          ADC ADRH
FUNCTION2 STA VEKTFUN+2
          STX VEKTFUN+1
          CLC
          RTS
FUNCTION1 LDX#$AC
          LDA#$E1
          BNE FUNCTION2

INWORK3   BEQ INWORK2
          LDX#46
          JMP SYSERR


*-------------- SEEK ADRESSES IN TABL --------------*

; вход:  A,Y - адрес обработчика команд драйвера
; 
; выход: SLUH*256+SLUL+Y - адрес свободной 2х байтной обл.
;        X=номер драйвера 
;        ADRL,ADRH - адрес обработчика команд драйвера
;        C=1 если адрес найден

SEEK      LDX QUANTYDR
          STA ADRH
          STY ADRL
          LDA#<MANTABL
          LDY#>MANTABL
          STA SLUH
          STY SLUL
          LDY#0
SEEK1     LDA (SLUL),Y
          CMP ADRL
          BNE SEEK2 
          INY
          LDA (SLUL),Y
          CMP ADRH
          BNE SEEK3
          BEQ SEEK4 
SEEK2     INY
SEEK3     INY
          DEX
          BPL SEEK1
          CLC
          DFB $2C
SEEK4     INY
          SEC
          PHP
          TYA
          SEC
          SBC#2
          LSR A
          TAX
          PLP
          RTS
          
          DS $F700+$100-*

