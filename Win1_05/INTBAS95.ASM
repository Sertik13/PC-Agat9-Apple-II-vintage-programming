
          LST ON

*==============================*
* <C> BIOCOMPUTER and FRIENDS' *
*          SOFTWARE            *
*    ИНТЕРПРЕТАЦИЯ КОМАНДЫ     *
*      ВЕРСИЯ  15.09.95        *
*   для драйверов под BASIC    *
*        'Master'95            *
*   [ процедуры и функции ]    *
*------------------------------*
*   Волков И.М. Серков С.В.    *
*==============================*

          LST OFF

; Знаки интерпретации

COLON    EQU $3A         двоеточие
COMMA    EQU $2C         запятая
EQALITY  EQU $D0         равно
OBRACKET EQU $28         открывающая скобка
CBRACKET EQU $29         закрывающая скобка
LINEND   EQU $00         конец строки
QUOTAT   EQU $22         кавычка


*=============================*
* НАЧАЛО ОБСЛУЖИВАНИЯ КОМАНДЫ *
*=============================*


PROC     LDA#$00       пришла процедура
         DFB $2C
FUNC     LDA#$80       пришла функция
         STA VEKTFLAG
         LDY#12        Обнулить управляющие флаги команды,
         LDA#0         флаг количества параметров
DRVINT   STA FUNFLAG,Y и карты параметров
         DEY
         BPL DRVINT
INTBAS   JSR RDOPER    Считать команду в буфер
         BCS INTERR12
         JSR SEARCH    Поиск имени команды
         BCS INTERR12  имя не найдено 
         JSR SETFLAG   Установить флаги команды
         JSR COMCHECK  Проверить допустимость команды
INTERR12 BCS BASERR12
         JSR COMDIR    Проверить режим команды
         BCS BASERR112 ошибка "НЕ В ДИАЛОГЕ"
         JSR GETCHR
         BEQ EXEC      Если после имени ноль или двоеточие
         CMP #COLON    то исполнить команду немедленно
         BEQ EXEC
         BIT FUNFLAG
         BPL INTOPER3  Не функция
         CMP #OBRACKET Если функция с параметрами, то
         BEQ INTOPER2  должна быть открывающая скобка
         BNE EXEC      Иначе-функция без параметров.
INTOPER2 JSR GETCHR
INTOPER3 LDA WORKSIM   Если установлен флаг нестандартной
         BNE COMSTART  интерпретации то сразу исполнить. 
         JSR GETPARAM  Иначе -  считать параметры
         BCS BASERR57
EXEC     JSR CHECKPAR  Проверить количество входн. парам.
         BCS PARERROR
COMSTART JSR COMAND    Исполнить команду
         BIT FUNFLAG   Это функция?
         BPL INTEND    Нет, это оператор
FUNRET   STX LONG      Сложить результат функции 
         STA ZBH       в сумматор INTBAS95
         STY ZBL
         LDA#$00       A=0
         STA $12       флаг числа (целое)
         ROL FUNTYPE   сдвинуть тип результата функции
         BCC FNUMBER1  C=0 (результат "число") 
         LDA#$FF       установить флаг результата функции
FNUMBER1 STA $11       число/строка для Бейсика (0 или FF)
         LDA ZBH
         LDY ZBL
         BCC FNUMBER2
         TXA           X=LONG
         JSR $E3F0     Выделить память под строку
         LDA ZBH
         LDY ZBL
         STA $5F
         STY $5E
         LDX LONG
         BEQ PUTSTEK   ! Ошибка исправлена 03.02.97 !
         LDY#0
FSTRING1 LDA ($5E),Y   Перенести строку в память Бейсика
         STA ($9E),Y
         INY
         DEX
         BNE FSTRING1
PUTSTEK  JMP $E43D     Положить указатель на стек данных
INTEND   RTS           (для строк)
FNUMBER2 JMP $E305     Положить результат на стек данных
;                      (для чисел)

COMAND   JMP (OPER)

PARERROR  TAY
          BNE BASERR57

BASERR35  LDX#35      - мало данных
          DFB $2C
BASERR12  LDX#12      - синтаксическая ошибка
          DFB $2C
BASERR112 LDX#112     - не в диалоге
          DFB $2C
BASERR46  LDX#46      - ошибочное значение
          DFB $2C
BASERR57  LDX#57      - переполнение


BASERR   DO ATRIBDR&:10000000

         JMP DRBASEXIT  для драйверов в банках

         ELSE

         JMP SYSERR     для ОЗУ-драйверов

         FIN


*===================*
* СЧИТАТЬ ПАРАМЕТРЫ *
*===================*

