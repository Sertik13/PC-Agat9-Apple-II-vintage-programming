
*-----------------------------*
* оператор "ГОВОРЯЩАЯ СТРОКА" *
*-----------------------------*

SAY        DFB:00100000 
           DW EXIT
           DFB 1,3
           DFB:00000000,:00000001
           ASC "SAY A${,Speed,Mod}" 
           DFB 0

; параметры:
; ----------
;
; A$    - текстовое выражение в формате интерпретатора
; Speed - скорость проговаривания строки
; Mod   : 0 - вывод только на динамик и магнитофон
;         >0 - также и на экран и устройство
;      
                                              
; USED ZERO PAGE                              

ABEGL   EQU $06
ABEGH   EQU $07
AENDL   EQU $08
AENDH   EQU $09
CALC    EQU $1B
BYTEND  EQU $ED
ASRL    EQU $EE
ASRH    EQU $EF
SAYL    EQU $01
SAYH    EQU $02
SYSPEED EQU $00


; CONSTANTS

CSPEED  EQU 8
CMOD    EQU 0
SDATA   EQU $6B80

         
        LDA#0
        JSR RPARAM
        STA SAYH
        STY SAYL
        TXA
        BEQ SAYERR3    имя нулевое
        STA SAYSTRL    длина строки
SAY3    JSR CH.PARH
        LDX XBUF1
        CPX#3
        BCS SAY10      SPEED и MOD указаны
        LDA#CMOD       установить MOD=CMOD(0)
        STA BUF1+2
SAY10   CPX#2  
        BCC SAY11      
        LDA BUF1+1     SPEED указан, проверить значение
        CMP#CSPEED+1
        BCC SAY12
SAYERR3 JMP BASERR46  
                  
SAY11   LDA#CSPEED     SPEED не указан, установить
SAY12   STA SYSPEED    SPEED=CSPEED(8)
SAY4    LDY#0
        LDA (SAYL),Y
        EOR #$80
        LDX BUF1+2
        BEQ SAY9
        JSR COUT      вывести на экран и устройство
SAY9    PHA
        ORA#$80
        JSR SAYVRFY   
        BCS SAY5      уже отработан (без динамика)
        PLA
        AND #$7F
        SEC
        SBC #$60
        ASL A
        ASL A
        TAY
        LDX #0
SAY7    LDA SDATA,Y   начало данных адресов
        STA ABEGL,X
        INX
        INY
        CPX#4
        BMI SAY7    
        JSR SPEAK     вывести символ на динамик и мафон
        BEQ SAY8      JMP
SAY5    PLA      
SAY8    INC SAYL   
        BNE SAY6
        INC SAYH
SAY6    DEC SAYSTRL
        BNE SAY4
SAYEND  RTS
      
SAYSTRL DFB $00

SAYVRFY LDY#5             отсекает символы не русского
        CMP SVFYTBL,Y     алфавита 
        BEQ SAYINT 
        DEY
        BNE SAYVRFY+2
        CMP#$E0
        BCC SAYVRF2
        CLC
        RTS
        
SAYINT  LDA SYSPEED      интерпретация специальных знаков
        ASL A            ("," "." " " "!" ";" "?")
        ASL A
        ASL A
        TAX
SAYINT1 JSR WAIT
        TXA
        DEX
        BNE SAYINT1
SAYVRF2 SEC
        RTS
        
SVFYTBL DFB $A0,$A1,$AE,$AC,$BB,$BF


SPEAK   LDA #$08
        STA SPEAK7
        LDY #$00
        STY CALC
        LDA (ABEGL),Y
        CMP #$FF
        BNE SPEAK1
        INC ABEGL
        STY SPEAK7
SPEAK1  LDA (ABEGL),Y
        STA BYTEND
        INC ABEGL
        LDA ABEGH
        STA ASRH
        LDA ABEGL
        STA ASRL
SPEAK5  LDA ABEGL
        CMP AENDL
        BNE SPEAK3
        LDA ABEGH
        CMP AENDH
        BEQ SPEAK9
SPEAK3  LDA (ABEGL),Y

SPEAK7  EQU *+1

        BNE SPEAK8
SPEAK8  STA CALC
        AND #$F0
        LSR A
        LSR A
        LSR A
        LSR A
SPEAK13 TAY 
        BEQ SPEAK10
        STX $C030
        STX $C020
SPEAK10 LDX SYSPEED    взять скорость
SPEAK11 DEX 
        BNE SPEAK11
        DEY 
        BNE SPEAK10
        LDA CALC
        BEQ SPEAK12
        STY CALC
        AND #$0F
        BNE SPEAK13
SPEAK12 INC ABEGL
        BNE SPEAK5
        INC ABEGH
        BNE SPEAK5
SPEAK9  DEC BYTEND
        BEQ SPEAK4
        LDA ASRL
        STA ABEGL
        LDA ASRH
        STA ABEGH
        JMP SPEAK3
SPEAK4  RTS 
