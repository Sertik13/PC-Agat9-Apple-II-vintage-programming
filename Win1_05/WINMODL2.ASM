

*===========================*
*   МОДУЛЬ "WINMODL2.ASM"   *
*===========================*

; by Wolkow I. & Serkov S.
; должен располагаться в памяти до $8000
; для хранения окон использует банки E,F
; не разрешается пользоваться страницами текста
; и графики, лежащими в диапазоне $8000-$BFFF
; 12 команд

WN1    EQU $3C
WN2    EQU $3D
WN3    EQU $3E
WN4    EQU $3F
WN5    EQU $C9
WN6    EQU $CA
WN7    EQU $2E
WN8    EQU $2F
WN9    EQU $26
WN10   EQU $27
WN11   EQU $42
WN12   EQU $43

; используются и другие ячейки ZERO PAGE

*---------------------*
* оператор "RAM"      *
*---------------------*

; построить рамку

RAM    DFB 0
       DW  RAMS
       DFB 5,6
       DW 0
       ASC "RAM vt,ht,xl,yl,type {,col}"
       DFB 0
       
       JSR CH.PARH
       JSR PR10
       LDX#2
       JSR PRPN5
RAM1   LDY BUF1
       LDX BUF1+1
       JSR PR1
       JSR PR6
       LDA BUF1+2
       STA WN9
       LDA BUF1+3
       STA WN10
       LDA XBUF1
       CMP #$06
       BCC RAM2
       BIT COLOR
       BMI RAM2
       LDA BUF1+5
       JSR PR7
RAM2   LDA BUF1+4
       BEQ RAM5
       LDA #$10
       LDX #$1B
       LDY #$12
       JSR PR3
RAM3   LDA #$5C
       JSR PR4
       LDX WN9
RAM4   LDY PR2.0
       JSR PR5
       DEX 
       BNE RAM4
       LDA #$5C
       JSR PR4
       JSR PR3.1
       DEC WN10
       BNE RAM3
       LDA #$1D
       LDX #$1B
       LDY #$1F
       JSR PR3
       JMP PR2
RAM5   JSR RAM8
RAM6   LDA #$20
       JSR PR4
       LDX WN9
RAM7   LDY PR2.0
       JSR PR5
       DEX 
       BNE RAM7
       LDA #$20
       JSR PR4
       JSR PR3.1
       DEC WN10
       BNE RAM6
       JSR RAM8
       JMP PR2
RAM8   LDA #$20
       TAX 
       TAY 
       JMP PR3

*----------------------*
* оператор "RAMS"      *
*----------------------*

; построить фоновую рамку

RAMS   DFB 0
       DW  OWIN
       DFB 4,5
       DW 0
       ASC "RAMS vt,ht,xl,yl {,col}"
       DFB 0

       JSR CH.PARH
       JSR PR10
RAMS1  LDY BUF1
       LDX BUF1+1
       JSR PR1
       LDA XBUF1
       CMP #$05
       BCC RAMS2
       BIT COLOR
       BMI RAMS2
       LDA BUF1+4
       JSR PR7
RAMS2  JSR RAMS3
RAMS7  LDA WN10
       STA WN12
       JSR RAMS4
       JSR RAMS5
       INC WN9
       INC WN9
       INC WN10
       INC WN10
       DEC CH 
       BIT COLOR
       BMI RAMS6
       DEC CH
RAMS6  DEC CV
       JSR $FC5F
       DEC WN11
       BPL RAMS7
       JMP PR2
RAMS3  LDA #$00
       STA WN11
       LDX BUF1+2
       LDY BUF1+3
RAMS10 CPX #$03
       BCC RAMS8
       CPY #$03
       BCC RAMS8
       INC WN11
       DEX
       DEX
       INC CH
       BIT COLOR
       BMI RAMS9
       INC CH
RAMS9  DEY
       DEY
       INC CV
       BNE RAMS10
RAMS8  STX WN9
       STY WN10
       JMP $FC5F
RAMS4  JSR PR6
       LDA #$10
       LDX #$1B
       LDY #$12
       JSR PR3
RAMS11 LDA #$5C
       TAY 
       LDX #$20
       JSR PR3
       DEC WN12
       BNE RAMS11
       LDA #$1D
       LDX #$1B
       LDY #$1F
       JMP PR3  
RAMS5  LDY #$18
       LDX #$00
RAMS12 DEX       
       BNE RAMS12
       DEY 
       BNE RAMS12
       RTS 
 
