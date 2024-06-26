;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*              MODIFICA��ES PARA USO COM 12F675                   *
;*                FEITAS PELO PROF. MARDSON                        *
;*                      OUTUBRO DE 2022                            *
;*                 BASEADO NO EXEMPLO DO LIVRO                     *
;*           Desbravando o PIC. David Jos� de Souza                *
;*-----------------------------------------------------------------*
;*   MODELO PARA O PIC 12F675                                      *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

;SINAL ANAL�GICO - GP1
;RESET - GP3			PS: O RESET PRECISA ESTAR DESLIGADO PARA O LED LIGAR, NOS TESTES PERCEBI QUE ELE COME�A ALTO ASSIM QUE O PROGRAMA INICIA
;LED - GP5
	
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     ARQUIVOS DE DEFINI��ES                      *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
#INCLUDE <p12f675.inc>	;ARQUIVO PADR�O MICROCHIP PARA 12F675

	__CONFIG _BODEN_OFF & _CP_OFF & _PWRTE_ON & _WDT_OFF & _MCLRE_ON & _INTRC_OSC_NOCLKOUT

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                    PAGINA��O DE MEM�RIA                         *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;DEFINI��O DE COMANDOS DE USU�RIO PARA ALTERA��O DA P�GINA DE MEM�RIA
#DEFINE	BANK0	BCF STATUS,RP0	;SETA BANK 0 DE MEM�RIA
#DEFINE	BANK1	BSF STATUS,RP0	;SETA BANK 1 DE MAM�RIA

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                         VARI�VEIS                               *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINI��O DOS NOMES E ENDERE�OS DE TODAS AS VARI�VEIS UTILIZADAS 
; PELO SISTEMA

	CBLOCK	0x20	;ENDERE�O INICIAL DA MEM�RIA DE
					;USU�RIO
		W_TEMP		;REGISTRADORES TEMPOR�RIOS PARA USO
		STATUS_TEMP	;JUNTO �S INTERRUP��ES
		;COLOQUE AQUI SUAS NOVAS VARI�VEIS
		;N�O ESQUE�A COMENT�RIOS ESCLARECEDORES

	ENDC			;FIM DO BLOCO DE DEFINI��O DE VARI�VEIS

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                        FLAGS INTERNOS                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINI��O DE TODOS OS FLAGS UTILIZADOS PELO SISTEMA

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                         CONSTANTES                              *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINI��O DE TODAS AS CONSTANTES UTILIZADAS PELO SISTEMA

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                           ENTRADAS                              *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINI��O DE TODOS OS PINOS QUE SER�O UTILIZADOS COMO ENTRADA
; RECOMENDAMOS TAMB�M COMENTAR O SIGNIFICADO DE SEUS ESTADOS (0 E 1)

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                           SA�DAS                                *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINI��O DE TODOS OS PINOS QUE SER�O UTILIZADOS COMO SA�DA
; RECOMENDAMOS TAMB�M COMENTAR O SIGNIFICADO DE SEUS ESTADOS (0 E 1)

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                       VETOR DE RESET                            *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	ORG	0x00			;ENDERE�O INICIAL DE PROCESSAMENTO
	GOTO	INICIO
	
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                    IN�CIO DA INTERRUP��O                        *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; ENDERE�O DE DESVIO DAS INTERRUP��ES. A PRIMEIRA TAREFA � SALVAR OS
; VALORES DE "W" E "STATUS" PARA RECUPERA��O FUTURA

	ORG	0x04			;ENDERE�O INICIAL DA INTERRUP��O
	MOVWF	W_TEMP		;COPIA W PARA W_TEMP
	SWAPF	STATUS,W
	MOVWF	STATUS_TEMP	;COPIA STATUS PARA STATUS_TEMP

	
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                    ROTINA DE INTERRUP��O                        *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; AQUI SER�O ESCRITAS AS ROTINAS DE RECONHECIMENTO E TRATAMENTO DAS
; INTERRUP��ES
	
	
	GOTO SAI_INT
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                 ROTINA DE SA�DA DA INTERRUP��O                  *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; OS VALORES DE "W" E "STATUS" DEVEM SER RECUPERADOS ANTES DE 
; RETORNAR DA INTERRUP��O

SAI_INT
	SWAPF	STATUS_TEMP,W
	MOVWF	STATUS		;MOVE STATUS_TEMP PARA STATUS
	SWAPF	W_TEMP,F
	SWAPF	W_TEMP,W	;MOVE W_TEMP PARA W
	RETFIE

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*	            	 ROTINAS E SUBROTINAS                      *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; CADA ROTINA OU SUBROTINA DEVE POSSUIR A DESCRI��O DE FUNCIONAMENTO
; E UM NOME COERENTE �S SUAS FUN��ES.

