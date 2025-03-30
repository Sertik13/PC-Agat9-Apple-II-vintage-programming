

 LST ON

*--------------------------------*
* <C> Friends' software 1995     *
* NCC 1.02 driver 04.11.95 for   *
* SYSTEM BASIC 'MASTER'95 only   *
*--------------------------------*

 LST OFF


 CHN ALLDEFIN.ASM  ; файл общих меток


ATRIBDR    EQU :00110110 ; константа сборки драйвера

    DO ATRIBDR&:00010000

    REL

    FIN

           ORG $4000

           DFB @44
           DFB ATRIBDR   ; главный атрибут драйвера
           DFB $2C                            
BEGDRIVE   DW AREA       ; адрес поля точек входа в
;                        ; обработчик драйвера
           DFB $2C
INITDR     DW 0          ; адрес программы инициализации
           DFB $2C
TEXTHELP   DW 0          ; адрес заставки драйвера
           DFB @44
           DFB 5         ; уникальный номер драйвера

 CHN SETDRMOD.ASM  ; модуль установки драйвера
 CHN AREAMODL.ASM  ; поле точек входа в интерпретатор
 CHN INTBAS95.ASM  ; интерпретатор драйвера
 CHN ALLSUBRS.ASM  ; общие подпрограммы  

*----------------
NEXTOPER
*----------------

 CHN NCCMODUL.ASM  ; модуль работы с ячейкой часов
 CHN CLOCKDRV.ASM  ; драйвер часов Голова А.

 CHN ERRORMOD.ASM  ; модуль обработки ошибок
 CHN EXIT_OPR.ASM  ; оператор "EXIT"

;END
