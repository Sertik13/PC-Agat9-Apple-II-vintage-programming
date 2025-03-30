
           LST ON

*=-=-=-=-=-=-=-=-=-=-=-=*
* DIRECTORY TREE DRIVER *
* version 4.07 23.10.95 *
* для BASIC-MASTER'95   *
* START FILE            *
*=-=-=-=-=-=-=-=-=-=-=-=*

          LST OFF

; вызовы модулей
                        
           CHN ALLDEFIN.ASM  файл общих меток
           CHN DIRDEF47.ASM  дополнительные метки "DIR"
        
           ORG $5DF8

ATRIBDR    EQU:11101100  ; гл. константа ассемблирования

           DFB @44
           DFB ATRIBDR   ; главный аттрибут драйвера
           DFB $2C                            
BEGDRIVE   DW AREA       ; адрес обработчика драйвера
           DFB $2C                              
INITDR     DW DIRINIT    ; адрес программы инициализации
           DFB $2C
TEXTHELP   DW HELPIN     ; адрес заставки драйвера

           CHN SETDRMOD.ASM  модуль установки драйвера
           CHN DIRHLP47.ASM  заставка драйвера 
           CHN DIRINI47.ASM  инициализация драйвера
           CHN AREAMODL.ASM  поле точек входа в драйвер
                                       
           ORG $A000   

           CHN INTBAS95.ASM  интерпретатор драйвера
           CHN DIRSUB47.ASM  подпрограммы "DIR"
           CHN ALLSUBRS.ASM  общие подпрограммы 
           
*---------------------
NEXTOPER              
*---------------------

           CHN DIRMOD47.ASM  сам "DIR"
; END                                 


