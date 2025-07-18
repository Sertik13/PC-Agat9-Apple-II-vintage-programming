
      
         LST OFF   
*=======================*
* <C> FRIENDS' SOFTWARE *
*   by: Sergey Serkov   *
* --------------------- *
*    DIRECTORY TREE     *    
*        DRIVER         *
* --------------------- *
* version 4.07 23.10.95 *
*=======================*
         LST OFF              
* 
* использование ячеек ZERO PAGE
*
* $D0-$D1 - обращение к буферу
*           (буфер $AF00 (DOS не использует))
* $4E-$4F - RNDL & RNDH (monitor) - в CD\, CD. CD/
* $C9-$CA - счетчик директорий в &"DIR"
*           (случайное число для BASICа)
*

; версия имеет только команды переключения подкаталогов:
; -------------------------------------------------------
; &"DIR"{,S,D}          список директорий
; &"CD\"{,S,D}          включить корневой каталог
; &"CD."{,S,D}          включить надкаталог
; &"CD",NAME {,S,D}     включить подкаталог с именем     
; &"CD?"{,S,D}          выбрать и включить подкаталог
;

*ТАБЛИЦА МАСОК КОМАНД*
*позиция:    12345678

PDIR     EQU:10000000   1    "DIR"
PRTDIR   EQU:01000000   2    "CD\"   
PUPDIR   EQU:00100000   3    "CD."
PSDIR    EQU:00010000   4    "CD"
PSDIR1   EQU:00001000   5    "CD?"
PDDIR    EQU:00000100   6    "ED"   \      
PDDIR1   EQU:00000010   7    "ED?"  | резерв для 
PMDIR    EQU:00000001   8    "MD"   | будущих версий
PRNDIR   EQU:00000000   9    "RD"   /



*---------------------------*
* BЫДATЬ KATAЛOГ ДИPEKTOPИЙ *
*---------------------------*

DIR      DFB 0
         DW CDROOT 
         DFB 0,2
         DFB 0,0
         ASC"DIR {S,D}"
         DFB 0
         
         LDA #PDIR
         STA DIRFLAG
         JSR TAKEPAR
DIR1     JSR INSTALL
         JSR WINDOWDL
         JSR READVTOC
         JSR READY
         JSR WORK 
         JSR TOM
SEEKDIR  JSR REFERCE 
         BCS REPORT
         JSR WORK
         JSR SEEKSUB
         BCS SEEKDIR
         JMP KOLVSUB

INSTALL  LDA #$00
         STA BUFS
         STA BUFS+1
         STA SCALC
         STA SCALC+1
         STA REGKLAV
         RTS

WINDOWDL LDA DGW
         SEC
         SBC UGW
         SEC
         SBC#$03
         STA IOSABER1+1
         RTS

READVTOC LDA#$11
         STA RWTREK                    
         LDA#0
         STA RWSECT
         STA ACTION
         STA RWTOM
         STA RWBUFL
         STA BUFS
         LDA #<BUFDIR
         STA RWBUFH
         STA BUFS+1
         LDA#1 
         STA RWMODE
         RTS
                 
REPORT   LDA SCALC         подкаталоги были? 
         BNE REPORT1     если да, то на KOLVSUB
         LDA DIRFLAG     проверка на приход
         AND #PSDIR      с команды &"SUBDIR":"NAME"
         BNE REPORT2     или с &"SUBDIR?" ,если да, то...
REPORT1  JMP KOLVSUB

REPORT2  JSR LOADCV      - введено в версии 4.00
         LDA #$03  
         LDX #$06
         JMP DIRERR 

VOLUME   ASC "ДИСК N "       
TSO2     ASC "<DIR>"
TSO3     ASC "ДИРЕКТОРИЙ"

