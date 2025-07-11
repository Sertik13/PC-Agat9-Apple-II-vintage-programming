
************************************************
*                                              *
* УСТАНОВКА СИСТЕМЫ "ДИСПЕТЧЕР" В BASIC Agat-9 *
*                                              *
* (устанавливает в BASIC команду "DR=" вместо  *
* команды "GR=", которая не работает и систему *
* на $F700                                     *
************************************************
                
IOSAVE EQU $FF4B
IOREST EQU $FF40

       ORG $7000
 
       JSR IOSAVE
STAY   LDX $C160
       STA $C166
       STA $C083
       LDA #$44     установить "d" в "g" (DR= вместо GR=)
       STA $D0ED
       STA $C08B
       LDY #$C      установить подпрограмму DR=
STAY1  LDA DRCOM,Y
       STA $DC67,Y
       DEY
       BPL STAY1
       STA $C083
       STA $C100,X
       LDX $C170
       STA $C177
       LDY#0        установить "ДИСПЕТЧЕР"
STAY2  LDA MANBEG,Y
       STA DISP,Y
       INY
       BNE STAY2
       STA $C100,X
       JMP IOREST
       
DRCOM  JMP $E1AC
       JSR $E4CD
       CPX #11      
       BCS DRCOM
       JMP INWORK
       
MANBEG

       CHN MANDRIVE.ASM

