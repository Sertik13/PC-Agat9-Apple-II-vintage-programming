
*======================================*
*   <C> Friends' software 1995         *
*   ---------------------------        *
*   МОДУЛЬ ФОРМАТИРОВАНИЯ ДИСКА        *
*   ---------------------------        *
* by Luzganov V.B. and Serkov S.V.     *
* used programs text by Ilya M. Wolkov *
* только для дисководов типа FD55.F    *
* должен располагаться до $8000        *
*======================================*


*---------------------------------*
* оператор "FORMFAST"             *
*---------------------------------*
           
FORMFAST  DFB 0
          DW FORMVOL
          DFB 0,3
          DFB 0,0
          ASC "FORMFAST {S,D,V}"
          DFB 0

ABSMOVE   EQU $C00
ARMMOVE   EQU $C0C
DBUFDIR   EQU $B971
DCTWAIT   EQU $D45
FMLIST    EQU $3DC
FMIN      EQU $3D6
SFN.16    EQU $4E6

FFAST     JSR F.PAR 
          JSR F.RWMV
          JSR F.BNKSV  
          LDA #>FFAST1
          STA $CD1
          LDA #<FFAST1
          STA $CD2
          LDY $C140
          STA $C148
          LDA $9EE3
          STA F.SYSVD+1
          LDA #$60
          STA $9EE3
          STA $C100,Y
          JSR F.CHK       проверка на FD55.F
          JSR SWALBS      SWITCH ALL BANKS          
          STA $C088
          JSR FMLIST
          STA $CA
          STY $C9
          LDY #0 
          LDA #$B          код INIT
          STA ($C9),Y
          LDA #1
          STA SFN.16
          LDY #4
          LDA BUF1+2       VOLUME
          STA ($C9),Y
          INY    
          LDA BUF1+1       DRIVE
          STA ($C9),Y
          INY
          LDA BUF1         SLOT
          LSR A
          LSR A
          LSR A
          LSR A
          STA ($C9),Y
          LDA $CA
          LDY $C9
          JSR FMIN
          BCC FFEXIT
          LDY #$0A
          LDA ($C9),Y
          JSR CLBANKS
          TAX
          JSR F.SYSVRF
          CPX #4
          BEQ FFASTER1
          CPX #$10
          BEQ FFASTER3
          BNE FFASTER2 
FFEXIT    JSR F.SYSVRF
          JMP CLBANKS
  
F.SYSVRF  LDY $C140
          STY $C148
F.SYSVD   LDA#$A2         модификация
          STA $9EE3
          STA $C100,Y
          RTS

FFASTER1  JMP F.ERWP        диск защищен

FFASTER2  JMP F.INOT        ошибка обмена

FFASTER3  LDA#>S4           нет устройства
          LDY#<S4
          JMP F.ALER

FFAST1    LDA #>DBUFDIR
          STA $3E
          LDA #<DBUFDIR
          STA $3F
          LDA DCTWAIT
          STA FFAST2+1
          LDA #$18
          STA DCTWAIT
          LDA FFTREKST
          STA $44
          JSR ABSMOVE
          LDA $C081,X
          AND #$20
          BNE FFAST18
          SEC
          LDA #$10
          BNE FFAST16
FFAST18   LDA #$14
          STA $45
FFAST3    LDA $44
          JSR ARMMOVE
          JSR FFAST4
          INC $44
          LDA $44
          CMP FFTREKEX
          BCC FFAST3
          CLC
          LDA #0         ERRKOD=0 O'KEY
          
FFAST16   PHP            запомнить C     
          PHA            запомнить A  (ERRKOD)

FFAST2    LDA #$00       восстановить $D45
          STA DCTWAIT
          JSR FFAST17    восстановить вектора DOSFORMAT
          
          PLA
          PLP
          RTS             конец форматирования

FFAST4    LDA #$AA
          STA $C085,X
          LDA #$08
          STA $C087,X
          LDA #$05
          STA $C087,X
          LDA #$0D
          STA $C083,X
          LDA FFSECTST
          STA $27
          STA $C085,X
FFAST5    LDA $C081,X
          BMI FFAST5
          LDY #$00
          JSR FFAST6
