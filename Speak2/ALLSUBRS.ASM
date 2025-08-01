
            LST ON

*=====================================*
* Модуль ALLSUBRS.ASM                 *
* только для Системы BASIC 'MASTER'95 *
* версия 23.10.95                     *
*=====================================*

         LST OFF

*-----------------------------------*
* Проверка состояния интерпретатора *
*-----------------------------------*

DIALOG   LDX ALIN+1
         INX
         BEQ DIALOG1
         LDX PROMPT
         CPX #'}
         BEQ DIALOG1
         SEC            Выполняется программа USERa
         RTS
DIALOG1  CLC            Бейсик в диалоге
         RTS


*-----------------------------------------*
* Проверить, что все параметры меньше 256 *
*-----------------------------------------*

CH.PARH  LDX XBUF1
         BEQ CH.PARH3   нет параметров в буфере
         DEX
CH.PARH1 STX RNDH
         JSR PARBIT     параметр строковый?
         BCS CH.PARH4   да, не проверять т.к.
         LDX RNDH       в BUF1 - старший байт адреса!
         LDA BUF11,X
         BNE CH.PARH2
CH.PARH4 LDX RNDH
         DEX
         BPL CH.PARH1
CH.PARH3 RTS
CH.PARH2 JMP BASERR46   старший байт числа не 0 - ошибка!


*--------------------------------------*
* Подпрограмма проверки типа параметра *
*--------------------------------------*

; проверяет по карте команды тип параметра с 
; номером X (0-15)
; Выход: C=1 - строковый
;        C=0 - числовой

PARBIT   LDA#<TKART2
         LDY#>TKART2
         JMP PARSUM1


*-----------------------------------------*
* Подпрограмма проверки наличия параметра *
*-----------------------------------------*

; Вход:  X-номер параметра (0-15)
; Выход: C=0 - нет параметра в буфере
;        C=1 - параметр есть

PARSUM   LDA#<BKART2
         LDY#>BKART2
PARSUM1  STA MEM+1
         STY MEM
         INX
         SEC
         LDA#0
         LDY#2
PARS1    DEY
PARS2    ROL A
         BCS PARS1
         DEX
         BNE PARS2
         STA RNDL
         LDA (MEM),Y
         AND RNDL
         BNE PARS3
         CLC
         DFB @44
PARS3    SEC
         RTS


*---------------------------------------*
* Чтение параметра из буфера параметров *
*---------------------------------------*

;Вход :A-номер параметра (0-15)
;Выход:C=0 - параметр не считан (его нет)
;      C=1 - параметр есть
; 1.Для строк:
;      X-длина строки
;      A,Y - адрес строки в памяти (ST/ML)
; 2.Для чисел:
;      A,Y - число (ST/ML)

RPARAM   PHA
         TAX
         JSR PARSUM
         BCC RPARAM1  нет параметра в буфере
         PLA
         TAY
         LDA LBUF,Y
         TAX
         LDA BUF11,Y
         PHA
         LDA BUF1,Y
         TAY
         PLA
         SEC         есть параметр
         DFB $2C
RPARAM1  PLA
         CLC
         RTS



*---------------------------------*
* ДЕСЯТИЧНОЕ ПРЕОБРАЗОВАНИЕ БАЙТА *
*---------------------------------*

; вход: A-байт
; выход: DNUMBER - три десятичных цифры

DECOZ    LDX#$FF
         STX DNUMBER+2
         STX DNUMBER+1
         LDX#2
DECOZ1   INC DNUMBER,X
         SEC
         SBC DECI,X
         BCS DECOZ1
         ADC DECI,X
         DEX
         BNE DECOZ1
         STA DNUMBER
         RTS

DNUMBER  DS 3
DECI     DFB 0,10,100