ERR0     DFB $0D,$07,$8D
ERR1     DCI "ОШИБКА ОБМЕНА"
ERR2     DCI "ДИСК ЗАЩИЩЕН"           
ERR3     DCI "ДИРЕКТОРИЯ НЕ НАЙДЕНА"
ERR4     DCI "ДЛИННОЕ ИМЯ"            введено в верс. 4.0
ERRMIT   DFB ERR0-ERR0
         DFB ERR1-ERR0
         DFB ERR2-ERR0
         DFB ERR3-ERR0
         DFB ERR4-ERR0

TOM      JSR DRCROUT
         JSR DRCLREOL
         LDX#$00
TOM1     LDA VOLUME,X  
         JSR DRCOUT
         INX
         CPX#$07
         BNE TOM1

         LDY#$06
         LDA (BUFS),Y
         JSR DECO  
         JSR DRCLREOL
         JSR DRCROUT
         JSR DRCLREOL
         JMP DRCROUT      

                  
*---> DECIMAL OUTPUT <---*
         
DECO     JSR DECOZ
         LDX#2
DECO1    LDA DNUMBER,X
         JSR DRPRHEX
         DEX
         BPL DECO1
         RTS


REFERCE  LDY#$01
         LDA (BUFS),Y
         BNE REFERCE1
         INY 
         TAX
         LDA (BUFS),Y
         BNE REFERCE2
         BEQ REFERCE4
REFERCE1 INY
         TAX
REFERCE2 LDA (BUFS),Y
         STX RWTREK
         STA RWSECT
REFERCE3 CLC
         RTS
REFERCE4 SEC
         RTS

WORK     JSR RWTSGO
         JSR RWTSGO1
         LDA#0
         STA STATUS
         LDA RWERR          
         TAY
         CMP#$04       A<$04 - нормальное завершение
         BCC REFERCE3   
         PLA
         PLA
         TYA
ERRFLOP  BMI ERORDISK   $80 - сбой ГМД
         ASL A                            
         ASL A       
         BCS ERORDISK   $40 - сбой при чтении
         ASL A
         ASL A    
         BCS ERORWRIT   $10 - ГМД защищен
         RTS            иначе  C=0 - нормальное заверш.
                                     
                         
ERORDISK LDA#$01    
         LDX#$08
         BNE DIRERR
ERORWRIT LDA#$02
         LDX#$04

* обработка ошибок при обмене с диском
* и других ошибок драйвера

DIRERR   STA RNDH       - сохранить код обработки  
         STX RNDL       - сохранить код ошибки
         BIT ERRFLAG
         BMI DIRERR2
DIRERR1  LDX#0
         JSR DIRERR3
         LDX RNDH
         JSR DIRERR3
         JSR DRCLREOL
         JSR DRCROUT
DIRERR2  JSR DIALOG
         LDX RNDL
         LDA SEGM
         STA USERMEM
         LDA#3
         JMP DREXIT
DIRERR3  JSR DRCLREOL
         LDA ERRMIT,X
         TAX
DIRERR4  STX DIRERR5+1
         LDA ERR0,X 
         PHA
         ORA#$80
         JSR DRCOUT
DIRERR5  LDX#$00        - модификация 
         INX
         PLA
         BPL DIRERR4
         RTS

READY    LDY #$00  
         LDX RWSLOT
         TXA
         LSR A
         LSR A
         LSR A
         LSR A
         ORA #$C0
         STA READY1+2
READY1   LDA $C60C      если работаем не с TEAKом
         CMP #TEACID    то готовность не проверять!
         BNE READY4
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
READY2   LDA $C081,X     проверка на READY
         BPL READY3
         LDA #$50
         JSR WAIT
         INY
         CPY#$50
         BNE READY2
         JSR READY3
         JMP ERORDISK 
READY3   LDA#14
         STA $C083,X
READY4   RTS

SEEKSUB  LDX#$07
         STX SEEKSUB4+1
         LDY#$0B
         LDA (BUFS),Y 
         BEQ KOLVSUB1 
         LDY#$0D        2-БАЙТ $FF
SEEKSUB1 JSR SEEKDEL
         BCS SEEKSUB3
         LDA (BUFS),Y
         CMP#$FF
         BNE SEEKSUB3
         CPX #$07       ;пpoвepять тoлькo пepвую пoзицию
         BCC SEEKSUB2   нa ... DIRECTORY
         JSR CHECKDL  
         BCS SEEKSUB3
