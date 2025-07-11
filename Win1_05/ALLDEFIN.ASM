
*================================*
*   <C> Friends' software 1995   *
* МОДУЛЬ ОПРЕДЕЛЕНИЯ ОБЩИХ МЕТОК *
*  только для BASIC 'MASTER'95   *
*        версия 23.10.95         *
*================================*

*--- ЯЧЕЙКИ ZERO PAGE ---* 

LGW      EQU $20
RGW      EQU $21
UGW      EQU $22
DGW      EQU $23
CH       EQU $24
CV       EQU $25
BASL     EQU $28
BASH     EQU $29
CURSOR   EQU $2D
RNDL     EQU $4E
RNDH     EQU $4F
COLOR    EQU $32
BUFS     EQU $D0
SCALC    EQU $C9
ALIN     EQU $75
BAS      EQU $B8
MEM      EQU $C9
OPER     EQU $4E
BCALC    EQU $06
DCALC    EQU $07
KART2    EQU $08
KART1    EQU $09

*--- СЛУЖЕБНЫЕ КОНСТАНТЫ ---*

EXITCODE EQU $DF

*--- КОНСТАНТЫ - ТИПЫ КОНТРОЛЛЕРОВ ---*

CLOCKID  EQU $02
MEMORID  EQU $10
PAPERID  EQU $4B
TEACID   EQU $BD
SHUGID   EQU $F0
NETID    EQU $EA

*--- СЛУЖЕБНЫЕ ЯЧЕЙКИ ДОС, МОНИТОРА  ---*

USERMEM  EQU $56C
ERRFLAG  EQU $D8
PROMPT   EQU $33
STATUS   EQU $48
SEGM     EQU $E8
PERR     EQU $571
PWARM    EQU $575
DEFSLOT  EQU $B813
DEFDRV   EQU $B811
FMSLOT   EQU $BA97
FMDRV    EQU $BA98

*---- СИСТЕМНЫЕ ВЕКТОРА ----*

VEKTPROC EQU $3F5
VEKTFUN  EQU $3E8
VEKTUSR  EQU $0A

*--- ДОС, ПОДПРОГРАММЫ ---*

RWTSGO   EQU $03E3
RWTSGO1  EQU $03D9

*--- БЕЙСИК, ПОДПРОГРАММЫ ---*

BASFLAG  EQU $E006  флаг типа BASICа
SYSERR   EQU $1844
SERRJ12  EQU $E508
SERRJ46  EQU $E1AC

*--- ПОДПРОГРАММЫ МОНИТОРА ---*

COUT     EQU $FDE1  вывод символа в A
COUT1    EQU $FDE4  вывод символа в A на экран
COUT2    EQU $FC0E  вывод символа в A на экран без расп.
CLREOL   EQU $FCA5  очистка до конца строки
CLREOP   EQU $FC4B  очистка до конца окна
CROUT    EQU $FD92  перевод строки
PRHEX    EQU $FDD7  печать шестнадцатиричной цифры
PRBYTE   EQU $FDCE  печать байта
PRNTAX   EQU $F93C  печать A и X
PRBLNK   EQU $FF5A  печать X пробелов
PRBLNK2  EQU $FF5C  печать 2 пробелов
SWSCR    EQU $F800  включить экран (X-тип реж. A-номер)
RDCHAR   EQU $FB74  ввод с редактированием
BELL1    EQU $FCB8  звук 1 частотой в 1 Кгц 0.1 сек.
KEYIN    EQU $FD11  ввод с клавиатуры в тек. поз. курсора
KEYIN1   EQU $FD16  ввод с клавиатуры, в Y-позиция ввода
IOSAVE   EQU $FF4B  сохранить регистры
IOREST   EQU $FF40  восстановить регистры (кроме S)
WAIT     EQU $FB94  задержка (5*A*A+27*A+26)/2 mks
BASCALC  EQU $FB2B  вычислить адрес начала строки (A-ном.)
XPAGE    EQU $F85E  A-ст.байт активной текстовой страницы
INIT     EQU $FBEF  установить стандартное окно
VTAB     EQU $FC61  вычислить адрес начала окна
SCROLL   EQU $FC77  скроллинг окна на одну строку вверх

*- МЕТКИ ДЛЯ РАБОТЫ С СИСТЕМОЙ "ДИСПЕТЧЕР" -*

INSET    EQU $F700
INEXIT   EQU $F703
INWORK   EQU $F706

*----- ЯЧЕЙКИ ДЛЯ RWTS -----*

RWTS     EQU $0557
RWSLOT   EQU $0558
RWDRV    EQU $0559
RWTOM    EQU $055A
RWTREK   EQU $055B
RWSECT   EQU $055C
ACTION   EQU $055D
RWBUFL   EQU $055F
RWBUFH   EQU $0560
RWMODE   EQU $0563
RWERR    EQU $0564