GETP1    JSR GETCHR   Перейти к следующему символу
GETPARAM LDX XBUF1
         CPX #16      Максимально разрешено 16 параметров
         BCS QUITPAR  Ошибка: Переполнение буфера
         BIT PARFLAG  Пропуск параметров по "," разрешен?
         BPL GETP2    нет
         CMP#COMMA
         BNE GETP2
         LDA#0        По запятой взять нулевое значение
         TAY          параметра
         TAX
         CLC          C=0 (параметр был пропущен по ",")
         BEQ GETP3    (JMP)
GETP2    LSR KART2    Сдвинуть карту типов параметров и 
         ROR KART1    выдвинуть признак параметра в C
         JSR INPAR    Считать параметр
         SEC          C=1 (параметр считан)
GETP3    ROL BKART1   Отметить признак параметра в карте
         ROL BKART2   наличия параметров
         PHA
         TXA
         LDX XBUF1    Записать параметр в буфер
         STA LBUF,X   длины
         TYA
         STA BUF1,X
         PLA
         STA BUF11,X
         INX          Увеличить счетчик параметров
         STX XBUF1
         JSR GETC1    Текущий сивол - "0" (конец строки)?
         BEQ GETP5    Да, закончить считывание параметров
         CMP #COLON   Или это двоеточие?
         BEQ GETP5    Если так, то тоже закончить
         CMP #COMMA   Это запятая?
         BEQ GETP1    Да, значит есть еще параметры
         CMP#CBRACKET Это закрывающая скобка?
         BNE BASERR12 Нет, недопустимый символ
         BIT FUNFLAG  Да, это скобка, а команда-функция?
GETP4    BPL BASERR12 Нет, процедура (скобка не допустима)
         JSR GETCHR   Пропустить закрывающую скобку
         JMP EXITOK2  (для функций) и выйти
GETP5    BIT FUNFLAG
GETP6    BMI BASERR12
EXITOK2  CLC
QUITPAR  RTS


*============================*
* УНИВЕРСАЛЬНАЯ ПОДПРОГРАММА *
* СЧИТЫВАНИЯ ПАРАМЕТРОВ      *
*============================*

; Вход:  а) C=0  -  требуется число
;        б) C=1  -  требуется строка
;
; Выход: а) C=0, Y,A - число (младший/старший), X=0
;        б) C=1, Y,A - адрес строки, X-длина
;

INPAR    PHP
         JSR $DD62
         PLP
         BCC NPUR
SPUR     JSR $E5BC
         TAX
         LDA $5F
         LDY $5E
         BIT $11
         BPL GETP4
         SEC
         RTS
NPUR     BIT $11
         BMI GETP6
         JSR $E712
         CLC
         LDA $51
         LDY $50
         LDX#0
         RTS

*==============================================*
* Проверить допустимость использования команды *
* и разрешить двойное использование для        *
* смешанных команд (VARIFLAG=1)                *
*==============================================*

COMCHECK LDX VEKTFLAG  флаг команды (процедура/функция)
         LDA VARIFLAG  флаг смешанной команды
         BMI COMCH3    да, это она
         CPX FUNFLAG
         BNE COMCH2
COMCH1   CLC           команда используется в правильной
         DFB @44       записи
COMCH2   SEC           команда на разрешена
         RTS
COMCH3   STX FUNFLAG   VEKTFLAG=FUNFLAG
         BMI COMCH1     (JMP)

*=====================*
* ПРОВЕРКА КОЛИЧЕСТВА *
* ВХОДНЫХ  ПАРАМЕТРОВ *
*=====================*

CHECKPAR LDY #3          возвращает: C=0 - O'KEY
         LDA XBUF1                   
         CMP (MEM),Y                 C=1 - ERROR 
         BCC CHECKP1                 A=0 - мало данных
         INY                         A>0 - переполнение
         CMP (MEM),Y
         BCC EXITOK2
         BEQ EXITOK2
         DFB $2C
CHECKP1  LDA#$00
         SEC
         RTS

*=====================*
* ВЗЯТЬ СИМВОЛ ИЗ BAS *
*=====================*

GETCHR   INC BAS
         BNE GETC1
         INC BAS+1
GETC1    LDY #0
         LDA (BAS),Y
         RTS

*==========================*
* УСТАНОВИТЬ ФЛАГИ КОМАНДЫ *
*==========================*

SETFLAG  LDY#0          разбор битовой карты
         LDA (MEM),Y    атрибута команды
SETFLG1  ASL A
         BCS SETFLG3
SETFLG2  INY
         CPY#8
         BNE SETFLG1
         RTS

