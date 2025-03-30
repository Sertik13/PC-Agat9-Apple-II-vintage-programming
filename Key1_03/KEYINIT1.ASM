
***********************************
*                                 *
* ИНИЦИАЛИЗАЦИЯ ДРАЙВЕРА KEY 1.0  *
*                                 *
***********************************


*=================================*
* ИНИЦИАЛИЗАЦИЯ БУФЕРА КЛАВИАТУРЫ *
*=================================*

KEYINIT   JSR KBNKON 
          LDA KEYFLAG
          PHA
          JSR KBNKOFF
          PLA
          CMP #CONTROLKEY 
          BEQ INKEYBUF3     клавиатурный набор уже там
          LDA #<BUFKEY            
          LDY #>BUFKEY
          STA BKEYH
          STY BKEYL
          LDY#0
INKEYBUF0 TYA
          JSR KBNKON
          JSR KEYA
          STA (BKEYL),Y
          JSR KBNKOFF
          INC BKEYL
          BNE INKEYBUF2
          INC BKEYH
INKEYBUF2 LDA BKEYH 
          CMP #<KEYEND
          BCC INKEYBUF0
          LDA BKEYL
          CMP #>KEYEND+1
          BNE INKEYBUF0
          JSR KBNKON
          LDA#0    
          STA KEYFLAG      буфер клавиатуры пуст (=0)
          JSR KBNKOFF
INKEYBUF3 RTS