SEEKSUB2 JMP IOSABER
SEEKSUB3 TYA
         CLC
         ADC#$23
         TAY
         DEC SEEKSUB4+1
SEEKSUB4 LDX#$00        ;сохранение X, изменено в 3.02 в.
         BPL SEEKSUB1
         SEC           
         RTS

KOLVSUB1 PLA           
         PLA
         JMP REPORT    

CHECKDL  TYA    
         PHA
         CLC
         ADC#$1F
         TAY    
         LDA (BUFS),Y
         BNE PRDIR
         INY
         LDA (BUFS),Y
         BEQ CHECKDL1 
         BNE PRDIR   
CHECKDL1 PLA
         TAY
         CLC
         RTS    
                
PRDIR    LDA DIRFLAG    проверка прихода с
         AND #PSDIR     команды &"SUBDIR":" "
         BNE PRDIR3
         JSR DRCLREOL
         LDX#2
         LDA#$AE
PRDIR1   JSR DRCOUT
         DEX
         BPL PRDIR1
         LDA#$A0
         JSR DRCOUT
         PLA
         TAY
         PHA
         LDX#0          
         INY         ;Y=0D+1
PRDIR2   JSR CLIP   
         JSR DRCROUT
PRDIR3   PLA
         TAY         ;Y=0D
         SEC
         RTS 

SEEKDEL  DEY
         DEY
         LDA (BUFS),Y
         INY
         INY
         CMP#$FF
         BNE SEEKDEL1
         SEC     
         RTS
SEEKDEL1 CLC
         RTS
                    
SUPERGO  JMP CHECKN   
                    
IOSABER  INY
         TYA
         PHA
         LDA DIRFLAG     проверка на приход
         AND #PSDIR      с команды &"SUBDIR":" "
         BNE SUPERGO     если да, то ...
         INC REGKLAV                       
         SED
         LDA SCALC
         CLC
         ADC#1
         STA SCALC 
         LDA SCALC+1
         ADC#0
         STA SCALC+1
         CLD
         LDA DIRFLAG
         AND #PSDIR1      проверки на приход с
         BNE IOSABER2     команд &"SUBDIR?"      
         LDA REGKLAV
IOSABER1 CMP#$00          ; сравнение с длиной окна
         BCC IOSABER2
         LDA#$03
         STA CURSOR  
         LDY#0
         JSR KEYIN1
         LDA#EXITCODE
         STA CURSOR  
         PLA      
         PHA
         TAY
         LDA #$00
         STA REGKLAV
IOSABER2 JSR DRCLREOL
         LDX#00  
IOSUBER3 LDA TSO2,X
         JSR DRCOUT
         INX
         CPX#05    
         BNE IOSUBER3
         LDA#$A0
         JSR DRCOUT
         PLA
         TAY
         PHA
         JSR CLIP      
         JSR DRCROUT
IOSABER4 PLA      
         TAY
         DEY
         JMP SEEKSUB3

REGKLAV  DS 1       
             
             
*------- Y - начало имени      
         
CLIP     LDA RGW
         SEC
         SBC CH
         BIT COLOR
         BMI CLIP0
         LSR A
CLIP0    SEC
         SBC#1
         STA BCLIP
CLIP1    LDX#$00             введено в верс. 4.02
CLIP2    LDA (BUFS),Y
         JSR DRCOUT
         INY
         INX 
         CPX#30
         BCS CLIP3
         CPX BCLIP
         BCC CLIP2
CLIP3    RTS

BCLIP    DS 1

KOLVSUB  LDA DIRFLAG      проверка на приход 
         AND #PSDIR1      с команды &"SUBDIR?"
         BNE JMPCEN       если да, то...
         JSR DRCLREOL
         JSR DRCROUT
         LDX#00
