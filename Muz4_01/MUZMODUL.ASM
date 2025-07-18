


 LST ON

*========================================*
* MELODIES EXECUTER OF JUKEBOX' MODULE   *
* version 3.1 (universal interpretation) *
* by Serkov S.V. 28.10.93                *
*========================================*

   LST OFF

*--------------------------*
* смешанная команда "PLAY" *
*--------------------------*

Z6        EQU $06
Z7        EQU $07
Z8        EQU $08
Z9        EQU $09
ZD        EQU $1D
ZE        EQU $1E
ZF        EQU $1F

PLAY      DFB:00000010
          DW  LOCATMEL
          DFB 1,1
          DFB 0,0
          ASC "PLAY {(}hadr{)}"
          DFB 0

          LDX#$00
          LDA BUF11,X
          STA ZF
          LDA BUF1,X
          STA ZE
          LDA#01
          STA Z9
          STA ZD
          PHA
          PHA
          PHA
          BNE MUZ3
MUZ2      INY
          LDA (ZE),Y
          STA Z9
          INY
          LDA (ZE),Y
          STA ZD
MUZ23     LDA ZE
          CLC
          ADC#3
          STA ZE
          BCC MUZ3
          INC ZF
MUZ3      LDY#0
          LDA (ZE),Y
          CMP#1
          BEQ MUZ2
          BCS MUZ1
          PLA
          PLA
          PLA         окончание воспроизведения
MUZ26     LDY ZE      вернуть адрес следующей ноты
          LDA ZE+1
          LDX $C000   LONG=X=KLAVCOD ($1931)
          BMI MUZ4
MUZ5      LDX#$49
          INY
          LDA (ZE),Y
          BNE MUZ4
          LDX#$C9
MUZ4      STA$C010
          RTS
MUZ1      STA Z8
          JSR MUZ5
          STX MUZ6
          STA Z6
          LDX Z9
MUZ7      LSR A
          DEX
          BNE MUZ7
          STA MUZ8+1
          JSR MUZ5
          STX MUZ9
          STA Z7
          LDX ZD
MUZ10     LSR A
          DEX
          BNE MUZ10
          STA MUZ11+1
          PLA
          TAY
          PLA
          TAX
          PLA
          BNE MUZ12
          BIT$C030
MUZ12     CMP#0
          BMI MUZ13
          NOP
          BPL MUZ14
MUZ13     BIT$C030
MUZ14     STA$4E
          BIT$C000
          BMI MUZ26
          DEY
          BNE MUZ8
          BEQ MUZ15
MUZ8      CPY#0
          BEQ MUZ6
          BNE MUZ16
MUZ15     LDY Z6
MUZ6      EOR#$40
MUZ16     BIT$4E
          BVC MUZ17
          BVS MUZ18
MUZ18     BPL MUZ19
          NOP
          BMI MUZ20
MUZ17     NOP
          BMI MUZ19
          NOP
          BPL MUZ20
MUZ19     CMP$C030
MUZ20     DEC$4F
          BNE MUZ21
          DEC Z8
          BNE MUZ21
          BVC MUZ22
          BIT$C030
MUZ22     PHA
          TXA
          PHA
          TYA
          PHA
          JMP MUZ23
MUZ21     DEX
          BNE MUZ11
          BEQ MUZ24
MUZ11     CPX#0
          BEQ MUZ9
          BNE MUZ25
MUZ24     LDX Z7
MUZ9      EOR#$80
MUZ25     BVS MUZ12-3
          NOP
          BVC MUZ12

*-----------------------*
*  оператор "LOCATMEL"  *
*-----------------------*

LOCATMEL  DFB 0
          DW  TEMPUP
          DFB 1,1
          DFB 0,0
          ASC "LOCATMEL hadr"
          DFB 0

          LDX#$00
          LDA BUF1,X
          STA BUFMELL
          LDA BUF11,X
          STA BUFMELH
          RTS

*----------------------------*
*  оператор  "TEMPUP"        *
*----------------------------*

TEMPUP    DFB 0
          DW TEMPDW
          DFB 1,1
          DFB 0,0
          ASC "TEMPUP X"
          DFB 0

          LDA#$01
          STA MELCOM
          JMP TEMPDN1

*----------------------------*
*  оператор  "TEMPDW"        *
*----------------------------*

TEMPDW    DFB 0
          DW  TONEUP
          DFB 1,1
          DFB 0,0
          ASC "TEMPDW X"
          DFB 0


          LDA #$02
          STA MELCOM
TEMPDN1   JSR CH.PARH
          JSR MELPOZ
          LDX #$00
          LDA BUF1,X
          CMP#1
          BEQ TEMP1
          CMP#2
          BEQ TEMP1
          JMP MUZERR

TEMP1     STA MEL1
          LDA MELCOM
          CMP#1
          BEQ TEMP3
          JMP TEMP4
TEMP3     LDA MEL1
          CMP#1
          BEQ TEMP9
          BNE TEMP11