FFAST7    LDY $45
          JSR FFAST6
          LDA #$A4
          JSR FFAST8
FFAST9    LDA $C086,X
          BPL FFAST9
          LDA #$FF
          STA $C085,X
          STA $C088,X
          LDA #$95
          JSR FFAST8
          LDA #$6A
          JSR FFAST8
          LDA $41
          JSR FFAST8
          LDA $44
          JSR FFAST8
          LDA $27
          STA $2A
          JSR FFAST8
          LDA #$5A
          JSR FFAST8
          JSR FFAST10
          JSR FFAST11
          INC $27
          LDA $27
          CMP FFSECTEX
          BCC FFAST7
          JSR FFAST10
          LDA #$0C
          STA $C083,X
          LDA #$04
          STA $C087,X
          LDA #$09
          STA $C087,X
          RTS 
FFAST10   LDY #$05
FFAST6    LDA $C086,X
          BPL FFAST6
          LDA #$AA
          STA $C085,X
          DEY 
          BNE FFAST6
          RTS 
FFAST8    LDY $C086,X
          BPL FFAST8
          STA $C085,X
          RTS 
FFAST11   LDA #$A4
          JSR FFAST8
FFAST12   LDA $C086,X
          BPL FFAST12
          LDA #$FF
          STA $C085,X
          STA $C088,X
          LDA #$6A
          JSR FFAST8
          LDA #$95
          JSR FFAST8
          JSR FFAST13
          LDA #$5A
          JSR FFAST8
          LDA #$AA
          JMP FFAST8
FFAST13   LDY #$00
          STY $26
          CLC 
FFAST14   LDA $C086,X
          BPL FFAST14
          LDA ($3E),Y
          STA $C085,X
          ADC $26
          STA $26
          INY 
          BNE FFAST14
FFAST15   LDY $C086,X
          BPL FFAST15
          STA $C085,X
          RTS 
FFAST17   LDA #$D3
          STA $CD1
          LDA #$E3
          STA $CD2
          RTS

FFSECTST  DFB $00
FFSECTEX  DFB $15
FFTREKST  DFB $00
FFTREKEX  DFB $A0


*--------------------*
* оператор "FORMVOL" *
*--------------------*

FORMVOL DFB 0
        DW  EXIT 
        DFB 0,3
        DFB 0,0
        ASC "FORMVOL {S,D,V}
        DFB 0
        

F.BEG   JSR F.BNKSV  
        JSR F.PAR
        JSR F.RWMV
F.BEG1  JSR F.CHK 
        JMP FRMT.E
        
F.SER   JSR F.EXIT1
        JMP BASERR46

POZ0    DFB $04,$11,$02,$03
POZ8    ASC"MADE BY VOLUME FORMAT"
        DFB $8D,$00

POZ27   EQU $7A            
POZ31   EQU $01
POZ30   DFB $12,$12,$12,$12
POZ34   DFB $2B,$2B,$2B,$28
POZ35   DFB $15,$00,$01
B.VLM   DFB $00,$2B,$53,$7B
B.MASK  DFB $3C,$44,$44,$44
CAT.VLM DFB $11,$39,$61,$89
E.MASK  DFB $E4,$E4,$E4,$D8
E.VLM   DFB $2A,$52,$7A,$9F
MASK    DFB $FF,$FF,$F8,$00

S1      DCI"ОШИБКА ОБМЕНА"
S3      DCI"ОШИБКА ВЫБОРА УСТРОЙСТВА"
S4      DCI"НЕТ УСТРОЙСТВА"
S5      DCI"ДИСК ЗАЩИЩЕН"

FRMT.E0 JSR F.INIT
        JSR SETRD
        JMP FRMT.E4

FRMT.E  LDA BUF1+2
        BNE FRT.1
FRT.0   JMP F.SER
FRT.1   CMP #5
        BCS FRT.0
        STA TOM
        LDA #$FF
        STA F.K
        BNE FRMT.E4
FRT.E   LDA #1
        STA TOM
        STA F.K
FRMT.E4 JSR SWALBS       SWITCH ALL BANKS
        STA $C083
        LDA #$11
        STA $A5B
        STA $A5E
        STA $A61
        LDA #$71
        STA $3E
        LDA #$B9
        STA $3F

        LDA #$D
        STA $3D
        LDA #$40
        STA $3C