*---------------------*
* оператор OWIN       *
*---------------------*

; открыть окно

OWIN   DFB 0
       DW  CWIN
       DFB 5,6
       DW 0
       ASC "OWIN vt,ht,xl,yl,type {,col}"
       DFB 0 

       JSR CH.PARH
       JSR PR10
       LDX#4
       JSR PRPN5
OWIN1  LDX KOLWIN
       CPX #$08
       BCC OWIN2

       LDX#200     ошибка "УЖЕ ЕСТЬ" (много открытых окон)
       JMP BASERR

OWIN2  CPX ACTWIN
       BEQ OWIN2.
       BCC OWIN2.
       JSR OWIN27
OWIN2. JSR OWIN3
       LDA XBUF1
       CMP #$06
       BCC OWIN4
       BIT COLOR
       BMI OWIN4
       LDA BUF1+5
       JSR PR7
OWIN4  LDA #$00
       STA UGW
       STA LGW
       LDA #$20
       STA DGW
       LDA #$40
       STA RGW
       JSR OWIN5
       JSR OWIN6
       JSR OWIN7
       JSR PR6
       LDA WN9
       STA BUF1+2
       LDA WN10
       STA WN12
       STA BUF1+3
       LDA BUF1+4
       STA OWIN9+1
       AND #$02
       BNE OWIN8
       JSR RAMS4
       JMP OWIN9
OWIN8  LDA XBUF1
       PHA
       LDA #$04
       STA XBUF1
       JSR RAMS1
       PLA
       STA XBUF1
       DEC WN9
       DEC WN9
       DEC WN10
       DEC WN10
OWIN9  LDA #$00
       AND #$01
       BNE OWIN10
       CLC
       RTS
OWIN10 LDY WN7
       INY
       STY UGW
       TYA
       CLC
       ADC WN10
       STA DGW
       LDY WN8
       INY
       BIT COLOR
       BMI OWIN11
       INY
OWIN11 STY LGW
       LDA WN9
       BIT COLOR
       BMI OWIN12
       ASL A
OWIN12 STA RGW
       LDA #$8C
       JMP COUT
OWIN3  LDX KOLWIN
OWIN28 LDA COLOR
       STA OWBUF7,X
       LDA LGW
       STA OWBUF1,X
       LDA RGW
       STA OWBUF2,X
       LDA UGW
       STA OWBUF3,X
       LDA DGW
       STA OWBUF4,X
       LDA CV
       STA OWBUF5,X
       LDA CH
       STA OWBUF6,X
       RTS
OWIN27 LDX KOLWIN
OWIN29 LDA OWBUF7,X
       STA COLOR
       LDA OWBUF1,X
       STA LGW
       LDA OWBUF2,X
       STA RGW
       LDA OWBUF3,X
       STA UGW
       LDA OWBUF4,X
       STA DGW
       LDA OWBUF5,X
       STA CV
       LDA OWBUF6,X
       STA CH
       JMP $FC5F

OWBUF1 DS 9
OWBUF2 DS 9
OWBUF3 DS 9
OWBUF4 DS 9
OWBUF5 DS 9
OWBUF6 DS 9
OWBUF7 DS 9

OWIN5  LDY BUF1+1
       DEY
       TYA
       BIT COLOR
       BMI OWIN13
       ASL A
OWIN13 STA CH
       LDY BUF1
       DEY
       STY CV
       JSR $FC5F
       JMP PR6
OWIN6  LDX KOLWIN
       LDA CV
       STA OWBUF2.1,X
       STA WN7
       LDA CH
       STA OWBUF2.2,X
       STA WN8
       LDY BUF1+2
       STY WN9
       INY
       INY
       TYA
       STA OWBUF2.3,X
       STA BUF1+2
       LDY BUF1+3
       STY WN10
       INY
       INY
       TYA
       STA OWBUF2.4,X
       STA BUF1+3
       RTS
OWIN26 LDX KOLWIN
       LDA OWBUF2.1,X
       STA CV
       LDA OWBUF2.2,X
       STA CH
       LDA OWBUF2.3,X
       STA BUF1+2
       LDA OWBUF2.4,X
       STA BUF1+3
       JSR $FC5F
       JMP PR6

OWBUF2.1    DS 8
OWBUF2.2    DS 8
OWBUF2.3    DS 8
OWBUF2.4    DS 8

OWIN7  JSR WINBNKO
       JSR OWIN15