SUBROTINA1

	;CORPO DA ROTINA
	
	RETURN

SEARCH_INTERVAL				;VERIFICA A TENS�O DO SINAL ANALOGICO
					;COM INTUITO DE ENCONTRAR O INTERVALO QUE EST� POSICIONADO
	
	BTFSC GPIO, GP3			;DESLIGA O LED QUANDO O RESET FOR PRESSIONADO
	CALL LED_OFF
					
	CALL MORE_THAN_3.5
	CALL MORE_THAN_3.0
	CALL MORE_THAN_2.5
	CALL MORE_THAN_2.0
	CALL MORE_THAN_1.5
	CALL MORE_THAN_1.0
	CALL MORE_THAN_0.5
	
	GOTO SEARCH_INTERVAL

MORE_THAN_3.5
	BANK1
	MOVLW	B'10001110'		;CONFIGURA O COMPARADOR
	MOVWF	VRCON			;HIGH - N 14 - VREF = 3.44 V
	BANK0
	BTFSC GPIO, GP2			;VERIFICA SE O SINAL ANALOGICO � MAIOR QUE VREF
	GOTO LED_IN_100			;SE FOR, DUTY CYCLE DE 100%
	
	RETURN
	
MORE_THAN_3.0
	BANK1
	MOVLW	B'10001011'		;CONFIGURA O COMPARADOR
	MOVWF	VRCON			;HIGH - N 11 - VREF = 2.97 V
	BANK0
	BTFSC GPIO, GP2			;VERIFICA SE O SINAL ANALOGICO � MAIOR QUE VREF
	GOTO LED_IN_80			;SE FOR, DUTY CYCLE DE 80%
	
	RETURN
	
MORE_THAN_2.5
	BANK1
	MOVLW	B'10001000'		;CONFIGURA O COMPARADOR
	MOVWF	VRCON			;HIGH - N 8 - VREF = 2.5 V
	BANK0
	BTFSC GPIO, GP2			;VERIFICA SE O SINAL ANALOGICO � MAIOR QUE VREF
	GOTO LED_IN_40			;SE FOR, DUTY CYCLE DE 40%
	
	RETURN
	
MORE_THAN_2.0
	BANK1
	MOVLW	B'10000101'		;CONFIGURA O COMPARADOR
	MOVWF	VRCON			;HIGH - N 5 - VREF = 2.03 V
	BANK0
	BTFSC GPIO, GP2			;VERIFICA SE O SINAL ANALOGICO � MAIOR QUE VREF
	GOTO LED_IN_30			;SE FOR, DUTY CYCLE DE 30%
	
	RETURN
	
MORE_THAN_1.5
	BANK1
	MOVLW	B'10000010'		;CONFIGURA O COMPARADOR
	MOVWF	VRCON			;HIGH - N 2 - VREF = 1.56 V
	BANK0
	BTFSC GPIO, GP2			;VERIFICA SE O SINAL ANALOGICO � MAIOR QUE VREF	
	GOTO LED_IN_20			;SE FOR, DUTY CYCLE DE 20%
	
	RETURN
	
MORE_THAN_1.0
	BANK1
	MOVLW	B'10100101'		;CONFIGURA O COMPARADOR
	MOVWF	VRCON			;LOW - N 5 - VREF = 0.94 V
	BANK0
	BTFSC GPIO, GP2			;VERIFICA SE O SINAL ANALOGICO � MAIOR QUE VREF	
	GOTO LED_IN_10			;SE FOR, DUTY CYCLE DE 10%
	
	RETURN
	
MORE_THAN_0.5
	BANK1
	MOVLW	B'10100010'		;CONFIGURA O COMPARADOR
	MOVWF	VRCON			;LOW - N 2 - VREF = 0.42 V
	BANK0
	BTFSC GPIO, GP2			;VERIFICA SE O SINAL ANALOGICO � MAIOR QUE VREF	
	GOTO LED_IN_05			;SE FOR, DUTY CYCLE DE 5%
	GOTO LED_OFF			;SE N�O, DESLIGA O LED
	
	RETURN

LED_IN_100
	MOVLW .7		;OFFSET PARA O DELAY DE 2ms
	MOVWF TMR0
	BSF GPIO, GP5		;LIGA O LED
	CALL TIME_WAIT		;DELAY
	
	GOTO SEARCH_INTERVAL
	