KOLV1    LDA TSO3,X 
         JSR DRCOUT
         INX
         CPX #10  
         BNE KOLV1
         LDA#$BA
         JSR DRCOUT
         LDA SCALC+1
         JSR DRPRHEX
         LDA SCALC
         JSR DRPRBYTE
         LDA#$00
         STA SCALC
         STA SCALC+1
         JSR DRCROUT
         JMP DRCLREOL

JMPCEN   JSR DRCLREOL
         JMP SELECT0

*--------------------------*
* BЫЙTИ B KOPHEBOЙ KATAЛOГ *
*--------------------------*

CDROOT   DFB 0
         DW  CDUP    
         DFB 0,2
         DFB 0,0
         ASC "CD\ {S,D}"
         DFB 0
         
         LDA #PRTDIR
         STA DIRFLAG
         JSR TAKEPAR
         LDA #$2C    
         STA RNDL
CDROOT1  JSR INSTALL
         JSR READVTOC
         JSR READY
         JSR WORK
         JSR REFERCE
         BCS CDROOT5  
         JSR WORK
         LDY#$0D
         LDA (BUFS),Y
         CMP#$FF
         BNE CDROOT4            
         JSR SEEKDEL 
         BCS CDROOT4            
         LDY#$2C
         LDA (BUFS),Y
         BNE CDROOT2
         INY
         LDA (BUFS),Y
         BEQ CDROOT4            
CDROOT2  LDY RNDL
CDROOT3  LDA (BUFS),Y
         STA BUFFTR
         INY       
         LDA (BUFS),Y
         STA BUFFSC
         JSR READVTOC
         JSR WORK
         LDA#$02   
         STA RWMODE
         LDY#$01
         LDA BUFFTR
         STA (BUFS),Y
         INY
         LDA BUFFSC
         STA (BUFS),Y
         JSR WORK
         JSR DRCROUT
CDROOT4  RTS  
CDROOT5  JMP ERORDISK

BUFFTR   DS 1 
BUFFSC   DS 1 

 
*--------------------*
* ВЫЙТИ В НАДКАТАЛОГ *
*--------------------*

CDUP     DFB 0
         DW  CDSUB 
         DFB 0,2
         DFB 0,0
         ASC "CD. {S,D}"
         DFB 0

         LDA #PUPDIR
         STA DIRFLAG
         JSR TAKEPAR
         LDA#$0B
         STA RNDL
         JMP CDROOT1

*--------------------*
* ВЫЙТИ В ПОДКАТАЛОГ *
*--------------------*

CDSUB    DFB:00100000
         DW  CDSUBSEL
         DFB 1,3 
         DFB 0
         DFB:00000001
         ASC 'CD name {,S,D}'
         DFB 0     
         
         JSR TAKENAME
         JSR SAVECV
CDSUB1   LDA #PSDIR
         STA DIRFLAG
         JSR INSTALL
         JSR READVTOC
         JSR READY
         JSR WORK
CDSUB2   JSR REFERCE
         BCS CDSUB3 
         JSR WORK
         JSR SEEKSUB
         BCS CDSUB2
CDSUB3   JMP REPORT2 

CHECKN   LDX #$00
CHECKN1  LDA (BUFS),Y
         CMP BUFNAME,X
         BNE CHECKN3
         INY
         INX
         CPX#30
         BNE CHECKN1
         PLA
         TAY          Y=0E B 1
         PLA         
         PLA
         DEY
         DEY
         DEY
         JMP CDROOT3

CHECKN3  JMP IOSABER4
         
*------------------------------*
* ВЫЙТИ В ПОДКАТАЛОГ С ВЫБОРОМ *
*------------------------------*

CDSUBSEL DFB 0
         DW EXIT    
         DFB 0,2
         DFB 0,0
         ASC "CD? {S,D}"
         DFB 0
         
         JSR TAKEPAR
         LDA #PSDIR1
         STA DIRFLAG
         JMP DIR1
SELECT0  LDA#$03
         STA CURSOR   
         JSR SAVECV 