OWIN18 LDX BUF1+2
OWIN17 JSR OWIN16
       DEX
       BNE OWIN17
       JSR PR3.1
       DEC BUF1+3
       BNE OWIN18
       INC KOLWIN
       LDA KOLWIN
       STA ACTWIN
       ASL A
       TAX 
       LDA WN3
       STA OWBUF3.1,X
       LDA WN4
       STA OWBUF3.2,X
       JMP WINBNKC
OWIN15 LDA KOLWIN
       ASL A
       TAX
       LDA OWBUF3.1,X
       STA WN3
       LDA OWBUF3.2,X
       STA WN4
       RTS
OWIN16 JSR OWIN19
       BIT COLOR
       BMI OWIN20
OWIN19 LDY PR2.0
       LDA (WN1),Y
       LDY #$00
       STA (WN3),Y
       INC PR2.0
       INC WN3
       BNE OWIN20
       INC WN4
OWIN20 RTS

OWBUF3.1 DS 1
OWBUF3.2 DFB $80
         DS 16

OWIN23 LDX BUF1+2
OWIN22 JSR OWIN21
       DEX
       BNE OWIN22
       JSR PR3.1
       DEC BUF1+3
       BNE OWIN23
       RTS
OWIN21 JSR OWIN24
       BIT COLOR
       BMI OWIN25
OWIN24 LDY #$00
       LDA (WN3),Y
       LDY PR2.0
       STA (WN1),Y
       INC PR2.0
       INC WN3
       BNE OWIN25
       INC WN4
OWIN25 RTS

KOLWIN DS 1

*--------------------*
* оператор CWIN      *
*--------------------*

; закрыть окно

CWIN    DFB 0
        DW  TOWIN 
        DFB 0,1
        DW 0
        ASC "CWIN {type}"
        DFB 0

        JSR CH.PARH
        LDX XBUF1
        BEQ CWIN1
        LDA BUF1
        CMP #3
        BCS CWINERR
CWIN1   LDX KOLWIN
        BNE CWIN2
        RTS 
CWIN2   LDX XBUF1
        BEQ CWIN3
        LDA BUF1
        BEQ CWIN3
        CMP #$02
        BNE CWIN4
        BEQ CWIN5
CWIN6   JSR CWIN3
CWIN5   LDX KOLWIN
        CPX #$02
        BCS CWIN6
        RTS
CWIN4   JSR CWIN3
        LDX KOLWIN
        BNE CWIN4
        RTS
CWIN3   JSR WINBNKO
        LDA #$00
        STA LGW
        STA UGW
        LDA #$20
        STA DGW
        LDA #$40
        STA RGW
        DEC KOLWIN
        LDA KOLWIN
        STA ACTWIN
        JSR OWIN15
        JSR OWIN26
        JSR OWIN23
        JSR WINBNKC
        JMP OWIN27
CWINERR JMP BASERR46


WINBNKO LDA $C140
        STA WINBNKC+1
        LDA $C150
        STA WINBNKC+4
        STA $C14E
        STA $C15F
        RTS

WINBNKC STA $C100
        STA $C100
        RTS


*------------------*
* оператор "TOWIN" *
*------------------*

; перейти в окно

TOWIN   DFB 0
        DW MAXWIN
        DFB 1,1
        DW 0
        ASC "TOWIN {nwin}"
        DFB 0

        LDX ACTWIN
        JSR OWIN28
        LDX BUF1
        CPX KOLWIN
        BCC TOWIN1
        BEQ TOWIN1
        JMP BASERR46
TOWIN1  STX ACTWIN
        JMP OWIN29

ACTWIN  DS 1

*-------------------*
*  функция "MAXWIN" *
*-------------------*

; возвращает число открытых окон

MAXWIN  DFB:10000000
        DW WUP
        DFB 0,0
        DW 0
        ASC "MAXWIN"
        DFB 0

        LDA#0
        LDY KOLWIN
        RTS

*------------------*
* функция "NUMWIN" *
*------------------*

; возвращает номер активного окна

NUMWIN  DFB:10000000
        DW WUP
        DFB 0,0
        DW 0
        ASC "NUMWIN"
        DFB 0

        LDA#0
        LDY ACTWIN
        RTS


*----------------*
* оператор "WUP" *
*----------------*

; скроллинг вверх

WUP    DFB 0
       DW WDN
       DFB 0,1
       DW 0
       ASC "WUP {n}"
       DFB 0

       JSR CH.PARH
       JSR WMVALL
       JSR WVRT