LED_IN_80
	MOVLW .57		;OFFSET PARA O DELAY DE 1.6ms
	MOVWF TMR0
	BSF GPIO, GP5		;LIGA O LED
	CALL TIME_WAIT
	MOVLW .207		;OFFSET PARA O DELAY DE 0.4ms
	MOVWF TMR0
	BCF GPIO, GP5		;DESLIGA O LED
	CALL TIME_WAIT
	
	GOTO SEARCH_INTERVAL
	
LED_IN_40
	MOVLW .157		;OFFSET PARA O DELAY DE 0.8ms
	MOVWF TMR0
	BSF GPIO, GP5		;LIGA O LED
	CALL TIME_WAIT
	MOVLW .107		;OFFSET PARA O DELAY DE 1.2ms
	MOVWF TMR0
	BCF GPIO, GP5		;DESLIGA O LED
	CALL TIME_WAIT
	
	GOTO SEARCH_INTERVAL
	
LED_IN_30
	MOVLW .182		;OFFSET PARA O DELAY DE 0.6ms
	MOVWF TMR0
	BSF GPIO, GP5		;LIGA O LED
	CALL TIME_WAIT
	MOVLW .82		;OFFSET PARA O DELAY DE 1.4ms
	MOVWF TMR0
	BCF GPIO, GP5		;DESLIGA O LED
	CALL TIME_WAIT
	
	GOTO SEARCH_INTERVAL
	
LED_IN_20
	MOVLW .207		;OFFSET PARA O DELAY DE 0.4ms
	MOVWF TMR0
	BSF GPIO, GP5		;LIGA O LED
	CALL TIME_WAIT
	MOVLW .57		;OFFSET PARA O DELAY DE 1.6ms
	MOVWF TMR0
	BCF GPIO, GP5		;DESLIGA O LED
	CALL TIME_WAIT
	
	GOTO SEARCH_INTERVAL
	
LED_IN_10
	MOVLW .232		;OFFSET PARA O DELAY DE 0.2ms
	MOVWF TMR0
	BSF GPIO, GP5		;LIGA O LED
	CALL TIME_WAIT
	MOVLW .32		;OFFSET PARA O DELAY DE 1.8ms
	MOVWF TMR0
	BCF GPIO, GP5		;DESLIGA O LED
	CALL TIME_WAIT
	
	GOTO SEARCH_INTERVAL
	
LED_IN_05
	MOVLW .244		;OFFSET PARA O DELAY DE 0.1ms
	MOVWF TMR0
	BSF GPIO, GP5		;LIGA O LED
	CALL TIME_WAIT
	MOVLW .19		;OFFSET PARA O DELAY DE 1.9ms
	MOVWF TMR0
	BCF GPIO, GP5		;DESLIGA O LED
	CALL TIME_WAIT
	
	GOTO SEARCH_INTERVAL
	
LED_OFF
	MOVLW .7		;OFFSET PARA O DELAY DE 2ms
	MOVWF TMR0
	BCF GPIO, GP5		;DESLIGA O LED
	CALL TIME_WAIT		;DELAY
	
	GOTO SEARCH_INTERVAL
	
TIME_WAIT			;FUNCAO QUE TEM O PAPEL DE ESPERAR
				
	BTFSS INTCON, T0IF
	GOTO TIME_WAIT
	BCF INTCON, T0IF
	RETURN
	
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIO DO PROGRAMA                          *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	
INICIO
	BANK1				;ALTERA PARA O BANCO 1
	MOVLW	B'00001010'	;CONFIGURA TODAS AS PORTAS DO GPIO (PINOS)
	MOVWF	TRISIO		;COMO SA�DAS
	MOVWF	ANSEL 		;DEFINE PORTAS COMO Digital I/O
	MOVLW	B'00000010'
	MOVWF	OPTION_REG	;DEFINE OP��ES DE OPERA��O
	MOVLW	B'00000000'
	MOVWF	INTCON		;DEFINE OP��ES DE INTERRUP��ES
	MOVLW	B'10001110'
	MOVWF	VRCON		
	BANK0				;RETORNA PARA O BANCO
	MOVLW	B'00010011'
	MOVWF	CMCON		;DEFINE O MODO DE OPERA��O DO COMPARADOR ANAL�GICO

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIALIZA��O DAS VARI�VEIS                 *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     ROTINA PRINCIPAL                            *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
MAIN

	;CORPO DA ROTINA PRINCIPAL
	GOTO SEARCH_INTERVAL

	
	GOTO	MAIN

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                       FIM DO PROGRAMA                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	END