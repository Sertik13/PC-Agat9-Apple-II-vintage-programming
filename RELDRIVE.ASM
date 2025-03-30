     LST ON


****************************************
* <C> Friends' software 1995           *
*     by Serkov S.V.                   *
* Драйвер загрузки перемещаемых файлов *
* для DOS 3.3 ИКП-1                    *
****************************************

         LST OFF

*-------- Метки и подпрограммы среды DOS ---------*

KWP       EQU $B80E  флаг указанных ключевых слов
R2BYT     EQU $D819  читать два байта из файла
OPENF     EQU $D702  открыть файл
CLOSE     EQU $D612  закрыть файл
FMCODE    EQU $B823  код работы менеджера файлов
FMSUBCODE EQU $B824  подкод -//-
DRVFM     EQU $DA4C  внутренний вход в менеджер файлов
FMRNGADR  EQU $B82B  адрес файла в памяти (FILEMANEDGER)
FMRNGLEN  EQU $B829  длина файла (FILEMANEDGER)
DEFADD    EQU $B81B  адрес файла в памяти (DOS)
LDP       EQU $B809  длина файла (DOS)

RFILTYPE  EQU $10    тип файла "R"

DRIVIN    EQU $D697  вход в драйвер
DRIVEX    EQU $D69A  выход из драйвера если файл не "R"
DRIVLOC   EQU $E800  положение резидента в DOS
CHKSUMAD  EQU $DF38  + $100 для проверки CHECKSUM DOS

; ячеики ZERO PAGE   рабочие ячейки "настройщика"

RADR     EQU $06
NAS      EQU $08
SERO     EQU $2A
ADR      EQU $4E
HRAN     EQU $01
LIR      EQU $C9
KOM      EQU $15

; подпрограммы системы MONITOR

CLREOP   EQU $FC4B очистка до конца окна
COUT1    EQU $FDE4 печать символа на экран
COUT2    EQU $FC0E печать символа без распознавания управ.
IOSAVE   EQU $FF4B сохранить регистры
IOREST   EQU $FF40 восстановить регистры


         ORG $6000
         OBJ $8000


*------------------------*
*     НАЧАЛО ДРАЙВЕРА    *
*------------------------*

STARTRM JSR IOSAVE    сохранить вектора входа
        JSR SETINDOS  внести изменения в ДОС
        JSR TEXT      вывести заставку
        JSR CALCSUM   пересчитать контрольную сумму ДОС
EXIT    JMP IOREST    восстановить вектора и выйти


*----------------------------*
* УСТАНОВИТЬ ИЗМЕНЕНИЯ В ДОС *
*----------------------------*

SETINDOS JSR ALLSET   общие изменения
         JSR SETTABL  изменить таблицы загрузки ДОС
         JSR MOVIN    перенос драйвера в ДОС
         RTS

; общие изменения для установления связи
; драйвера с ДОС


ALLSET   LDX $C160
         STX $C168
         STX $C08B
         LDA#$4C
         STA DRIVIN
         LDA#<IN 
         LDY#>IN
         STA DRIVIN+2
         STY DRIVIN+1
         STA $C100,X
         RTS

* изменение таблиц загрузки ДОС
* чтобы присвоить адреса $E800-$E8FF банка 9 под ДОС

SETTABL  LDX $C170
         STA $C179
         STA $C083
         LDY#0
SET1     LDA TABLTEAK,Y
         STA $E185,Y
         STA $E1B0,Y
         INY
         CPY#5
         BNE SET1
         LDA#$14
         STA $E1B9
         LDY#0
SET2     LDA TABLSHUG,Y
         STA $E085,Y
         STA $E0B0,Y
         INY
         CPY#5
         BNE SET2
         STA $C100,X
         RTS

TABLTEAK DFB $09,$E8,$E8,$00,$13
TABLSHUG DFB $04,$E8,$E8,$03,$03
            

