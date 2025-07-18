
*===============================*
*                               *
*    МОДУЛЬ ПРОГРАММИРОВАНИЯ    *
*   ФУНКЦИОНАЛЬНОЙ КЛАВИАТУРЫ   *
* ----------------------------- *
*  by Serkov S.V. version 1.03  *
*        - 04.11.95. -          *
*===============================*
                                

*----------------*
* оператор "KEY" *
*----------------* 

KEY      DFB 0
         DW KEY_ON
         DFB 2,2  
         DFB:00000000,:00000010
         ASC "KEY n,X$"
         DFB $00
         
         LDA#1
         JSR RPARAM
         STA $5F
         STY $5E
         TXA
         CMP #KOLVSIM
         BCS KEYER130   больше чем кол-во символов
         PHA
         JSR CH.PARH
         LDY BUF1
         BEQ KEYER46
         CPY #KOLVKEY+1
         BCS KEYER46
         JSR KEYZ           Y=0
KEY3     PLA
         PHA
         TAX
         BEQ KEY6
KEY5     LDA ($5E),Y
         EOR #$80
         JSR KBNKON
         JSR KEYA
         STA (BKEYL),Y
         JSR KBNKOFF
         INY
         DEX
         BNE KEY5
KEY6     JSR KBNKON
         PLA
         LDY#KOLVSIM-1
         STA (BKEYL),Y      записать длину
KEY7     LDA #CONTROLKEY
         STA KEYFLAG
         JMP KBNKOFF

KEYER46  LDX#46
         DFB $2C
KEYER130 LDX#130
         JMP BASERR
         
KEYZ     LDA #<BUFKEY
         STA BKEYH
         LDA #>BUFKEY
         STA BKEYL
KEYZ1    DEY
         BEQ KEYZ2
         CLC
         LDA #KOLVSIM
         ADC BKEYL   
         STA BKEYL
         LDA #0
         ADC BKEYH    
         STA BKEYH
         JMP KEYZ1
KEYZ2    RTS

*=======================*     
*    ЗАПРОС СИМВОЛА     *
*=======================*
  
TAKESIM  LDY CH          для стрелки вправо
         LDA (BASL),Y
         STA $2A
         LDY SIMFLAG
         BEQ TAKESIM4    отдать из буфера ПФК
TAKESIM1 JSR $FD14       не мой, взять от KEYIN
         STA KFUNCOD
         LDY #KOLVKEY-1
TAKESIM2 CMP TKEYS,Y     сверить с таблицей
         BEQ TAKESIM3
         DEY
         BPL TAKESIM2
         BNE TAKESIM5    нет в таблице
TAKESIM3 INY             настроиться на адрес клавиши
         JSR KEYZ
         JSR KBNKON
         LDY#KOLVSIM-1
         STY KEYNUM
         LDA (BKEYL),Y   взять длину этой "клавиши"
         STA KEYTXT      
         JSR KBNKOFF
         LDA KEYTXT
         BEQ TAKESIM8    "пустая" клавиша, отдать ее код
         LDA BKEYH
         LDY BKEYL
         STA TAKESIM7+2  установить первый символ
         STY TAKESIM7+1
TAKESIM4 LDY #0          выдать символ из буфера
         JSR KBNKON      
         JSR KEYA
TAKESIM7 LDA $1000,Y  
         PHA             код символа передается в A
         JSR KBNKOFF
         PLA
         DEC KEYNUM      контроль максимального кол-ва
         BMI TAKESIM6
         DEC KEYTXT      контроль по "длине" клавиши
         BMI TAKESIM6    отдал уже все
         INC TAKESIM7+1  настроиться на следующий символ
         BNE TAKESIM5
         INC TAKESIM7+2  Y=0
TAKESIM5 STY SIMFLAG     
         RTS
TAKESIM6 LDY #$FF        следующий символ не из буфера
         STY SIMFLAG 
         BNE TAKESIM1    (JMP)
