

*----------------------------------------*
* ПОЛЕ ТОЧЕК ВХОДА В ОБРАБОТЧИК ДРАЙВЕРА *
*----------------------------------------*

;                    76543210
AREA     DO ATRIBDR&:00000100  Драйвер имеет процедуры?

         JMP PROC              Да, записать вектор

         ELSE

         JMP SERRJ12           Нет, вектор указывает
;                              на "СИНТ.ОШ"
         FIN

         DO ATRIBDR&:00000010  Драйвер имеет функции?

         JMP FUNC              Да, записать вектор

         ELSE

         JMP SERRJ46           Нет, вектор указывает
;                              на "ОШИБОЧНОЕ ЗНАЧЕНИЕ"
         FIN