SETFLG3  PHA            при установленном бите в
         LDA#$80        соответствующий ему флаг
         STA FUNFLAG,Y  установливается $80
         PLA
         JMP SETFLG2

*=========================*
* ПРОВЕРКА РЕЖИМА КОМАНДЫ *
*=========================*

COMDIR   JSR DIALOG
         BCS COMDIR1
         LDA COMFLAG
         ASL A
         RTS

COMDIR1  CLC
         RTS


*=================*
* ПОИСК ОПЕРАТОРА *
*=================*

SEARCH   LDA #<MODULE   Начать поиск команды с метки
         LDX #>MODULE   MODULE
SEARCH1  STA MEM+1
         STX MEM
         LDY #7
         LDX #$FF
SEARCH2  LDA (MEM),Y
         BEQ SEARCH3
         CMP #$A0       Команда отделена от комментария
         BEQ SEARCH3    пробелом
         INY
         BNE SEARCH2
SEARCH3  TYA
         SEC
         SBC#8
         STA BCALC
         LDY #6
SEARCH4  INY
         INX
         LDA WORDOP,X   Сравнить имя в буфере
         CMP (MEM),Y    с именем команды в тексте
         BNE SEARCH5    модуля 
         CPX BCALC
         BNE SEARCH4
         INY
         INX
         LDA WORDOP,X
         BEQ SEARCH6
SEARCH5  LDY #1         Имя не то, перейти к проверке
         LDA (MEM),Y    следущей команды
         TAX
         INY
         LDA (MEM),Y
         BNE SEARCH1
EXITERR  SEC            Конец модуля команд,
         RTS            имя команды не найдено

SEARCH6  LDA (MEM),Y
         BEQ SEARCH8    Комментария либо нет либо он
         CMP #$A0       отделен от команды пробелом.
         BNE EXITERR
SEARCH7  INY            пропустить комментарий
         LDA (MEM),Y
         BNE SEARCH7    JMP
SEARCH8  INY
         TYA
         CLC
         ADC MEM        Получить адрес исполняемой
         STA OPER       части команды и поместить
         LDA #0         его в OPER.
         ADC MEM+1
         STA OPER+1
         LDY#5
         LDA (MEM),Y    Установить карту параметров
         STA KART2      команды в KART2 (9-16 параметры) и
         STA TKART2     KART1 (1-8)              
         INY            
         LDA (MEM),Y    а также в TKART2 и TKART1
         STA KART1      (для подпрограмм команды)
         STA TKART1
EXITOK1  CLC
         RTS

*==================*
* СЧИТАТЬ ОПЕРАТОР *
*==================*

RDOPER   LDX #0
RDOP1    JSR GETCHR
         CMP #QUOTAT
         BEQ RDOP2
         ORA #$80       Имя команды состоит только
         STA WORDOP,X   из заглавных букв
         INX
         LDA #0
         STA WORDOP,X
         CPX #$F        Имя команды не длиннее 15-ти
         BCC RDOP1      символов включительно.
         RTS

RDOP2    TXA
         BNE EXITOK1
         RTS
              
*-----------------------------------------*
* РАБОЧАЯ ОБЛАСТЬ ИНТЕРПРЕТАТОРА ДРАЙВЕРА *
*-----------------------------------------*

         DSECT
           
         ORG $1920


*----- БУФЕР ДЛЯ ИМЕНИ КОМАНДЫ ------*

WORDOP   DS  16


*----- СУММАТОР ДЛЯ РЕЗУЛЬТАТА ФУНКЦИИ -----*

LONG     DS 1  длина текста или 0
ZBL      DS 1  адрес текста или значение целого числа
ZBH      DS 1  младший/старший

*====== ФЛАГ ВЕКТОРА =======*

VEKTFLAG DS 1       ;$00-процедура, $80-функция


*------ ФЛАГИ КОМАНДЫ ------*

FUNFLAG  DS  1      признак функции
WORKSIM  DS  1      признак нестандартной интерпретации
COMFLAG  DS  1      режим команды
FUNTYPE  DS  1      тип результата функции (для функций)
LISTFLG  DS  1      флаг скрытой команды (для &"LIST")
PARFLAG  DS  1      признак пропуска параметров по запятой
VARIFLAG DS  1      признак смешанной команды
         DS  1      резерв

*-------- БИТОВАЯ КАРТА НАЛИЧИЯ ПАРАМЕТРОВ --------*

