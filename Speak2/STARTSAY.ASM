

 LST ON

*------------------------------*
* <C> Friends' software 1995   *
* СТАРТОВЫЙ ФАЙЛ СБОРКИ        *
* "говорящего" драйвера        *
* СИСТЕМЫ под BASIC 'MASTER'95 *
*------------------------------*

 LST OFF


 CHN ALLDEFIN.ASM  ; файл общих меток


ATRIBDR    EQU :01101100 ; константа сборки драйвера

    DO ATRIBDR&:00010000

    REL

    FIN

           ORG $6610

           DFB @44
           DFB ATRIBDR   ; главный атрибут драйвера
           DFB $2C                            
BEGDRIVE   DW AREA       ; адрес поля точек входа в
;                        ; обработчик драйвера
           DFB $2C
INITDR     DW INITSAY    ; адрес программы инициализации
           DFB $2C
TEXTHELP   DW TEXTSAY    ; адрес заставки драйвера
           DFB @44
           DFB 6         ; уникальный номер драйвера

 CHN SETDRMOD.ASM  ; модуль установки драйвера
 CHN AREAMODL.ASM  ; поле точек входа в интерпретатор
 CHN INTBAS95.ASM  ; интерпретатор драйвера
 CHN ALLSUBRS.ASM  ; общие подпрограммы  

*----------------
NEXTOPER
*----------------
 
 CHN SAYMODUL.ASM  ; оператор "Говорящая строка"
 CHN EXIT_OPR.ASM  ; оператор "EXIT"
 
 CHN INITSAYM.ASM  ; инициализация драйвера 
 CHN TEXTSAYM.ASM  ; заставка               

;END
