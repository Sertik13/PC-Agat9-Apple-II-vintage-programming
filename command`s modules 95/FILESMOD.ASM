
*---------------------------*
* смешанная команда "FILES" *
*---------------------------*

; требует модуля WINMODL2.ASM
; использует 4-й сегмент ($8000-$9FFF) для подключения
; банка B (для временного буфера)

FILES   DFB:10010010
        DW RLINE
        DFB 6,9
        DW 0
        ASC "FILES (vt,ht,xl,yl,col1,col2,{S,D,ftype})"
        DFB 0

FDBFL   EQU $01   указатель к полю файла
FDBFH   EQU $02
FXCUR   EQU $3C   служебные
FXCUR1  EQU $3D
FXCUR2  EQU $3E
FCALC   EQU $3F
FYL     EQU $11   размер окна по X 
FXL     EQU $12   размер окна по Y 
FXL1    EQU $06   длина печати имени файла
FVTAB   EQU $07
FILNUM  EQU $08   число считанных полей файлов
FTXTCOL EQU $09   цвет текста имен
FRAMCOL EQU $15   цвет меню-рамки

FDBUF   EQU $800  буфер для чтения сектора
FDTRK   EQU $8000 буфер для значения треков
FDSCT   EQU $8100 -//-  секторов
FDTYP   EQU $8200 -//- типов файлов
FDNAL   EQU $8300 буферы хранения адресов имен файлов
FDNAH   EQU $8400 (ML/ST)
FNAMEB  EQU $9000 буфер хранения имен файлов


        JSR FPARAM  проверка параметров
        LDA $C140
        LDY $C150
        STA FILES3+1
        STY FILES3+4
        STA $C14B
        JSR FILES4  прочесть каталог и сложить в буферы
        LDX FILNUM
        BEQ FILES48
FILES1  DEC FILNUM
        JSR OWIN1
        JSR FILES17
FILES2  PHA
        TYA
        PHA
        TXA
        PHA
        JSR CWIN3
        PLA
        TAX
        PLA
        TAY
        PLA
FILES3  STA $C140
        STA $C150
        RTS

FILES48 JMP FLSERR2

FILES4  LDA #$00
        STA FILNUM
        STA RWSECT
        STA FDBFL
        LDA #<FNAMEB
        STA FDBFH
        LDA #$11     читать сектор главного VTOC
        STA RWTREK
        LDA #<FDBUF
        STA RWBUFH
        LDA #>FDBUF
        STA RWBUFL
        JSR FILES6
FILES5  LDA FDBUF+1  посмотреть ссылку
        STA RWTREK   каталога
        LDA FDBUF+2
        STA RWSECT
        JSR FILES6
        LDA #$00
        STA FXCUR
        JSR FILES8
        BCC FILES5
        CLC
        RTS

FILES6  LDA #$00
        STA RWTOM
        STA RWERR
        LDA #$01
        STA RWMODE
        JSR FREADY
        JSR RWTSGO
        JSR RWTSGO1
        BCS FILSERR
        RTS
        
FREADY  LDY #$00  
        LDX RWSLOT
        TXA
        LSR A
        LSR A
        LSR A
        LSR A
        ORA #$C0
        STA FREADY1+2
FREADY1 LDA $C60C      если работаем не с TEAKом
        CMP #TEACID    то готовность не проверять!
        BNE FREADY4
        LDA #$92                              
        STA $C083,X
        LDA #$BD
        STA $C087,X
        LDA RWDRV  
        LSR A
        ORA #$06
        STA $C083,X
        LDA #15
        STA $C083,X
FREADY2 LDA $C081,X    проверка на READY
        BPL FREADY3
        LDA #$50
        JSR WAIT
        INY
        CPY#$50
        BNE FREADY2
        JSR FREADY3
        BNE FILSERR    JMP
FREADY3 LDA#14
        STA $C083,X
FREADY4 RTS

FLSERR2 LDA#<FLERR1
        LDY#>FLERR1
        LDX#6
        BNE FILEROR

FILSERR LDX#8
        LDA#<FLERR
        LDY#>FLERR
FILEROR JSR FILES3
        JSR DCERR
        JMP DCEXIT

FLERR   DCI "ОШИБКА ОБМЕНА"
FLERR1  DCI "ФАЙЛ НЕ НАЙДЕН"

FPARAM  JSR CH.PARH
        JSR PR10
        LDY BUF1         vt
        STY FVTAB
        LDA COLOR
        PHA
        STA FTXTCOL
        LDA BUF1+5       цвет меню-рамки
        JSR PR7
        LDA COLOR
        AND #:11011111
        STA FRAMCOL
        PLA
        STA COLOR
        LDA BUF1+3       длина окна
        STA FYL  
        LDA BUF1+2
        TAY
        ASL A
        STA FXL1
        TYA
        SEC
        SBC#4
        STA FXL
        LDA BUF1+4       перенести цвет окна
        STA BUF1+5
        LDA #$01         задать тип окна
        STA BUF1+4
        LDX XBUF1
        LDA BUF1+6
        CPX#7 
        BCC FPARAM1
        CMP#2
        BCC FLSERR1
        CMP#7
        BCS FLSERR1
        LDY $C150
        STA $C15D
        STA DEFSLOT
        ASL A
        ASL A
        ASL A
        ASL A
        STA FMSLOT
        STA $C100,Y
        STA RWSLOT
FPARAM1 LDA BUF1+7
        CPX#8
        BCC FPARAM2
        CMP#1
        BCC FLSERR1
        CMP#3
        BCS FLSERR1
        STA $C15D
        STA FMDRV
        STA DEFDRV
        STA RWDRV
        STA $C100,Y
FPARAM2 RTS

FLSERR1 JMP BASERR46

FILTYPE DS 1
FILTRK  DS 1
FILSEC  DS 1

FILES7  SEC 
        RTS 
FILES8  LDX FXCUR
        LDA FPOZI,X
        TAY 
        LDA FDBUF,Y
        BEQ FILES7      нет файла
        CMP #$FF
        BEQ FILES11     файл стерт
        INY
        INY
        TAX
        LDA XBUF1       выбирать только файлы 
        CMP #9          данного типа
        BCC FILES9 
        LDA FDBUF,Y
        CMP BUF1+8
        BEQ FILES9 
        AND#$7F
        CMP BUF1+8
        BNE FILES15
FILES9  TXA
        LDX FILNUM
        STA FDTRK,X     трек файла
        DEY 
        LDA FDBUF,Y     сектор файла
        STA FDSCT,X
        INY 
        LDA FDBUF,Y     тип
        STA FDTYP,X
        LDA FDBFL       адрес имени с$9000 и далее
        STA FDNAL,X
        LDA FDBFH
        STA FDNAH,X
        LDX FXCUR
        LDA FPZ2NAM,X
        TAX 
FILES10 LDA FDBUF,X
        CMP #$A0
        BNE FILES12
        STX FXCUR1
        DEX 
        BNE FILES10
FILES11 BEQ FILES15
FILES12 LDY #$00
        LDX FXCUR
        LDA FPZ1NAM,X   имя файла
        TAX 
FILES13 LDA FDBUF,X
        STA (FDBFL),Y   сложить на $9000 и далее 
        INY 
        INX 
        CPX FXCUR1
        BCC FILES13
        LDA #$00        положить 0 в конец имени
        STA (FDBFL),Y
        INY 
        TYA 
        CLC 
        ADC FDBFL       изменить 
        STA FDBFL
        BCC FILES14
        INC FDBFH
FILES14 INC FILNUM
FILES15 INC FXCUR
        LDA FXCUR
        CMP #$07        кол-во файлов в секторе
        BCS FILES16
        JMP FILES8
FILES16 CLC 
        RTS 

FPOZI   DFB $0B,$2E,$51
        DFB $74,$97,$BA
        DFB $DD
FPZ1NAM DFB $0E,$31,$54
        DFB $77,$9A,$BD
        DFB $E0
FPZ2NAM DFB $2B,$4E,$71
        DFB $94,$B7,$DA
        DFB $FD

FILES17 JSR FILES32
FILES18 JSR FILES26
FILES19 LDA $C000
        BPL FILES19
        PHA 
        JSR FILES31
        PLA 
        STA $C010
        CMP #$99
        BEQ FILES20
        CMP #$9A
        BEQ FILES22
        CMP #$8D
        BEQ FILES23
        CMP #$9B
        BNE FILES18
        LDX #$00
        RTS 

FILES20 LDX FXCUR
        BEQ FILES18
        DEC FXCUR
        DEC FXCUR2
        BPL FILES18
        INC FXCUR2
        JSR WDN2
FILES21 JSR FILES36
        JMP FILES18
FILES22 LDA FXCUR
        CMP FILNUM
        BCS FILES18
        INC FXCUR
        INC FXCUR2
        LDA FXCUR2
        CMP FYL
        BCC FILES18
        DEC FXCUR2
        JSR WUP2
        JMP FILES21

FILES23 LDX FXCUR
        LDA FDTYP,X
        AND #$0F
        STA FILTYPE
        LDA FDTRK,X
        STA FILTRK
        LDA FDSCT,X
        STA FILSEC
        LDA FDNAL,X
        STA FDBFL
        LDA FDNAH,X
        STA FDBFH
        LDY#0
FILES24 LDA (FDBFL),Y
        BEQ FILES25
        EOR#$80
        STA FDBUF,Y
        INY
        BNE FILES24
FILES25 TYA
        TAX
        LDY #>FDBUF
        LDA #<FDBUF
        RTS

FILES26 JSR FILES44
        BIT COLOR
        BMI FILES30
        LDA FRAMCOL
FILES27 LDY #$01
FILES28 STA (BASL),Y
        INY
        INY
        CPY FXL1
        BCC FILES28
        RTS

FILES29 LDA #$A0
        DFB $2C
FILES30 LDA #$5F
        LDY #$02
        STA (BASL),Y
        RTS

FILES31 JSR FILES44
        BIT COLOR
        BMI FILES29
        LDA FTXTCOL
        JMP FILES27

FILES32 LDX #$00
        STX FXCUR
        STX FXCUR2
FILES33 JSR FILES36
        INC FXCUR2
        INC FXCUR
        LDA FXCUR
        CMP FILNUM
        BEQ FILES34
        BCS FILES35
FILES34 CMP FYL  
        BCC FILES33
FILES35 LDA #$00
        STA FXCUR
        STA FXCUR2
        RTS

FILES36 JSR FILES44
        BIT COLOR
        BMI FILES37
        LDA FTXTCOL
        STA COLOR
FILES37 LDX FXCUR
        LDA FDNAL,X
        STA FDBFL
        LDA FDNAH,X
        STA FDBFH
        LDY #$A0
        LDA FDTYP,X
        PHA
        AND #$80
        BEQ FILES38
        LDY #$AA
FILES38 TYA
        JSR COUT2
        LDY #$AD
        PLA
        AND #$7F
        LDX#7
FILES39 CMP FTYPTBL,X
        BEQ FILES40
        DEX
        BPL FILES39
        BMI FILES41
FILES40 LDA FTPTITL,X
        DFB @44
FILES41 TYA
        JSR COUT2
        LDA #$A0
        JSR COUT2
        LDY #$00
FILES42 LDA (FDBFL),Y
        BEQ FILES46
        JSR FILES43
        BCC FILES42
        BCS FILES47
FILES46 LDA #$A0
        JSR FILES43
        BCC FILES46
FILES47 LDA COLOR
        BMI FILES45
        LDY CH
        INY
        STA (BASL),Y
FILES45 RTS

FILES43 STY FCALC
        JSR COUT2
        LDY FCALC
        INY
        CPY FXL
        RTS

FILES44 LDA FXCUR2
        CLC
        ADC FVTAB
        STA CV
        JSR $FC01
        LDA #$00
        STA CH
        RTS

FTYPTBL DFB $00,$01,$02,$04,$08,$10,$20,$7F
FTPTITL ASC"TIABSRKD"


