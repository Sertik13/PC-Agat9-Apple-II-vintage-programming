
  LST ON

*-=-=-=-=-=-=-=-=-=-=-=-=-=-=*
* DRIVER OF THE PROGRAMMABLE *
* FUNCTIONAL KEYBOARD 1.03   *
* by Sergej Serkov 04.11.95. *
* for BASIC 'MASTER'95 only  *
* СТАРТОВЫЙ ФАЙЛ             *
*-=-=-=-=-=-=-=-=-=-=-=-=-=-=*

 LST OFF

    CHN ALLDEFIN.ASM  ; файл общих меток
    CHN KEYDEF10.ASM  ; дополнительные метки KEY


ATRIBDR    EQU :01111100 ; константа сборки драйвера

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
INITDR     DW KEYINIT    ; адрес программы инициализации
           DFB $2C
TEXTHELP   DW KEYHELP    ; адрес заставки драйвера
           DFB @44
           DFB 2         ; уникальный номер драйвера

 CHN SETDRMOD.ASM  ; модуль установки драйвера
 CHN AREAMODL.ASM  ; поле точек входа в интерпретатор
 CHN INTBAS95.ASM  ; интерпретатор драйвера
 CHN ALLSUBRS.ASM  ; общие подпрограммы

*----------------
NEXTOPER
*----------------

  CHN KEYMODUL.ASM  ; модуль ПФК

  CHN KEYHELP1.ASM  ; заставка драйвера
  CHN KEYINIT1.ASM  ; инициализация драйвера
;

;END
