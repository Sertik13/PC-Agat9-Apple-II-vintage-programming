

*=====================================*
* ДОПОЛНИТЕЛЬНЫЕ МЕТКИ ДРАЙВЕРА "KEY" *
*=====================================*
  
KOLVSIM      EQU 21    кол-во символов в одной клавише+1
KOLVKEY      EQU 15    количество клавиш в таблице
KEYFLAG      EQU $E000
BUFKEY       EQU $E001
KEYEND       EQU KOLVKEY*KOLVSIM+BUFKEY
BKEYL        EQU $4E
BKEYH        EQU $4F
BKEY1L       EQU $2A
BKEY1H       EQU $2B
CONTROLKEY   EQU $02                   

