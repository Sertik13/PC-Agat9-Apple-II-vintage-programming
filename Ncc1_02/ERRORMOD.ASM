
*--------------------------------------*
* УНИВЕРСАЛЬНАЯ ПОДПРОГРАММА ОБРАБОТКИ *
*               ОШИБОК                 *
*--------------------------------------*


;-------------------------------------------------------!
; DCERR                                                 !
; -----                                                 !
; ВХОД: A,Y - адрес сообщения об ошибке (в DCI)         !
;       X   - желаемый код для $DE                      !
;                                                       !
; DCEXIT                                                !
; -------                                               !
; ВХОД: A=3, C set DCERR                                !
;                                                       !
;-------------------------------------------------------!
DCERR    STX RNDL
         BIT ERRFLAG
         BMI DCERR2
DCERR1   PHA 
         TYA
         PHA
         LDA #<ERR0
         LDY #>ERR0
         JSR PRERR
         PLA
         TAY
         PLA
         JSR PRERR
         JSR CLREOP
         JSR CROUT
DCERR2   JSR DIALOG
DCERR3   LDX RNDL
         LDA#3
         RTS
PRERR    STA $CA 
         STY $C9 
         JSR CLREOP
         LDY#0
PRERR1   LDA ($C9),Y
         PHA
         ORA#$80
         JSR COUT
         INY
         PLA
         BPL PRERR1
         RTS
;---------------------------------------------------------
DCEXIT   BCC DCEXIT1 
         JMP (PERR)
DCEXIT1  JMP (PWARM)
;---------------------------------------------------------

ERR0     DFB $0D,$07,$8D

