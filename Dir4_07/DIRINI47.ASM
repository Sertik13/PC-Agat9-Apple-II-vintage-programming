
***********************************
*                                 *
* ИНИЦИАЛИЗАЦИЯ ДРАЙВЕРА DIR 4.7  *
*                                 *
***********************************


*==================*
* ПЕРЕНОС ДРАЙВЕРА *
*==================*


ISET      EQU $2A
OSET      EQU $4E

        
DIRINIT   LDA $C170
          PHA
          STA $C083
          STA $C17D
          LDA #$60
          STA ISET+1
          LDA #$E0
          STA OSET+1
          LDX #9          перенос 9-и секторов
          LDY #0                    
          STY ISET
          STY OSET
MOVED1    LDA (ISET),Y
          STA (OSET),Y
          INY
          BNE MOVED1
          INC ISET+1
          INC OSET+1
          DEX
          BNE MOVED1
          PLA
          TAX
          STA $C100,X
             
*==============================*
* ПЕРЕНОС ОБРАЩЕНИЯ К ДРАЙВЕРУ *
*==============================*

MOVECALL  LDX #$2D
MOVECALL1 LDA DRMOV,X
          STA DRCALL,X
          DEX              
          BPL MOVECALL1
          RTS

*==============================*
* ПОДПРОГРАММА ВЫЗОВА ДРАЙВЕРА *
* ВЫХОДЫ ПО ОШИБКАМ            *
* СИСТЕМНЫЙ ВЫВОД              *
*==============================*

DRMOV     EQU *

          ORG $390   

DRCALL    LDA SEGMDRV   ВЫЗОВ ДРАЙВЕРА &
          STA BANKDRV
          STA DRCALL1+1
          JSR PROC 
DRCALL1   STA $C100
          RTS 
DRBASEXIT JSR DRCALL1   выход по ошибке интерпретатора
          JMP SYSERR
DREXIT    JSR DRCALL1   выход по ошибке драйвера
          BCC DREXIT1 
          JMP (PERR)
DREXIT1   JMP (PWARM)
SYSCOUT   JSR COUT 
DRCALL2   STA BANKDRV
          RTS


