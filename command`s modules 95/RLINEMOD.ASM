
*---------------------------*
* оператор "БЕГУЩАЯ СТРОКА" *
*---------------------------*

RLINE      DFB:00100000
           DW  BIT_TEST
           DFB 1,5
           DFB:00000000,:00000001
           ASC "RLINE A${,X,Y,dX,Speed}"
           DFB 0

; параметры:
; ----------
;
; A$    - текстовое выражение в формате интерпретатора
; X     - левый отступ от начала экрана
; Y     - верхний отступ
; dX    - длина выводимой строки
; Speed - скорость вывода текста строки
;

RL1      EQU $C9     указатель буфера
RL2      EQU $CA
RL4      EQU $01     текущий цвет
RL5      EQU $02
RL6      EQU $2A
RL7      EQU $2B
RL8      EQU $4E     цвет больших букв
RL10     EQU $4F     цвет малых букв
RL9      EQU $07
LINEBUF  EQU $1FF    буфер ($200)
         
         LDA#0
         JSR RPARAM
         STA $5F
         STY $5E
         TXA
         BEQ RLINE4     имя нулевое
         CMP#251
         BCS RLINE47    строка длинна (макс. длина 250)
         LDY #0
RLINE1   LDA ($5E),Y    взять N-ый символ имени начиная
         EOR #$80       с первого после ","
         STA LINEBUF+5,Y
         INY
         DEX
         BNE RLINE1
         TXA
         STA LINEBUF+5,Y
         LDX XBUF1
         CPX#1
         BNE RLINE6
         JMP RLINE17

RLINE4   LDX#46
         DFB $2C
RLINE47  LDX#130
         JMP BASERR

RLINE6   JSR CH.PARH

RLINE8   LDA BUF1+1           X
         BIT $32
         BMI RLINE9
         ASL A
         STA BUF1+1
RLINE9   JSR RLINE15
         BCS RLINE4
         LDX XBUF1
         CPX#4
         BCC RLINE11
         LDA BUF1+3           Dx
         BIT $32
         BMI RLINE10
         ASL A
         STA BUF1+3
RLINE10  BEQ RLINE4
         BNE RLINE14
RLINE11  BIT $32
         BPL RLINE12
         LDA STRDX
         DFB $2C
RLINE12  LDA #62
         SEC
         SBC BUF1+1
RLINE13  STA BUF1+3
         BEQ RLINE4
RLINE14  LDA BUF1+1
         CLC
         ADC BUF1+3
         JSR RLINE15
         BCS RLINE4
         LDA BUF1+2           Y
         JSR RLINE16
         BCS RLINE4
         LDA BUF1+4           Speed
         CPX#4
         BCS RLINE45
         LDA STRSP
RLINE45  EOR #$FF   
         STA BUF1+4
         JMP RLINE18

RLINE15  TAY
         CPY #64
         RTS
RLINE16  TAY
         CPY #32
         RTS

RLINE17  JSR RLINE43
RLINE18  JSR RLINE46
         LDA #>LINEBUF
         STA RLINE27+1
         LDA #<LINEBUF
         STA RLINE27+2

RLINE19  LDX BUF1+1
RLINE20  LDY BUF1+2
         JSR RLINE42
         CLC 
         LDA RL1
         STA RL6
RLINE21  ADC BUF1+3
         STA RL1
         LDA RL2
         STA RL7
         LDY #0
         LDA BUF1+4      скорость движения строки
         JSR WAIT
RLINE22  INY
         BIT $32
         BMI RLINE23
         INY 
RLINE23  LDA (RL6),Y
         DEY 
         BIT $32
         BMI RLINE24
         DEY 
RLINE24  STA (RL6),Y    

         INY 
         CPY BUF1+3             
         BCC RLINE22
RLINE25  INC RLINE27+1
         BNE RLINE26
         INC RLINE27+2
RLINE26  LDA $C000 
         BMI RLINE29
RLINE27  LDA $1000        <--- взять новый байт
         BEQ RLINE28
         CMP #$8D
         BEQ RLINE29
         JSR RLINE30
         BIT RL9
         BMI RLINE25
         JMP RLINE19
RLINE28  LDA #$A0
         JSR RLINE30
         JMP RLINE18

RLINE29  LDA #$A0
         JSR RLINE30
         STA $C010
         RTS

RLINE30  LDY #0
         STY RL9  
         PHA
         JSR RLINE32  установка  цветов
         PLA
         STY RL4   
         LDY #$00
         STA (RL1),Y

;        TAX          зарезервировано для SPEAKER.DRV

         INY 
         BIT $32     
         BMI RLINE31
         LDA RL4
         STA (RL1),Y

;RLINE31 JSR SPEAKINT зарезервировано для SPEAKER.DRV

RLINE31  RTS 

RLINE32  PHA 
         CMP #$A0
         BCS RLINE35  
         PLA          
         BMI RLINE33
         LDY RL10
         RTS
RLINE33  LDY #$FF
         STY RL9
         CMP #$90     
         BCS RLINE34  
         LDX RL10
         JSR RLINE36
         STA RL10
         PLA
         PLA
         PLA    
         RTS

RLINE34  SEC
         SBC #$10
         LDX RL8
         JSR RLINE36
         STA RL8
         PLA
         PLA
RLINE35  PLA
         LDY RL8
         RTS
       
RLINE36  CMP #$88
         BCC RLINE40
         CMP #$88
         BEQ RLINE38
         CMP #$89
         BEQ RLINE39
         CMP #$8A 
         BEQ RLINE37
         TXA
         RTS
                           
RLINE37  TXA     5 3
         AND #:11010111   мерцание (FLASH)
         ORA #:00001000
         RTS
RLINE38  TXA    
         AND #:11010111   инверсия (INVERSE)
         RTS
RLINE39  TXA              
         ORA #:00101000   норма (NORMAL)
         RTS

RLINE40  SEC
         SBC #$80
         STA RLINE41+1
         TXA
         AND #$F8
RLINE41  ORA #0
         RTS

RLINE42  PHA 
         STY RL2
         LDA #$00
         STA RL1
         LSR RL2
         ROR RL1
         LSR RL2
         ROR RL1
         LDA $19
         AND#:11111000
         ADC RL2
         STA RL2
         TXA 
         CLC 
         ADC RL1
         STA RL1
         PLA 
         RTS 

RTABL    DFB $93,$99,$86,$89

STRX     DFB $00
STRY     DFB $00
STRDX    DFB $3F
STRSP    DFB 50 

RLINE43  LDA STRX   
         STA BUF1+1
         LDA STRY
         STA BUF1+2
         LDY STRDX 
         BIT $32
         BMI RLINE44
         DEY     
RLINE44  STY BUF1+3
         LDA STRSP
         EOR #$FF
         STA BUF1+4
         RTS 

RLINE46  LDX#3
         LDA RTABL,X
         STA LINEBUF+1,X
         DEX
         BPL RLINE46+2
         RTS
