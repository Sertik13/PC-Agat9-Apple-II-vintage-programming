

*===========================*
* ОПЕРАТОР: TABL P1,P2...PN *
*===========================*

; Строит таблицу, используя в качестве количества
; и размеров столбцов параметры оператора "BUF2"
; Собственные параметры задают количество и размеры
; строк таблицы


CUR.V    EQU $E0 ; Для сохранения текущей позиции VTAB
CUR.H    EQU $E1 ; Для сохранения текущей позиции HTAB
CUR.C    EQU $E2 ; Для сохранения текущего цвета


TABL     DFB 0
         DW BUFER
         DFB 0,16
         DFB 0,0
         ASC "TABL p1,p2...pN"
         DFB 0

         JSR CH.PARH
TABL.OP  JSR SETADR
         LDA MEM
         AND #:11000000
         STA MEM
         LDX #0
         STX $01
         JSR UPSTRING
TABO0    LDX $01
         LDA BUF1,X
         TAX
TABO1    TXA 
         PHA
         JSR WYWERT
         PLA
         TAX
         DEX
         BNE TABO1
         INC $01
         LDA $01
         CMP XBUF1
         BEQ ENDTB
         JSR MDSTRING
         JMP TABO0

ENDTB    JMP DNSTRING

*=====================*
* ВЫВЕСТИ ЛЮБУЮ ЛИНИЮ *
*=====================*

SUPERLIN STA SSP
         STX SSM
         STY SSR
         LDY #0
         STY $02
         JSR SETHH
         STA THT
         LDA SSL
         JSR WYWPG
SUPL0    INC $02
         LDY $02
         CPY XBUF2
         BEQ SUPL4
SUPL1    LDY $02
         LDA BUF2,Y
         JSR SETHH
         CMP THT
         BEQ SUPL3
         BCC SUPL3
         LDA SSP
         JSR WYWPG
         JMP SUPL1

SUPL3    LDA SSM
         JSR WYWPG
         JMP SUPL0

SUPL4    DEC THT
         BIT COLOR
         BMI SUPL5
         DEC THT
SUPL5    LDA SSR
         JSR WYWPG
         JMP PLUS40

SETHH    LDA BUF2,Y
         TAY
         DEY
         TYA
         BIT COLOR
         BMI SETH1
         ASL A
SETH1    RTS

*==========================*
* ПОСТРОИТЬ ВЕРХНЮЮ СТРОКУ *
*==========================*

UPSTRING LDA #$10
         STA SSL
         LDA #$1B
         LDX #$11
         LDY #$12
         BNE SUPERLIN

*================================*
* ПОСТРОИТЬ СРЕДНИЕ ВЕРТИКАЛЬНЫЕ *
*================================*

WYWERT   LDA #$5C
         STA SSL
         TAX
         TAY
         LDA #$20
         BNE SUPERLIN

*=========================*
* ПОСТРОИТЬ СРЕДНИЕ ЛИНИИ *
*=========================*

MDSTRING LDA #$13
         STA SSL
         LDY #$1C
         LDA #$1B
         LDX #$14
         JMP SUPERLIN

*========================*
* ПОСТРОИТЬ НИЖНЮЮ ЛИНИЮ *
*========================*

DNSTRING LDA #$1D
         STA SSL
         LDY #$1F
         LDA #$1B
         LDX #$1E
         JMP SUPERLIN

SSL      DS  1
SSR      DS  1
SSM      DS  1
SSP      DS  1


*========================*
* СИСТЕМНЫЕ ПОДПРОГРАММЫ *
*========================*
;
; Вх.: X-Htab
;      Y-Vtab
;
SAVEPOS  LDA CV 
         STA CUR.V
         LDA CH 
         STA CUR.H
         DEY
         STY CV 
         DEX
         TXA
         BIT COLOR
         BMI SVPS1
         ASL A
SVPS1    STA CH 
         JMP $FC5F

LOADPOS  LDA CUR.V
         STA CV 
         LDA CUR.H
         JMP SVPS1

*------ СЛУЖЕБНЫЕ ЯЧЕЙКИ ------*

THT      DS 1  ; ТЕКУЩАЯ ПОЗИЦИЯ


*============================*
* ПЕРЕХОД НА СЛЕДУЮЩ. СТРОКУ *
*============================*

PLUS40   LDA #0
         STA THT
         LDA MEM
         CLC
         ADC #$40
         STA MEM
         BCC PL4
         INC MEM+1
PL4      RTS

*=========================*
* ЗАПИСАТЬ СИМВОЛ В ЭКРАН *
*=========================*

WYWPG    LDY THT
         STA (MEM),Y
         INY
         BIT COLOR
         BMI WYWPG1
         LDA COLOR
         STA (MEM),Y
         INY
WYWPG1   STY THT
         RTS

PLUSPG   INY
         BIT COLOR
         BMI PLPG1
         INY
PLPG1    STY THT
         RTS

*===============================*
* УСТАНОВИТЬ В МЕМ АДРЕС ЭКРАНА *
*===============================*

SETADR   LDA BASL
         CLC
         ADC CH 
         STA MEM
         LDA BASH 
         ADC #0
         STA MEM+1
         LDY #0
         STY THT
         RTS

*=========================*
* УСТАНОВИТЬ ЦВЕТ: A=ЦВЕТ *
*=========================*
; 00-07 Нормальный
; 08-15 Инверсный
; 16-23 Мерцающий

SETCOL   AND #:00011111
         CMP #8
         BCS SETC1
         ORA #$20
         STA COLOR
         RTS
SETC1    CMP #$16
         BCS SETC2
         AND #7
         STA COLOR
         RTS
SETC2    AND #7
         ORA #8
         STA COLOR
         RTS