FRM0    JSR F.NUL 
        LDA #0
        STA REE 
        STA $44
        JSR $C00
        LDA #20
        STA $45 
        LDY TOM
        STY $41
        LDA B.VLM-1,Y
        STA $44
        JSR $C0C
FRM1    LDA $44
        JSR $C0C
FRM11   JSR SETWRT    ВКЛЮЧЕНИЕ ЗАПИСИ
        JSR $E47D     WRITRACK
        JSR SETRD   ВКЛЮЧЕНИЕ ЧТЕНИЯ
        JSR $E4E7     TESTRACK
        BCC FRM2
        INC REE
        LDA REE
        CMP #3
        BCC FRM11
        JMP F.INOUT
FRM2    INC $44
        LDA #0
        STA REE
        LDY TOM
        LDA E.VLM-1,Y
        CMP $44
        BCS FRM1

        JSR MAKEVTC 
        JSR MAKECAT
        LDA F.K
        BMI FRMOL
        INC TOM
        LDA TOM 
        CMP #5
        BCS FRMOL
        JMP FRMT.E0
FRMOL   JMP F.EXIT1

MAKEVTC LDY #0
        LDX #0
MV1     LDA POZ0,Y
        STA ($3E),Y
        INY
        CPY #4
        BNE MV1
        INY 
        INY
        LDA TOM
        STA ($3E),Y
        LDY #8
MV2     LDA POZ8,X
        BEQ MV3
        STA ($3E),Y
        INX
        INY
        BNE MV2
MV3     LDY #$27
        LDA #POZ27
        STA ($3E),Y
        LDA #POZ31
        LDY #$31
        STA ($3E),Y
        LDX TOM
        DEY
        LDA POZ30-1,X
        STA ($3E),Y
        LDY #$34
        LDA POZ34-1,X
        STA ($3E),Y
        INY
        LDX #0
MV7     LDA POZ35,X
        STA ($3E),Y
        INY
        INX
        CPX #3
        BNE MV7
        LDX TOM
        LDA B.MASK-1,X
        TAY
        LDA E.MASK-1,X
        STA REE
        LDX#0
MV8     LDA MASK,X
        STA ($3E),Y
        INX 
        INY
        CPX #4
        BNE MV8
        LDX #0
        CPY #$7C
        BNE MV10
MV11    INY 
        INX
        CPX#4
        BNE MV11
        LDX #0
MV10    CPY REE
        BNE MV8
        LDX TOM
        LDA CAT.VLM-1,X
        STA RWTREK
        LDA #0
        STA RWSECT
        STA ACTION
        STA RWTOM
        LDA #2
        STA RWMODE 
        LDA $3E
        STA RWBUFL 
        LDA $3F
        STA RWBUFH   
        LDA #0 
        LDX RWSLOT
        STA $44
        JSR $C00
        JMP F.RWTS


MAKECAT JSR F.NUL  
        LDA #$11
        LDY #1
        STY RWSECT
        STA ($3E),Y
        INY
        LDA #3
        STA ($3E),Y
MC1     JSR F.RWTS
        INC RWSECT
        INC $B973   ССЫЛКА НА СЛЕД. СЕКТ. КАТАЛОГА
        LDA RWSECT
        CMP #$13
        BNE MC1
        LDA #0 
        STA $B973
        STA $B972
        JSR F.RWTS
        INC RWSECT
        LDA #1
        STA $B973
        LDA #$11
        STA $B972

F.RWTS  JSR $3E3  
        JSR $3D9
        LDA RWERR 
        CMP #2
        BCC RWT1
        PLA
        PLA
        PLA 
        PLA
        JMP F.INOUT
RWT1    RTS

F.INIT  LDX RWSLOT
        LDA #$92
        STA $C083,X
        LDA #$BD        ВКЛЮЧЕНИЕ ДИСКОВОДА
        STA $C087,X
        LDA RWDRV
        LSR A
        LSR A
        LDA #$3
        ROL A
        STA $C083,X
        LDA #15
        STA $C083,X
        RTS

