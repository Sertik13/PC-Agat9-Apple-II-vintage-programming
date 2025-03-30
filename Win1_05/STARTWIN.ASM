
 LST ON

*--------------------------------*
* СТАРТОВЫЙ ФАЙЛ СБОРКИ ДРАЙВЕРА *
* "WIN 1.05"  Serkov S.V.        *
* for BASIC 'MASTER' only        *
*--------------------------------*

 LST OFF


 CHN ALLDEFIN.ASM  ; файл общих меток


ATRIBDR    EQU :00111110 ; константа сборки драйвера

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
TEXTHELP   DW WINTXT     ; адрес заставки драйвера
           DFB @44
           DFB 4         ; уникальный номер драйвера

 CHN SETDRMOD.ASM  ; модуль установки драйвера
 CHN AREAMODL.ASM  ; поле точек входа в интерпретатор
 CHN INTBAS95.ASM  ; интерпретатор драйвера
 CHN ALLSUBRS.ASM  ; общие подпрограммы  

*----------------
NEXTOPER
*----------------

 CHN WINMODL2.ASM  ; "оконный модуль"
 CHN EXIT_OPR.ASM  ; оператор "EXIT"
 CHN TEXTWIND.ASM  ; заставка

;END
