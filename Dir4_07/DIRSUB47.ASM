
*============================================*
*   БАЗОВЫЕ ПОДПРОГРАММЫ ВЫВОДА ДЛЯ МОДУЛЯ   *
*                 "DIR"                      *
* (это обязательно! иначе DOS отключит банк) *
*============================================*

DRPRBYTE  PHA
          LSR A
          LSR A
          LSR A
          LSR A
          JSR DRPRHEX1
          PLA
DRPRHEX   AND#$0F
DRPRHEX1  ORA#$B0
          CMP#$BA
          BCC DRCOUT
          ADC#6
          DFB $2C
DRCLREOL  LDA#$9D
          DFB $2C
DRCROUT   LDA#$8D
DRCOUT    JMP SYSCOUT