; "1" - параметр был считан
; "0" - параметр не был считан ( команда имеет меньше па-
;       раметров или он был пропущен по ","


BKART2   DS  1      9-16
BKART1   DS  1      1-8  параметры


*------- БИТОВАЯ КАРТА ТИПОВ ПАРАМЕТРОВ ---------*

; "1" - строка
; "0" - число

TKART2   DS  1      9-16
TKART1   DS  1      1-8  параметры



*------ БУФЕРЫ ДЛЯ НАКОПЛЕНИЯ ПАРАМЕТРОВ ------*

XBUF1    DS  1      количество найденных параметров
LBUF     DS  16     буфер для длин (для строковых)
BUF1     DS  16     буфер для младших байтов параметров
BUF11    DS  16     буфер для старших байтов параметров
;                   (или адресов для строковых)

          DEND


MODULE

;--------------------------------------------------------
;         ОПИСАНИЕ ФОРМАТА КОМАНД МОДУЛЯ
;--------------------------------------------------------
;
; Модуль должен начинаться с метки NEXTOPER и располагать-
; ся после команды "LIST". Его описание включает:
;    
; ПОЛЕ КОМАНДЫ:
; -  1 байт - атрибут команды в битах.
;
;  ! номер !               значение
;  !-------!--------------------------------------------
;  !   7   !  "1"-функция, "0"-процедура
;  !   6   !  "1"-нестандартная интерпретация параметров,
;  !       !  "0"-обычная
;  !   5   !  "1"-запрещена в режиме диалога, "0"-нет 
;  !   4   !  "1"-результат функции-строка, "0"-число 
;  !   3   !  "1"-команда не просматривается по &"LIST",
;  !       !  "0"-открытая команда
;  !   2   !  "1"-разрешен пропуск параметров по ","
;  !       !  "0"-запрещен
;  !   1   !  "1"-смешанная команда, "0"-тип команды
;  !       !      установлен битом 7
;  !   0   !  резерв (в наст. версии не используется)
;
; -  2 байта ссылка на следующий оператор
;    (если следующего оператора нет то 0,0)
; -  2 байта минимальное и максимальное количество вход-
;    ных параметров (если их нет, то 0,0), допустимо 16.
; -  2 байта битовая карта параметров команды 
;    (от 16-го к 1-ому); "1"-строка, "0"-число
; -  Имя оператора, которое не содержит пробелов, записано
;    заглавными буквами и имеет длину не более 15-ти
;    символов.
; -  После имени оператора, может идти комментарий, отде-
;    ленный от команды пробелом.
; -  Нулевой байт (0) - признак конца поля команды
;
; Функция должна вернуть:
; -----------------------
;  X - длина текста (для числовых функций не используется)
;  A,Y - адрес хранения текста в ОП или значение целого
;        числа в формате младший/старший.
; Возвращаемый текст должен быть в обратном коде (EOR#$80)
;
; Например:
;
;    DFB $00                      Простая процедура.
;    DW  NEXTFUN                  все параметры-числа
;    DFB $04,$05
;    DFB 0,0
;    ASC "OPER.ONE vt,ht,xl,yl,color"
;    DFB 0
;
;NEXTFUN DFB:10100000             Функция, запрещенная в
;        DW NEXTOPER2             режиме диалога, ее ре-
;        DFB $00,$03              зультат-число.
;        DFB:00000000,00000100    Параметры: два первых-
;        ASC "FUN.ONE x1,y1,STR$" числа, третий-строка. 
;        DFB $00
;
;---------------------------------------------------------

*------------------------------*
*      процедура "LIST"        *
*------------------------------*

; Выводит список команд драйвера на экран
; пропуская "скрытые команды" (LISTFLG=1)

LIST     DFB:00001000
         DW  NEXTOPER
         DFB 0,0,0,0
         ASC "LIST"
         DFB 0


LST0     LDA #0
         STA BCALC
         JSR LST7 
         LDA DGW
         SEC
         SBC UGW
         SEC  
         SBC#1
         STA DCALC
         LDX #>MODULE
         LDA #<MODULE
LST1     STX MEM
         STA MEM+1
         LDY#0
         LDA (MEM),Y
         AND#:00001000
         BNE LST5
         LDY #7 
LST2     LDA (MEM),Y
         BEQ LST3
         JSR COUT1
         INY
         BNE LST2
LST3     JSR LST7
         LDY #0
         INC BCALC
         LDA BCALC
         CMP DCALC
         BCC LST5
LST6     LDA $C000
         BPL LST6
         STY BCALC
LST5     LDA $C000
         CMP #$9B
         BEQ LST4
         INY
         LDA (MEM),Y
         TAX
         INY
         JSR LST4
         LDA (MEM),Y
         BNE LST1
LST4     STA $C010
         RTS
LST7     LDA#$8D
         JMP COUT1

