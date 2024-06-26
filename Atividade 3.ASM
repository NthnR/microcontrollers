;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*              MODIFICA��ES PARA USO COM 12F675                   *
;*                FEITAS PELO PROF. MARDSON                        *
;*                      OUTUBRO DE 2022                            *
;*                 BASEADO NO EXEMPLO DO LIVRO                     *
;*           Desbravando o PIC. David Jos� de Souza                *
;*-----------------------------------------------------------------*
;*   MODELO PARA O PIC 12F675                                      *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

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
		ITERADOR_2s	;VARIAVEL QUE CONTROLA O LOOP NA FUNCAO DELAY
		ITERADOR_0.5s	;VARIAVEL QUE CONTROLA O LOOP NA FUNCAO DELAY
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

	
SET_ITERADORES			;FUN��O QUE INICIA AS VARIAVEIS DE CONTROLE
	MOVLW .8		;DOS LOOPS DAS FUNCOES DE DELAY
	MOVWF ITERADOR_0.5s
	MOVLW .34
	MOVWF ITERADOR_2s
	
	RETURN
	
SET_OFFSET_2s			;FUN��O QUE INICIA O OFFSET PARA O DELAY DE 2 SEGUNDOS
	MOVLW .26
	MOVWF TMR0
	
	RETURN

SET_OFFSET_0.5s			;FUN��O QUE INICIA O OFFSET PARA O DELAY DE 0.5 SEGUNDO
	MOVLW .12
	MOVWF TMR0
	
	RETURN
	
TIME_WAIT			;FUNCAO QUE TEM O PAPEL DE ESPERAR/CONTAR
				;PEQUENAS FRA��ES DE TEMPO
	BTFSS INTCON, T0IF
	GOTO TIME_WAIT
	BCF INTCON, T0IF
	RETURN

DELAY_2s			;FUN��O RESPONSAVEL POR ESPERAR 2 SEGUNDOS
				;ATRAVES DE PEQUENAS FRA��ES DE TEMPO EM LOOP
	CALL SET_OFFSET_2s
	CALL TIME_WAIT		;FRA��O DE TEMPO
	
	DECFSZ ITERADOR_2s, F	;CONTROLANDO A QUANTIDADE DE LOOPS
	GOTO DELAY_2s
	
	MOVLW .34
	MOVWF ITERADOR_2s
	
	RETURN

DELAY_0.5s			;FUN��O RESPONSAVEL POR ESPERAR 0.5 SEGUNDO
				;ATRAVES DE PEQUENAS FRA��ES DE TEMPO EM LOOP
	
	CALL NOPS_SEGUIDOS	;NOPS SEGUINDOS PARA ALCAN�AR COM PRECIS�O O TEMPO ESPERADO 
	CALL SET_OFFSET_0.5s
	CALL TIME_WAIT		;FRA��O DE TEMPO
	
	DECFSZ ITERADOR_0.5s, F	;CONTROLANDO A QUANTIDADE DE LOOPS
	GOTO DELAY_0.5s
	
	MOVLW .8
	MOVWF ITERADOR_0.5s

	RETURN

SEM1_RED_ON_SEM2_GREEN_ON	
	
	BSF GPIO, GP0		;LIGA A LED VERMELHA DO SEM�FORO 1 E A LED VERDE DO SEM�FORO 2
	RETURN
	
SEM1_GREEN_ON_SEM2_RED_ON
	
	BSF GPIO, GP2		;LIGA A LED VERDE DO SEM�FORO 1 E A LED VERMELHA DO SEM�FORO 2
	RETURN
	
SEM_1_CLEAN_LEDS		;DESLIGA TODAS AS LEDS DO SEM�FORO 1
	
	BCF GPIO, GP0
	BCF GPIO, GP1
	BCF GPIO, GP2
	RETURN
	
SEM_2_CLEAN_LEDS		;DESLIGA TODAS AS LEDS DO SEM�FORO 2
	
	BCF GPIO, GP2
	BCF GPIO, GP4
	BCF GPIO, GP0
	RETURN	
	
NOPS_SEGUIDOS			;NOPS SEGUIDOS UTILIZADOS NA FUN��O DE 0.5 SEGUNDOS
	
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	
	RETURN
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIO DO PROGRAMA                          *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	
INICIO
	BANK1				;ALTERA PARA O BANCO 1
	MOVLW	B'00000000'	;CONFIGURA TODAS AS PORTAS DO GPIO (PINOS)
	MOVWF	TRISIO		;COMO SA�DAS
	CLRF	ANSEL 		;DEFINE PORTAS COMO Digital I/O
	MOVLW	B'00000111'
	MOVWF	OPTION_REG	;DEFINE OP��ES DE OPERA��O
	MOVLW	B'00000000'
	MOVWF	INTCON		;DEFINE OP��ES DE INTERRUP��ES
	BANK0				;RETORNA PARA O BANCO
	MOVLW	B'00000111'
	MOVWF	CMCON		;DEFINE O MODO DE OPERA��O DO COMPARADOR ANAL�GICO

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIALIZA��O DAS VARI�VEIS                 *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	CALL SET_ITERADORES
	
	;RELA��O DAS PORTAS E SEUS REPECTIVOS LEDS
	;
	;		SEM1		SEM2
	;
	;RED		GP0		GP2
	;YELLOW		GP1		GP4
	;GREEN 		GP2		GP0
	;
	
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     ROTINA PRINCIPAL                            *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
MAIN
	

	CALL SEM1_RED_ON_SEM2_GREEN_ON	    
	
	CALL DELAY_2s			    ;ESPERA 2 SEGUNDOS
	
	BSF GPIO, GP4			    ;LIGA O LED AMARELO DO SEM�FORO 2
	
	CALL DELAY_0.5s			    ;ESPERA 0.5 SEGUNDO

	CALL SEM_1_CLEAN_LEDS		    ;DESLIGA TODAS AS LEDS DO SEMAFORO 1
	CALL SEM_2_CLEAN_LEDS		    ;DESLIGA TODAS AS LEDS DO SEMAFORO 2
	
	CALL SEM1_GREEN_ON_SEM2_RED_ON

	CALL DELAY_2s			    ;ESPERA 2 SEGUNDOS
	
	BSF GPIO, GP1			    ;LIGA O LED AMARELO DO SEM�FORO 1
	
	CALL DELAY_0.5s			    ;ESPERA 0.5 SEGUNDO

	CALL SEM_1_CLEAN_LEDS		    ;DESLIGA TODAS AS LEDS DO SEMAFORO 1
	CALL SEM_2_CLEAN_LEDS		    ;DESLIGA TODAS AS LEDS DO SEMAFORO 2
	
	GOTO	MAIN

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                       FIM DO PROGRAMA                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	END