
          LST ON

*========================================*
*Module for work with "Nippel Clock Card"*
* by Serkov S.V. version 04/11/95        *
* 2 функции,   требует драйвера N.C.C.   *
*========================================*

          LST OFF

CLPARM1   EQU $06
CLPARM2   EQU $07
CLPARM3   EQU $08

*---------------------------*
* смешанная команда "TIME$" *
*---------------------------*

; читает/устанавливает время в ячейку часов
; Если работает как функция, то возвращает строку 8 сим-
; волов формата чч:мм:сс. При этом если контроллер не
; не обнаружен, то возвращает пустую строку.
; Если используется как процедура и при этом контроллер
; не найден то выдает ошибку "НЕТ УСТРОЙСТВА"

TIME     DFB:00010010
         DW  DATE
         DFB 0,3
         DFB 0,0
         ASC "TIME$ {(hh,mm,ss)}
         DFB 0

         JSR CH.PARH
         JSR SEEKCARD
         LDX XBUF1     есть параметры?
         BNE T.SET0    да 
         BIT VEKTFLAG
         BPL T.ERR35   процедура, а параметров нет
         BMI TIMEFUNC  функция без параметров
T.SET0   BIT VEKTFLAG
         BPL T.SET01   процедура, обработать ее
         JSR T.SET01   функция с параметрами обрабатыва-
         JMP TIMEFUNC  ется сначала как процедура, а 
T.SET01  CPX#3         потом как функция.
         BCC T.ERR35
         LDX #0
         LDA BUF1,X
         CMP #24
         BCS T.ERR46
         STA CLPARM1
         INX
T.SET1   LDA BUF1,X
         CMP #60
         BCS T.ERR46
         STA CLPARM1,X
         INX
         CPX #3
         BNE T.SET1
         INX             X=4
         JSR DCLOCK
T.SET2   LDX#0
         RTS

TIMEFUNC JSR DCLOCK      X=0 зафикс. часы
         LDX#$01         запросить время
         JSR DCLOCK
         LDY#0
         LDA CLPARM1
         JSR SETBTD
         JSR T.POINT
         LDA CLPARM2
         JSR SETBTD
         JSR T.POINT
         LDA CLPARM3
         JSR SETBTD
         LDX#8
T.STRING LDY#>BFTDSTR
         LDA#<BFTDSTR
         RTS

SETBTD   JSR DECOS       преобразовать часы
         STA BFTDSTR,Y
         INY
         TXA
         STA BFTDSTR,Y
         INY
         RTS

T.POINT  LDA#':
         DFB $2C
T.SLESH  LDA#'/
         EOR#$80
         STA BFTDSTR,Y
         INY
         RTS
                
T.ERR35  JMP BASERR35
T.ERR46  JMP BASERR46

SEEKCARD LDX#$FF
         JSR DCLOCK
         LDA CSLOT
         BEQ NOTCARD
         RTS

NOTCARD  BIT VEKTFLAG
         BPL NOTCARD1   для процедуры - всегда ошибка
         LDX XBUF1
         BNE NOTCARD1   функция с параметрами - тоже
         PLA                   
         PLA            иначе,(функция без параметров):
         JMP T.SET2     вернуть строку нулевой длинны
NOTCARD1 LDX#$10        оператор, выдать ошибку
         LDA#<TIMEERR   (код 16 -"НЕТ УСТРОЙСТВА"
         LDY#>TIMEERR
         JSR DCERR
         JMP DCEXIT

TIMEERR  DCI"НЕТ УСТРОЙСТВА"


*---------------------------*
* смешанная команда "DATE$" *
*---------------------------*

DATE     DFB:00010010
         DW  EXIT
         DFB 0,4
         DFB 0,0
         ASC "DATE$ {(n,m,y,d)}
         DFB 0


; читает/устанавливает дату в ячейку часов
; Если работает как функция, то возвращает строку 11 сим-
; волов формата чс/мс/гд/дн. При этом если контроллер
; не обнаружен, то возвращает пустую строку.
; Если используется как процедура и при этом контроллер
; не найден то выдает ошибку "НЕТ УСТРОЙСТВА"

 
         JSR CH.PARH
         JSR SEEKCARD
         LDX XBUF1     есть параметры?
         BNE D.SET0    да 
         BIT VEKTFLAG
         BPL T.ERR35   процедура, а параметров нет
         BMI DATEFUNC  функция без параметров
D.SET0   BIT VEKTFLAG
         BPL D.SET01   процедура, обработать ее
         JSR D.SET01   функция с параметрами обрабатыва-
         JMP TIMEFUNC  ется сначала как процедура, а 
D.SET01  CPX#4
         BCC T.ERR35
         LDX #3
         LDA BUF1,X
         CMP #8 
D.SET1   BCS T.ERR46
         DEX
         LDA BUF1,X
         CMP #100
D.SET2   BCS D.SET1 
         STA CLPARM3
         DEX
         LDA BUF1,X
         CMP #13
         BCS D.SET2 
         STA CLPARM2
         DEX
         LDA BUF1,X
         CMP #32
         BCS D.SET2
         STA CLPARM1
         LDX #5
         JSR DCLOCK
         LDX #3
         LDA BUF1,X
         STA CLPARM1
         LDX #6
         JSR DCLOCK
         LDX#0
         RTS

DATEFUNC LDX#0           зафиксир. знач. 
         JSR DCLOCK
         LDX #0
         JSR DCLOCK
         LDX #2
         JSR DCLOCK
         LDY#0
         LDA CLPARM1
         JSR SETBTD      вывести число
         JSR T.SLESH
         LDA CLPARM2
         JSR SETBTD      вывести месяц 
         JSR T.SLESH
         LDA CLPARM3
         JSR SETBTD
         JSR T.SLESH
         TYA
         PHA
         LDX#3
         JSR DCLOCK
         PLA
         TAY
         LDA CLPARM1
         JSR SETBTD
         LDX#11
         JMP T.STRING

BFTDSTR  DS 11

DECOS    JSR DECOZ
         LDX#1
DECOS1   LDA DNUMBER,X
         AND#$0F
         ORA#$B0
         CMP#$BA
         BCC DECOS2
         ADC#6
DECOS2   EOR#$80
         PHA
         DEX
         BPL DECOS1
         PLA
         TAX
         PLA
         RTS 
         