; Перенос драйвера на его место в ДОС

MOVIN    LDX$C170
         STX$C179
         STX$C083
         LDY#0
MOVIN1   LDA DRIVE,Y
         STA DRIVLOC,Y
         INY
         BNE MOVIN1
         STA $C100,X
         RTS


*-------------------------*
* ВЫВОД ЗАСТАВКИ ДРАЙВЕРА *
*-------------------------*

TEXT     JSR DIALOG
         BCC RALTXT2
         LDX#0
RALTXT1  LDA COPY,X
         BEQ RALTXT2
         CMP#$8D
         BEQ CROUT
         JSR COUT2
         INX
         BNE RALTXT1
RALTXT2  RTS

CROUT    JSR COUT1
         INX
         BNE RALTXT1
         RTS

COPY     DFB $8D
         DFB $8D
         ASC "ђ››››››››››››››››››››››››››’"
         DFB $8D
         ASC "|  Load Relocatable files  |"
         DFB $8D
         ASC "|         driver           |
         DFB $8D
         ASC "| by Serkov S.V.  14.07.95 |"
         DFB $8D
         ASC "ќ››››››››››››››››››››››››››џ"
         DFB $8D,$8D,$00


DIALOG   LDX $76
         INX
         BEQ DIALOG1
         LDX $33
         CPX #$5D
         BEQ DIALOG1
         CLC           PROGRAMM EXEC
         DFB @44
DIALOG1  SEC           DAILOG
         RTS


*---------------------------------------------------*
* Программа пересчета и коррекции таблицы           *
* контрольной суммы ДОС 3.3 (Агат-9)                *
* by Sergej Serkov 28.11.94 Friends' software       *
* (для коррекции CHECKSUM после внесения изменений) *
*---------------------------------------------------*

; Определение меток:

SYSVRFY  EQU $DEE3   подпрограмма подсчета суммы ДОС
SEGMSUM  EQU $C160   сегмент для подключения
RDWRALL2 EQU $C08B   второй половины 6-го сегмента
BANKSUM  EQU $8      восьмого банка
RDWRALL1 EQU $C083   первая половина 6-го сегмента
SVLOOP   EQU $DEEC

; Программа:

CALCSUM  LDA SEGMSUM
         PHA 
         LDY#BANKSUM
         STA SEGMSUM,Y
         STA RDWRALL2
         
         LDA CHKSUMAD
         CMP#$68
         BEQ CALC1
         BCS CALC2
         INC CHKSUMAD
CALC1    INC CHKSUMAD
                       
CALC2    LDA#$9D
         STA $DF14
         LDA#$4C
         LDX#<SVLOOP
         LDY#>SVLOOP
         JSR READR
         LDA#$A2
         STA SYSVRFY
         JSR SYSVRFY
         LDA#$DD
         STA $DF14
         LDA#$F0
         LDX#$8D
         LDY#$D3
         JSR READR
         STA RDWRALL1
         PLA
         TAY
         STA $C100,Y
         RTS

READR    STA $DF17
         STX $DF19
         STY $DF18
         RTS

         DS $61A0-*
                    

*-----------------------------------------------------*
* заплата доступа к загрузке "R" файла командой BLOAD *
*-----------------------------------------------------*

DRIVE
         ORG DRIVLOC

IN       CMP#RFILTYPE      это "R"-файл ?
         BEQ RELFILE
         JSR OPENF         нет, выйти из драйвера
         JMP $D69A
         
RELFILE  JSR OPENF         да, открыть файл
         JSR R2BYT         считать адрес загрузки
         TAX
         STX LIR           сохранить адрес по ORG в LIR
         STY LIR+1
         LDA KWP           адрес был задан в команде ?
         AND#$01
         BNE YESADR
NOADR    STX DEFADD        нет, LIR=DEFADR
         STY DEFADD+1