TAKESIM8 LDA KFUNCOD
         LDY #$FF
         BNE TAKESIM5    (JMP)
         

SIMFLAG  DFB $FF     флаг символа
KEYTXT   DS  1       счетчик символов клавиши
KEYNUM   DS  1       счетчик максимального кол-ва символов
KFUNCOD  DS  1       хранит скен-код нажатой клавиши


TKEYS    DFB $90    f1          1
         DFB $91    f2          2
         DFB $92    f3          3
         DFB $93    f4          4
         DFB $94    f5          5
         DFB $9C    f6          6
         DFB $9D    f7          7
         DFB $9E    f8          8
         DFB $9F    f9          9
         DFB $81    f0(10)      10
         DFB $84    F1          11
         DFB $85    F2          12
         DFB $86    F3          13
         DFB $82    f.          14
         DFB $83    f=          15
         

*-------------------*
* оператор "KEY_ON" *
*-------------------*

KEY_ON   DFB 0
         DW KEY_OFF
         DFB 0,0
         DFB 0,0
         ASC "KEY_ON"
         DFB 0
         
         JSR CHECKNAB
         BEQ KEY_ON2
         JSR DIALOG
         BCS KEY_ON1
         LDA COLOR
         STA KEYL6+1
         JMP KEYL10
KEY_ON1  JMP BASERR35
KEY_ON2  LDA #$FF
         STA SIMFLAG    выключить вывод из буфера
         LDA #<KEYON
         LDY #>KEYON

KEYALL   STA BKEYH
         STY BKEYL
         LDA#<KEYIN
         LDX#>KEYIN
         STA BKEY1H
         STX BKEY1L
         LDY#2
         STA $C083 
KEYALL1  LDA (BKEYL),Y
         STA (BKEY1L),Y
         DEY
         BPL KEYALL1
         RTS         
         

*--------------------*
* оператор "KEY_OFF" *
*--------------------*

KEY_OFF  DFB 0
         DW KEY_LIST
         DFB 0,0
         DFB 0,0
         ASC "KEY_OFF"
         DFB 0
         
KEY_OFF1 LDA#<KEYOFF
         LDY#>KEYOFF
         JMP KEYALL


CALLKEY  EQU TAKESIM    

KEYON    DFB $4C 
         DW CALLKEY

KEYOFF   DFB $20
         DW $F85E

KBNKON   STA KEYA+1 
         STX KEYX+1
         STY KEYY+1
         LDA $C170
         STA KEYB+1
         STA $C17A
         STA $C083
         RTS

KBNKOFF  STA $C083
KEYB     STA $C100
KEYA     LDA #$00
KEYY     LDY #$00
KEYX     LDX #$00
         RTS

*---------------------*
* оператор "KEY_LIST" *
*---------------------*

KEY_LIST DFB 0
         DW EXIT
         DFB 0,0
         DFB 0,0
         ASC "KEY_LIST"
         DFB 0
         
         LDA COLOR
         STA KEYL6+1
         JSR CHECKNAB
         BNE KEYL10
KEYL0    LDX#1           X - счетчик клавиш
         LDY#1           Y - счетчик символов
         JSR KEYZ        настроиться на начало КН
         BEQ KEYL2       Y=0 - JMP
KEYL1    LDY#2           перейти к следующей клавише
         JSR KEYZ1
KEYL2    TXA             сохранить ее номер
         PHA
         JSR KBNKON
         LDY#KOLVSIM-1
         LDA (BKEYL),Y   взять длину выражения в клавише
         STA KEYTXT
         JSR KBNKOFF
         JSR KEYCOL3     установить желтый цвет вывода  
         JSR KEYCROUT
         PLA             номеров клавиш
         PHA
         JSR DECOZ       пересчитать номер в десятичный
         JSR KEYCLREOL
         LDA DNUMBER+1   вывести номер
         JSR KEYPRHEX
