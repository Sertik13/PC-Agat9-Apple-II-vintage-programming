

 LST ON

*--------------------------------*
* <C> Friends' software 1995     *
* СТАРТОВЫЙ ФАЙЛ СБОРКИ ДРАЙВЕРА *
* MUZ 4.01 под BASIC 'MASTER'95  *
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
TEXTHELP   DW MELTXT     ; адрес заставки драйвера
           DFB @44
           DFB 1         ; уникальный номер драйвера

 CHN SETDRMOD.ASM  ; модуль установки драйвера
 CHN AREAMODL.ASM  ; поле точек входа в интерпретатор
 CHN INTBAS95.ASM  ; интерпретатор драйвера
 CHN ALLSUBRS.ASM  ; общие подпрограммы  

*----------------
NEXTOPER
*----------------

 CHN MUZMODUL.ASM  ; "музыкальный" модуль
 CHN EXIT_OPR.ASM  ; оператор "EXIT"
 CHN MELODTXT.ASM  ; заставка

;END