WUP1   JSR WUP2
       DEC BUF1
       BNE WUP1
       RTS

WUP2   LDX CV         WUP
       LDY DGW
       DEY
       STY CV
       LDA UGW
       PHA
       JSR VTAB
WUP3   LDA BASL
       STA $2A
       LDA BASL+1
       STA $2B
       LDY RGW
       DEY
       PLA
       ADC #$01
       CMP DGW
       BCS WUP5
       PHA
       JSR VTAB
WUP4   LDA (BASL),Y
       STA ($2A),Y
       DEY
       BPL WUP4
       BMI WUP3
WUP5   LDY #$00
       JSR $FCA7
       TXA
       STA CV
       JMP VTAB


*----------------*
* оператор "WDN" *
*----------------*

; скроллинг вниз 

WDN    DFB 0
       DW WRT
       DFB 0,1
       DW 0
       ASC "WDN {n}"
       DFB 0

       JSR CH.PARH
       JSR WMVALL
       JSR WVRT
WDN1   JSR WDN2
       DEC BUF1
       BNE WDN1
       RTS


WDN2   LDX CV         WDN
       LDA UGW
       STA CV
       LDY DGW
       DEY
       TYA
       PHA
WDN3   PLA
       PHA
       SEC
       SBC #$01
       JSR VTAB
       LDA BASL
       STA $2A
       LDA BASL+1
       STA $2B
       PLA
       PHA
       STA CV
       JSR VTAB
       PLA
       CMP UGW
       BEQ WDN5
       SEC
       SBC #$01
       PHA
       LDY RGW
       DEY
WDN4   LDA ($2A),Y
       STA (BASL),Y
       DEY
       BPL WDN4
       BMI WDN3
WDN5   JMP WUP5


*----------------*
* оператор "WRT" *
*----------------*

; скроллинг вправо

WRT    DFB 0
       DW WLF
       DFB 0,1
       DW 0
       ASC "WRT {n}"
       DFB 0

       JSR CH.PARH
       JSR WMVALL
       JSR WGOR
WRT1   JSR WRT2
       DEC BUF1
       BNE WRT1
       RTS


WRT2   LDA CV          WRT
       PHA
       LDA UGW
       STA CV
WRT3   JSR VTAB
       LDY RGW
       DEY
WRT4   BIT COLOR
       BMI WRT5
       DEY
WRT5   DEY
       BMI WRT7
       LDA (BASL),Y
       BIT COLOR
       BMI WRT6
       INY
WRT6   INY
       STA (BASL),Y
       DEY
       BPL WRT4
WRT7   LDY #$00
       LDA #$20
       STA (BASL),Y
       LDA COLOR
       BMI WRT8
       INY
       STA (BASL),Y
WRT8   INC CV
       LDA CV
       CMP DGW
       BCC WRT3
       JMP WLF10


*----------------*
* оператор "WLF" *
*----------------*

; скроллинг влево

WLF    DFB 0
       DW  WINDOW
       DFB 0,1
       DW 0
       ASC "WLF {n}"
       DFB 0

       JSR CH.PARH
       JSR WMVALL
       JSR WGOR
WLF1   JSR WLF2
       DEC BUF1
       BNE WLF1
       RTS

WLF2   LDA CV           WLF
       PHA
       LDA UGW
       STA CV
WLF3   JSR VTAB
       LDY #$00
WLF4   BIT COLOR
       BMI WLF5
       INY
WLF5   INY
       CPY RGW
       BCS WLF7
       LDA (BASL),Y
       BIT COLOR
       BMI WLF6
       DEY
WLF6   DEY
       STA (BASL),Y
       INY
       CPY RGW
       BCC WLF4
WLF7   LDY RGW
       BIT COLOR
       BMI WLF8
       DEY
WLF8   DEY
       LDA #$20
       STA (BASL),Y
       LDA COLOR
       BMI WLF9
       INY
       STA (BASL),Y
WLF9   INC CV
       LDA CV
       CMP DGW
       BCC WLF3
WLF10  PLA 
       STA CV
       JMP VTAB

WMVALL LDX XBUF1
       BNE WMVL1
       LDY #1
       STY BUF1
WMVL1  RTS

WVRT   LDA BUF1
       JSR PR12
WVRT1  BCC WVRT2
       BEQ WVRT2
       JMP BASERR46
WVRT2  RTS

