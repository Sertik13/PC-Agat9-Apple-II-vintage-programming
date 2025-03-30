*======================================*
*    НАСТРОЙЩИК ПЕРЕМЕЩАЕМЫХ ФАЙЛОВ    *
*    by Serkov S.V.   version 17.07.95    *
*======================================*

; перемещает 3 и 2 байтовые команды, а также псевдокоманды
; DFB и DW. Перемещает также псевдокоманду DDB в отличие
; от версии 15.08.94. Для нее зарезервирован атрибут метки
; $21 (Ассемблер Громова)
       
; ячеики ZERO PAGE   рабочие ячейки "настройщика"

RADR     EQU $06
NAS       EQU $08
SERO     EQU $2A
ADR       EQU $4E
HRAN     EQU $01
LIR        EQU $C9
KOM      EQU $15

RELCALC  LDA ADR           установить начало таблицы
                CLC               перемещения
                ADC NAS
                STA ADR
                LDA ADR+1
                ADC NAS+1
                STA ADR+1
                LDA #4
                CLC
                ADC ADR
                STA ADR
                LDA #0
                TAY
                ADC ADR+1
                STA ADR+1
         
CSICL      LDA (ADR),Y     Y=0
               BNE RETURN
         
START     RTS

RETURN   INY             Y=1
               LDA (ADR),Y
               CLC
               ADC NAS
               STA HRAN
               INY             Y=2
               LDA (ADR),Y
               ADC NAS+1
               STA HRAN+1
         
               LDY#0
               LDA (HRAN),Y
               TAX
               LDA (ADR),Y     Y=0
               PHA
               BMI CS1         3 BYTES  ML/ST
               ASL A
               BMI CS2         2 BYTES
               ASL A
               BMI CS8         3 BYTES  ST/ML
               PLA
               TXA
               SEC
               SBC LIR
               CLC
               ADC NAS
CS7         STA (HRAN),Y

CS6         LDA#4
               CLC
               ADC ADR
               STA ADR
               LDA#0
               TAY             Y=0
               ADC ADR+1
               STA ADR+1
               TYA             A=0
               BEQ CSICL       (JMP)
         
CS8        INY
              BNE CS9         (JMP)

CS1        INY             Y=1
              LDA (HRAN),Y
              TAX
              DEY             Y=0
CS9        LDA (HRAN),Y
              SEC
              BCS CS4         (JMP)

CS2      LDY#3
            LDA (ADR),Y     2 BYTES LOW
            SEC
CS4      SBC LIR
            STA KOM
            TXA
            SBC LIR+1
            STA KOM+1
         
            LDA NAS
            CLC
            ADC KOM
            TAX             X=LOW
            LDA NAS+1
            ADC KOM+1
            TAY             Y=HIGH
            PLA
            BMI CS5         3 BYTES ML/ST
            ASL A
            ASL A
            BMI CS10        3 BYTES ST/ML
            TYA
            LDY#0
            BEQ CS7         (JMP)
         
CS10     TXA               
             PHA           Y  ->
             TYA             <-  X
             TAX                 
             PLA
             TAY
         
CS5      TYA
            LDY#1
            STA (HRAN),Y
            TXA
            DEY             Y=0
            BEQ CS7         (JMP)
         

         DS DRIVLOC+$100-*
