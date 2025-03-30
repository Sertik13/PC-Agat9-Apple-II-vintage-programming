


 LST ON

*--------------------------------*
* СТАРТОВЫЙ ФАЙЛ СБОРКИ ДРАЙВЕРА *
* FORMAT 2.01                    *
* for BASIC 'MASTER'95 only      *
*--------------------------------*

 LST OFF


 CHN ALLDEFIN.ASM  ; файл общих меток


ATRIBDR    EQU :00111100 ; константа сборки драйвера

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
TEXTHELP   DW FRMTXT     ; адрес заставки драйвера
           DFB @44
           DFB 3         ; уникальный номер драйвера

 CHN SETDRMOD.ASM  ; модуль установки драйвера
 CHN AREAMODL.ASM  ; поле точек входа в интерпретатор
 CHN INTBAS95.ASM  ; интерпретатор драйвера
 CHN ALLSUBRS.ASM  ; общие подпрограммы

*----------------
NEXTOPER
*----------------

 CHN FORMTMOD.ASM  ; модуль форматирования TEAC
 CHN EXIT_OPR.ASM  ; оператор "EXIT"
 CHN ERRORMOD.ASM  ; универсальный модуль обработки ошибок
 CHN FORMTTXT.ASM  ; заставка

;END