YESADR   LDX DEFADD        в любом случае DEFADD=NAS
         LDY DEFADD+1
         STX NAS
         STY NAS+1
         JSR R2BYT         считать длину файла
         PHA
         TYA               сохранить временно в стеке
         PHA
         JSR R2BYT         считать длину кодовой части
         STA ADR           сохранить в ADR
         STY ADR+1
         PLA               восстановить длину файла
         TAY
         PLA
         STA LDP           поместить ее в системные
         STA FMRNGLEN      ячейки DOS и FILEMANEDGER
         STY LDP+1
         STY FMRNGLEN+1
         LDX NAS           поместить адрес файла
         LDY NAS+1
         STX FMRNGADR      в FILEMANEDGER
         STY FMRNGADR+1
         LDY#3             читать файл до конца
         STY FMCODE
         DEY
         STY FMSUBCODE
         JSR DRVFM
         JSR RELCALC       переместить адреса
         JMP CLOSE         закрыть файл

*======================================*
* ------------------------------------ *
*    НАСТРОЙЩИК ПЕРЕМЕЩАЕМЫХ ФАЙЛОВ    *
* ------------------------------------ *
* by Serkov S.V.   version 17.07.95    *
*======================================*

; перемещает 3 и 2 байтовые команды, а также псевдокоманды
; DFB и DW. Перемещает также псевдокоманду DDB в отличие
; от версии 15.08.94. Для нее зарезервирован атрибут метки
; $21 (Ассемблер Громова)
       

RELCALC  LDA ADR           установить начало таблицы 
         CLC               перемещения
         ADC NAS
         STA ADR
         LDA ADR+1
         ADC NAS+1
         STA ADR+1
         LDA #4
         CLC
         ADC ADR
         STA ADR
         LDA #0
         TAY
         ADC ADR+1
         STA ADR+1
         
CSICL    LDA (ADR),Y     Y=0
         BNE RETURN
         
START    RTS

RETURN   INY             Y=1
         LDA (ADR),Y
         CLC
         ADC NAS
         STA HRAN
         INY             Y=2
         LDA (ADR),Y
         ADC NAS+1
         STA HRAN+1
         
         LDY#0
         LDA (HRAN),Y
         TAX
         LDA (ADR),Y     Y=0
         PHA
         BMI CS1         3 BYTES  ML/ST
         ASL A
         BMI CS2         2 BYTES
         ASL A
         BMI CS8         3 BYTES  ST/ML
         PLA
         TXA
         SEC
         SBC LIR
         CLC
         ADC NAS
CS7      STA (HRAN),Y

CS6      LDA#4
         CLC
         ADC ADR
         STA ADR
         LDA#0
         TAY             Y=0
         ADC ADR+1
         STA ADR+1
         TYA             A=0
         BEQ CSICL       (JMP)
         
CS8      INY
         BNE CS9         (JMP)

CS1      INY             Y=1
         LDA (HRAN),Y
         TAX
         DEY             Y=0
CS9      LDA (HRAN),Y
         SEC
         BCS CS4         (JMP)

CS2      LDY#3
         LDA (ADR),Y     2 BYTES LOW
         SEC
CS4      SBC LIR
         STA KOM
         TXA
         SBC LIR+1
         STA KOM+1
         
         LDA NAS
         CLC
         ADC KOM
         TAX             X=LOW
         LDA NAS+1
         ADC KOM+1
         TAY             Y=HIGH
         PLA
         BMI CS5         3 BYTES ML/ST
         ASL A
         ASL A
         BMI CS10        3 BYTES ST/ML
         TYA
         LDY#0
         BEQ CS7         (JMP)
         
CS10     TXA               
         PHA           Y  -> 
         TYA             <-  X
         TAX                  
         PLA
         TAY
         
CS5      TYA
         LDY#1
         STA (HRAN),Y
         TXA
         DEY             Y=0
         BEQ CS7         (JMP)
         

         DS DRIVLOC+$100-*
         