WGOR   LDA BUF1
       JSR PR11
       JMP WVRT1

*-------------------*
* оператор "WINDOW" *
*-------------------*

; установить размеры окна

WINDOW DFB 0
       DW EXIT
       DFB 0,4
       DW 0
       ASC "WINDOW {Ht,Xl,Vt,Yl}"
       DFB 0

       JSR CH.PARH
WINDW1 LDA BUF1      Ht ($20)  LGW
       LDX XBUF1
       CPX #1
       BCS WINDW2
       LDA WHT
WINDW2 BIT COLOR
       BMI WDW2.
       ASL A
WDW2.  CMP #$40
       BCS WOWERR
       STA BUF1
       LDA BUF1+1    Xl ($21)  RGW
       CPX #2
       BCS WIND3.
       LDA WXL
       BNE WINDW3    JMP
WIND3. BIT COLOR
       BMI WINDW3
       ASL A
WINDW3 CMP #$41
       BCS WOWERR
       STA BUF1+1
       CLC
       ADC BUF1
       CMP #$41
       BCS WOWERR
       LDA BUF1+2    Vt ($22)  UGW
       CPX #3
       BCS WINDW4
       LDA WVT
WINDW4 CMP #$20
       BCS WOWERR
       STA BUF1+2
       LDA BUF1+3    Yl ($23)  DGW
       CPX #4
       BCS WINDW5
       LDA WYL
WINDW5 CMP #$21
       BCS WOWERR
       CLC
       ADC BUF1+2
       CMP #$21
       BCS WOWERR
       STA DGW
       LDA BUF1+1
       STA RGW
       LDA BUF1
       STA LGW
       LDA BUF1+2
       STA UGW
       STA CV
       JMP VTAB

WOWERR JMP BASERR46

WHT    DFB $00
WVT    DFB $00
WXL    DFB $40
WYL    DFB $20

*= ПОДПРОГРАММЫ ОБЩЕГО ЗНАЧЕНИЯ =*

PR1    LDA CV
       STA WN5
       LDA CH 
       STA WN6
       DEY
       STY CV
       DEX
       TXA
       BIT COLOR
       BMI PR1.0
       ASL A
PR1.0  STA CH
       JMP $FC5F

PR2    LDA WN5
       STA CV
       LDA WN6
       JMP PR1.0

PR2.0  DS  1

PR3    STX PR3.0+1
       STY PR3.3+1
       JSR PR4
       LDX WN9
PR3.0  LDA#$00
       JSR PR4
       DEX
       BNE PR3.0
PR3.3  LDA#$00
       JSR PR4
PR3.1  LDA#$00
       STA PR2.0
       LDA WN1
       CLC
       ADC#$40
       STA WN1
       BCC PR3.2
       INC WN2
PR3.2  RTS

PR4    LDY PR2.0
       STA (WN1),Y
       INY
       BIT COLOR
       BMI PR4.0
       LDA COLOR
       STA (WN1),Y
       INY
PR4.0  STY PR2.0
       RTS

PR5    INY
       BIT COLOR
       BMI PR5.0
       INY
PR5.0  STY PR2.0
       RTS

PR6    LDA BASL
       CLC
       ADC CH 
       STA WN1
       LDA BASH
       ADC #$00
       STA WN2
       LDY #0
       STY PR2.0
       RTS

PR7    AND#$1F
       CMP #$08
       BCS PR8
       ORA #$20
       STA COLOR
       RTS

PR8    CMP #$16
       BCS PR9
       AND #7
       STA COLOR
       RTS

PR9    AND #7
       ORA #8
       STA COLOR
       RTS

PR10   LDA BUF1+2
       BEQ PR10ER
       LDA BUF1+3
       BEQ PR10ER
       LDA BUF1+1
       BEQ PR10ER
       JSR PR11
       BCS PR10ER
       CLC
       ADC BUF1+2
       JSR PR11
       BCS PR10ER
       LDA BUF1
       BEQ PR10ER
       JSR PR12
       BCS PR10ER
       CLC
       ADC BUF1+3
       JSR PR12
       BCS PR10ER
       RTS
PR10ER JMP BASERR46
PR11   TAY
       BIT COLOR
       BMI PR11.1
PR11.2 CPY #32
       RTS
PR11.1 CPY #64
       RTS
PR12   TAY 
       JMP PR11.2

PRPN5  STX PRPX+1
       LDA BUF1+4
PRPX   CMP#0
       BCS PR10ER
       RTS