SELECT   LDA CH
         CLC
         ADC#$06
         STA CH
         LDA COLOR
         BMI SELECT1
         INC CH
         INC CH
         INC CH
         INC CH
         BNE SELECT2
SELECT1  DEC CH
SELECT2  JSR KEYIN 
         CMP#$99               
         BEQ SELECT3
         CMP#$9A
         BEQ SELECT3
         CMP#$8D    
         BEQ SELECT4
         BNE LOADCV 
SELECT3  JSR DRCOUT
         BNE SELECT2
SELECT4  LDX #$00 
         LDY CH
         INY
         LDA COLOR
         BPL SELECT6
SELECT5  LDA (BASL),Y
         STA BUFNAME,X
         INY
         INX
         CPX#30 
         BCS SELECT8
         CPX BCLIP
         BCC SELECT5
SELECT8  LDA#$A0
         CPX#30
         BCS SELECT9
         STA BUFNAME,X
         INX
         BNE SELECT8+2
SELECT9  JSR LOADCV 
         JSR INSTALL
         JMP CDSUB1
SELECT6  INY
SELECT7  LDA (BASL),Y
         STA BUFNAME,X
         INY
         INY
         INX
         CPX#30 
         BCS SELECT8
         CPX BCLIP
         BCC SELECT7
         BEQ SELECT8

LOADCV   LDA BCV
         STA CV
         JMP BASCALC
SAVECV   LDA CV  
         STA BCV 
         RTS

BCV      DS 1      

DIRFLAG  DFB $00


*---------------------------*
* оператор "EXIT" для "DIR" *
*---------------------------*

EXIT     DFB:00000000
         DFB 0,0   
         DFB 0,0
         DFB 0,0
         ASC "EXIT"
         DFB 0        
         
         DO ATRIBDR&:00100000

EXIT1    LDA#<AREA
         LDY#>AREA
         JMP INEXIT
         
         ELSE

EXIT3    LDA #$FF     
         LDY #$58       поставить $FF58 (JMP на RTS)
         STA VEKTPROC+2 в вектор процедур
         STY VEKTPROC+1 (вектор функций не менялся)
         RTS
             
         FIN

; - -----------------------\
; - Служебные подпрограммы  >
; - -----------------------/
       
; TAKENAME берет текст до 30 знаков и ,S,D обращаясь
; к подпрограмме TAKEPAR

TAKENAME LDA#0
         JSR RPARAM
         CPX#30
         BCS TAKES5     имя больше 30 знаков
         STA $5F
         STY $5E
         LDY #0
TAKENM1  LDA ($5E),Y    взять N-ый символ имени начиная
         EOR #$80       с первого после ","
         STA BUFNAME,Y
         INY
         DEX
         BNE TAKENM1
         BEQ TAKENM2

TAKES4   LDX#46        ош.значение
         JMP BASERR  
         
TAKES5   PLA           длинное имя 
         PLA
         LDA#4
         LDX#2   
         JMP DIRERR

BUFNAME  EQU $800

TAKENM2  LDA#$A0        дополнить имя пробелами
TAKENM3  STA BUFNAME,Y
         INY
         CPY #30
         BNE TAKENM3
TAKEPAR  JSR CH.PARH     
         LDX#0
         JSR PARBIT
         BCC TAKEP3
         DEC XBUF1
         LDX#1          после NAME  (3 параметра)  |
         DFB $2C                                   |MAX
TAKEP3   LDX#0          только числа (2 параметра) |
         LDY XBUF1
         LDA BUF1,X
         CPY#1         
         BCC TAKEP1
         CMP#2
         BCC TAKES4
         CMP#7
         BCS TAKES4
         STA DEFSLOT
         ASL A
         ASL A
         ASL A
         ASL A
         STA FMSLOT
         STA RWSLOT               
TAKEP1   INX
         LDA BUF1,X
         CPY#2
         BCC TAKEP2
         CMP#1
         BCC TAKES4
         CMP#3
         BCS TAKES4
         STA FMDRV
         STA DEFDRV
         STA RWDRV
TAKEP2   RTS

