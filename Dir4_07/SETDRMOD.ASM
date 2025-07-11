
          LST ON

*---------------------------------------*
*     <C> Friends' software 1995        *
* СТАНДАРТНЫЙ МОДУЛЬ УСТАНОВКИ ДРАЙВЕРА *
*      только для BASIC 'MASTER'95      *
*            версия 15.08.95            *
*---------------------------------------*

          LST OFF

SETDR     JSR IOSAVE     сохранить регистры
          LDA BASFLAG
          CMP#$AA        драйвер работает только
          BNE SETERR     в BASIC-MASTER'95
          LDX #$4C       установить код JMP
          STX VEKTPROC   в $3F5
          STX VEKTFUN    в $3E8
          LDA BEGDRIVE+1 начало поля точек входа
          LDY BEGDRIVE   интерпретации

          DO ATRIBDR&:00100000 Драйвер работает с 
;                              "Диспетчером"?
          JSR INSET      да, установиться в системе
          BCS SETEXIT    не активизироваться

          ELSE           нет, тогда самостоятельно

          STA VEKTPROC+2 активизировать & как процедуру
          STY VEKTPROC+1
          STA RNDH
          STY RNDL       активизировать & как функцию
          LDA#3
          CLC
          ADC RNDL
          STA VEKTFUN+1
          LDA#0
          ADC RNDH
          STA VEKTFUN+2

          FIN

          DO ATRIBDR&:01000000 Есть подпрограмма
;                              инициализации?
          JSR SETINIT
          JMP SETDR2           Да, обратиться к ней
SETINIT   JMP (INITDR)

          FIN

          DO ATRIBDR&:00001000    Есть заставка?

SETDR2    JSR OUTHELP    есть, вывести ее

          FIN

SETEXIT   JMP IOREST     восстановить вектора и выйти


*-------------------------------------*
* Обработка ошибки установки драйвера *
*-------------------------------------*

SETERR   LDY ALIN+1
         INY
         BEQ CONDIAL
         LDY PROMPT
         CPY #$5D
         BEQ CONDIAL
         JMP SYSERR

CONDIAL  LDX#0
         LDA CONERR,X
         PHA
         ORA#$80
         JSR COUT
         INX
         PLA
         BPL CONDIAL+2
         JMP (PWARM)

CONERR   DFB $0D,$1D,$07,$0D,$1D
         ASC "ошибка"
         DFB $20
         ASC "установки"
         DFB $0D,$1D,$8D


*---------------------------*
* ВЫВЕСТИ ЗАСТАВКУ ДРАЙВЕРА *
*---------------------------*

; адрес заставки должен лежать в 3-4 атрибутах
; драйвера
; заставка не длиннее 255 байт, последний байт 0


          DO ATRIBDR&:00001000

OUTHELP   LDX ALIN+1
          INX
          BEQ OUTHELP0
          LDX PROMPT
          CPX #'}
          BNE OUTHELP3
OUTHELP0  LDA #$8D
          JSR COUT1
          LDA TEXTHELP+1 
          LDY TEXTHELP  
          STA OUTHELP1+2
          STY OUTHELP1+1
          LDX #0
OUTHELP1  LDA $1000,X
          BEQ OUTHELP3
          CMP #$8D
          BEQ OUTHELP2
          JSR $FC0E
          INX
          BNE OUTHELP1
OUTHELP3  RTS
OUTHELP2  JSR COUT1
          INX
          BNE OUTHELP1

          FIN