KEYL4    LDA DNUMBER
         JSR KEYPRHEX
         LDA #$A0        пробел
         JSR COUT1
         LDA KEYTXT              
         BEQ KEYL9       "пустая клавиша"
         LDY#0           
         TYA
KEYL5    PHA
         DEC KEYTXT      контроль по длине
         BMI KEYL3
         JSR KBNKON
         JSR KEYA
         LDA (BKEYL),Y
         PHA
         JSR KBNKOFF
         PLA
         JSR KEYCOL
         BNE KEYL7
         LDA #$5F        вместо кода NUL (0)
KEYL7    JSR COUT2
         PLA
         TAY
         INY
         TYA
         CMP#KOLVSIM-1
         BNE KEYL5
         PHA
KEYL3    PLA
KEYL9    PLA
         TAX
         INX
         CPX#KOLVKEY+1
         BNE KEYL1
KEYL6    LDA#$00            храниться цвет
         STA COLOR
         JSR KEYCROUT
         JMP KEYCROUT
         
KEYL10   JSR KEYCROUT
         JSR KEYCLREOL
         JSR KEYCOL5
         LDX#0
KEYL11   LDA KEYSOO,X
         BEQ KEYL6 
         JSR KEYCOUT1
         INX
         BNE KEYL11  
         
KEYSOO   ASC "НАБОР ОТСУТСТВУЕТ"
         DFB $00
         
CHECKNAB JSR KBNKON
         LDA KEYFLAG
         PHA
         JSR KBNKOFF
         PLA
         CMP#CONTROLKEY
         RTS         

KEYCOL   STA KEYCOL6+1
         CMP #$20      не выводятся COUT
         BCC KEYCOL4
         CMP #$80      управляющие
         BCC KEYCOL2
         CMP #$A0      обычные
         BCS KEYCOL2
KEYCOL1  LDA #$46      инверсный голубой для управляющих
         DFB $2C
KEYCOL2  LDA #$22      зеленый для обычных
         DFB $2C
KEYCOL3  LDA #$23      желтый для номеров клавиш
         DFB $2C      
KEYCOL4  LDA #$21      красный для кодов 0<$20
         DFB $2C
KEYCOL5  LDA #$27      для сообщения
         BIT COLOR     
         BMI KEYCOL6
         STA COLOR
KEYCOL6  LDA #$00      восстановить A
         RTS
            
KEYPRHEX  AND#$0F
          ORA#$B0
          CMP#$BA
          BCC KEYCOUT1
          ADC#$06
          DFB $2C
KEYCROUT  LDA#$8D
          DFB $2C
KEYCLREOL LDA#$9D
KEYCOUT1  JMP COUT1
 

*---------------------------*
* оператор "EXIT" (for KEY) *
*---------------------------*

EXIT     DFB 0
         DFB 0,0   
         DFB 0,0
         DFB 0,0
         ASC "KEYEXIT"
         DFB 0
        
         JSR KEY_OFF1 отключить клавиатуру 
                                             
; оператор "EXIT" стандартный
; для драйверов под систему
; BASIC 'MASTER'95 23.10.95

                              
;Если драйвер работает с Диспетчером, то выход через него

         DO ATRIBDR&:00100000 

         LDA#<AREA            
         LDY#>AREA            
         JMP INEXIT

         FIN
;Драйвер не работает с Диспетчером- 
;организовать выход самостоятельно

         DO ATRIBDR&:00000100  

         LDA #$FF              если в драйвере есть
         LDY #$58              процедуры, то занести
         STA VEKTPROC+2        в вектор процедур
         STY VEKTPROC+1        JMP на MONRTS
         
         FIN
         
         DO ATRIBDR&:00000010
         
         LDA #$E1              если в драйвере есть
         LDY #$AC              функции, то занести
         STA VEKTFUN+2         в вектор функций
         STY VEKTFUN+1         JMP на "ОШИБОЧНОЕ ЗНАЧЕНИЕ"
         
         FIN

         RTS