TEMP4     LDA MEL1
          CMP#1
          BEQ TEMP5
          BNE TEMP7
TEMP5     JSR TEMP17
          LDA ($4E),Y
          LSR A
          CLC
          ADC ($4E),Y
          BEQ TEMP6
          STA ($4E),Y
TEMP6     JSR TEMP19
          JMP TEMP5
TEMP7     JSR TEMP17
          LDA ($4E),Y
          ASL A
          BEQ TEMP8
          STA ($4E),Y
TEMP8     JSR TEMP19
          JMP TEMP7
TEMP9     JSR TEMP17
          LDA ($4E),Y
          CMP#5
          BCC TEMP10
          ASL A
          JSR TEMP13
TEMP10    STA ($4E),Y
          JSR TEMP19
          JMP TEMP9
TEMP11    JSR TEMP17
          LDA ($4E),Y
          CMP#5
          BCC TEMP12
          LSR A
TEMP12    STA ($4E),Y
          JSR TEMP19
          JMP TEMP11
TEMP13    STA MEL3
          LDX#8
          CMP#3
          BCC TEMP16
          LDA#0
TEMP14    ROL MEL3
          ROL A
          CMP#3
          BCC TEMP15
          SBC#3
TEMP15    DEX
          BNE TEMP14
          ROL MEL3
          TAX
          LDA MEL3
          BNE TEMP16
          TXA
TEMP16    RTS
MELPOZ    LDA BUFMELL
          STA$4E
          LDA BUFMELH
          STA$4F
          RTS
TEMP17    LDY#0
TEMP18    LDA ($4E),Y
          BEQ TEMP21
          CMP#1
          BNE TEMP22
          JSR TEMP19
          JMP TEMP18
TEMP19    CLC
          LDA$4E
          ADC#3
          STA$4E
          BCC TEMP20
          INC$4F
TEMP20    RTS
TEMP21    JSR TONE2
          PLA
          PLA
TEMP22    RTS

*------------------------*
*  оператор "TONEUP"     *
*------------------------*

TONEUP    DFB 0
          DW  TONEDW
          DFB 2,2
          DFB 0,0
          ASC "TONEUP number,X"
          DFB 0
          
          LDA #$01
TONE1     JSR TONE4 
          JSR CH.PARH
          LDX#$00
          LDA BUF1,X
          CMP#$03
          BCS TONE7
          JSR TONE5
          JSR TONE6
TONE2     LDX#0
          TXA
TONE3     STA MELCOM,X
          INX
          CPX #5
          BNE TONE3
          RTS

*------------------------*
*  оператор "TONEDW"     *
*------------------------*

TONEDW    DFB 0
          DW  EXIT
          DFB 2,2
          DFB 0,0
          ASC "TONEDW number,X"
          DFB 0

          LDA #$02
          JMP TONE1


TONE4     STA MELCOM
          RTS
TONE5     STA MEL2
          RTS

TONE6     INX
          LDA BUF1,X
          CMP#$01
          BCC TONE19
          CMP#$05
TONE7     BCS TONE19
          STA MEL3
          LDA BUFMELH
          BNE TONE8
          LDA BUFMELL
          BNE TONE8
          RTS

TONE8     JSR MELPOZ
TONE9     LDY#0
TONE10    LDA ($4E),Y
          BEQ TONE14
          CMP#$01
          BEQ TONE15
TONE11    INY
TONE12    INY
TONE13    INY
          CPY#$FF
          BNE TONE10
          STY MEL4
          LDA$4E
          CLC
          ADC MEL4
          STA$4E
          LDA$4F
          ADC#0
          STA$4F
          JMP TONE9
TONE14    RTS
TONE15    LDA MEL2
          CMP#$01
          BEQ TONE16
          CMP#$02
          BEQ TONE17
          JSR TONE18
          BEQ TONE12
          JSR TONE18
          BEQ TONE13
          DEY
          JSR TONE20
          INY
          JSR TONE20
          JMP TONE13
TONE16    JSR TONE18
          BEQ TONE12
          JSR TONE20
          JMP TONE12
TONE17    INY
          JSR TONE18
          BEQ TONE13
          JSR TONE20
          JMP TONE13
TONE18    INY
          LDA ($4E),Y
          CMP#6
          RTS
TONE19    JMP MUZERR
TONE20    LDA MELCOM
          CMP#$01
          BEQ TONE23
          LDA ($4E),Y
          SEC
          SBC MEL3
          CMP#1
          BCS TONE21
          RTS
TONE21    CMP#6
          BCC TONE22
          RTS
TONE22    STA ($4E),Y
          RTS
TONE23    LDA ($4E),Y
          CLC
          ADC MEL3
          CMP#6
          BCC TONE22
          RTS

BUFMELL   DS 1   положение мелодии 
BUFMELH   DS 1   в памяти
MELCOM    DS 1   подкод команды: \ или /
MEL1      DS 1   на сколько 
MEL2      DS 1   номер голоса
MEL3      DS 1   служебные 
MEL4      DS 1

MUZERR    JMP BASERR46
