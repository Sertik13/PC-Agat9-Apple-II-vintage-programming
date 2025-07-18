
*==================*
* оператор "RESET" *
*==================*

; процедура RESET переустанавливает вектора сброса
; системы DOS 3.3 и Бейсик так, что после УПР-СБР
; система переходит к выполнению команды "RUN"
; (то есть запуска Бейсик-программы.
; &"RESET"1 выполняет указанные выше действия
; &"RESET"0 возвращает вектора в исходное состояние


RESET    DFB:00001000
         DW TURBO
         DFB 1,1
         DFB 0,0
         ASC "RESET n"
         DFB 0

RESET1   JSR CH.PARH      проверить параметр
         LDA BUF1
         BEQ RESOFF       если он равен 0, то выключить
         CMP#2
         BCS RESERR46     2 и более нельзя
         LDA RESFLAG      параметр равен 1-установить
         BNE RESOFF1      сброс на BASIC "RUN"
RESON    LDX $3F3         (если RESFLAG=1, то RESET уже
         LDY $3F2          установлен)
         STX RESH
         STY RESL
         INC RESFLAG
         LDY#>RESPROC
         LDA#<RESPROC
RESON1   STY $3F2
         STA $3F3
         EOR#$A5
         STA $3F4
         RTS
RESOFF   LDA RESFLAG      если RESFLAG=0, то 
         BEQ RESOFF1      RESET не был установлен и
         LDA RESH         выключать нечего
         LDY RESL
         JSR RESON1
         LDA#0
         STA RESFLAG
RESOFF1  RTS 

RESERR46 JMP BASERR46

RESL     DS 1
RESH     DS 1
RESFLAG  DS 1              флаг 

RESPROC  LDA#$44           процедура сброса на "RUN"
         STA $E8
         STA $56C
         JSR $3CB
         JSR $1889
         STA $C080
         LDX $56C
         STA $C100,X
         STA $C110,X
         JSR $D699
         JSR $1841
         JSR $D68B
         LDA#$00
         STA $D8
         STA $33
         JSR $184A
         JMP $D4FA