F.NUL   LDY #0
        TYA
F.NUL1  STA ($3E),Y 
        INY
        BNE F.NUL1
        RTS


F.EXIT1 LDA #$E    
        LDX RWSLOT
        STA $C083,X
CLBANKS LDX #0
F.BE    LDY F.BKS,X
        STA $C100,Y
        INX 
        CPX #4
        BNE F.BE
        STA $C083
        RTS

TOM     DS  1
REE     DS  1
F.BKS   DS  5
F.K     DS  1 

SETRD   LDA #4
        STA $C087,X
        LDA #9
        STA $C087,X
        LDA #$C
        STA $C083,X
        RTS
SETWRT  LDA #8
        STA $C087,X
        LDA #5
        STA $C087,X
        LDA #$D
        STA $C083,X
        RTS
    
*=============================================*
* Общие подпрограммы для операторов FORMATMOD *
*=============================================*

F.BNKSV LDA $C144  
        STA F.BKS
        LDA $C155
        STA F.BKS+1
        LDA $C166
        STA F.BKS+2
        LDA $C177
        STA F.BKS+3
        RTS
        
SWALBS  STA $C15D
        STA $C168
        STA $C179
        RTS 
        
F.PAR   JSR CH.PARH     проверить старшие байты параметров
        LDX XBUF1       SLOT
        CPX #1
        BCS F.PAR1      SLOT был дан
        LDA RWSLOT
        STA BUF1
        BNE F.PAR2     (JMP)
F.PAR1  LDA BUF1
        CMP #2
        BCC F.PARER - ошибочное значение
        CMP #7
        BCS F.PARER - ошибочное значение
        ASL BUF1
        ASL BUF1
        ASL BUF1
        ASL BUF1
F.PAR2  CPX #2          DRIVE
        BCS F.PAR3      DRIVE был дан
        LDA RWDRV
        STA BUF1+1
        BNE F.PAR4      (JMP)
F.PAR3  LDA BUF1+1
        BEQ F.PARER - ошибочное значение
        CMP#3
        BCS F.PARER - ошибочное значение
F.PAR4  CPX #3          VOLUME
        BCS F.PAR5 
        LDA RWTOM
        STA BUF1+2
F.PAR5  RTS
F.PARER JMP BASERR46

F.RWMV  LDX #1         записать SLOT и DRIVE 
        LDA BUF1,X     в $558 и $559
        STA RWSLOT,X
        DEX
        BPL F.RWMV+2
        RTS

F.CHK   LDA RWSLOT     проверка на TEAK
        LSR A          ----------------
        LSR A
        LSR A
        LSR A
        ORA #$C0
        STA F.CHK1+2
F.CHK1  LDA $C00C
        CMP #$BD
        BEQ F.CHK2
ERAP    LDA #<S3       это не TEAK
        LDY #>S3 
        JMP F.ALER

F.CHK2  JSR F.INIT     проверка на привод
        JSR SETRD      ------------------
        LDA $C081,X
        LDY RWDRV
        CPY #2
        BEQ F.CHK3
        AND #12
        BEQ F.CHK4
        BNE ERAP       ошибка выбора устройства
F.CHK3  AND #3 
        BNE ERAP 

F.CHK4  LDA #0         проверка на сигнал READY
        STA $4E        ------------------------
        STA $4F
        LDX RWSLOT
F.CHK6  LDA $C081,X
        BPL F.CHK5
        DEC $4E
        BNE F.CHK6
        DEC $4F
        BNE F.CHK6
        BEQ F.INOUT    дисковод не готов

F.CHK5  LDX RWSLOT     проверка на сигнал WRITE PROTECT
        LDA $C081,X    --------------------------------
        AND #$20
        BEQ F.ERWP
        RTS            все в порядке !

F.ERWP  LDA #<S5       диск защищен
        LDY #>S5
        LDX #4
        BNE F.ALER     (JMP)

F.INOUT LDX #8         ошибка обмена
F.INOT  LDA #<S1
        LDY #>S1

F.ALER  PHA
        TYA
        PHA
        JSR F.EXIT1
        PLA
        TAY
        PLA
        JSR DCERR
        JMP DCEXIT


