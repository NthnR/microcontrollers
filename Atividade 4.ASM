;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*              MODIFICA��ES PARA USO COM 12F675                   *
;*                FEITAS PELO PROF. MARDSON                        *
;*                      DEZEMBRO DE 2023                           *
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
		
		DATA_RECEIVED	    ;VARIAVEL QUE RECEBE O DATA
		COUNT_BITS	    ;VARIAVEL QUE CONTA OS BITS DO DATA
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

#DEFINE SLAVE_ADDRESS H'53'	;ENDERECO DO SLAVE

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                           ENTRADAS                              *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINI��O DE TODOS OS PINOS QUE SER�O UTILIZADOS COMO ENTRADA
; RECOMENDAMOS TAMB�M COMENTAR O SIGNIFICADO DE SEUS ESTADOS (0 E 1)
	
#DEFINE SCL GPIO, GP0		;PORTA QUE REPRESENTA O SCL
#DEFINE SCL_IN_OUT TRISIO, 0	;BIT QUE CONTROLA INPUT/OUTPUT DO SCL
#DEFINE SDA GPIO, GP1		;PORTA QUE REPRESENTA O SDA
#DEFINE SDA_IN_OUT TRISIO, 1	;BIT QUE CONTROLA INPUT/OUTPUT DO SDA

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

SUBROTINA1

	;CORPO DA ROTINA

	RETURN
	
SDA_DOWN				;ESPERA AT� A DESCIDA DO SDA
	
	BTFSS	SDA	    
	GOTO	$-1
	BTFSC	SDA
	GOTO	$-1

	RETURN

SLC_DOWN				;ESPERA AT� A DESCIDA DO SLC
	
	BTFSS	SCL	    
	GOTO	$-1
	BTFSC	SCL
	GOTO	$-1

	RETURN

SLC_UP					;ESPERA AT� A SUBIDA DO SLC
	
	BTFSC	SCL	    
	GOTO	$-1
	BTFSS	SCL
	GOTO	$-1

	RETURN
	
SET_OFFSET
	MOVLW .53
	MOVWF TMR0
	RETURN
	
SET_INICIAL
	MOVLW .8
	MOVWF COUNT_BITS
	CLRF DATA_RECEIVED
	
	RETURN

TIME_WAIT
	
	BTFSS INTCON, T0IF
	GOTO TIME_WAIT
	BCF INTCON, T0IF
	
	RETURN
	
START_BIT
	
	CALL SDA_DOWN
	BTFSS SCL
	GOTO START_BIT
	
	RETURN
	
RECEIVE_DATA_ROUTINE
	
	CALL SLC_UP
	
	BCF STATUS, C			;LIMPA O BIT DE CARRY DA ROTA��O
	BTFSC SDA			;VERIFICA SE O DADO ENVIADO � 0/1
	BSF STATUS, C			;SETA O BIT DE CARRY DA ROTA��O
	
	RLF DATA_RECEIVED		;ROTACIONA E POSICIONA O CARRY NO INICIO DA VARIAVEL   
	
	DECFSZ COUNT_BITS		;MANTEM O RECEBIMENTO 8 VEZES
	GOTO RECEIVE_DATA_ROUTINE
	
	RETURN
	
SEND_ACKNOWLEDGE
	
	BTFSC SCL
	GOTO $-1
	
	BANK1
	BCF SDA_IN_OUT			;ALTERA A PORTA SDA PARA SAIDA
	
	BANK0
	BCF SDA				;MANDA ACK
	
	CALL SLC_UP			;ESPERA O MASTER LER O ACK
	
	BANK1		
	BSF	SDA_IN_OUT		;LIBERA SDA
	
	BANK0
	
	RETURN
	
TURN_LED
	
	BSF GPIO, GP5			;ACENDE O LED
	CALL TIME_WAIT
	BCF GPIO, GP5			;DESLIGA O LED
	
	RETURN

RIGHT_ADDRESS
	
	CALL SEND_ACKNOWLEDGE
	
	BTFSC	SCL			;ESPERA CLOCK EM LOW
	GOTO	$-1
	
	BANK1
	BCF SCL_IN_OUT			;ALTERA A PORTA SCL PARA SA�DA
	
	BANK0
	BCF SCL				;FOR�A O CLOCK PARA LOW
	
	CALL TURN_LED			;LIGA O LED, ESPERA 50ms, DESLIGA LED
	
	BANK1
	BSF SCL_IN_OUT			;LIBERA A PORTA SCL
	
	BANK0
	
	RETURN
	

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIO DO PROGRAMA                          *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	
INICIO
	BANK1			;ALTERA PARA O BANCO 1
	MOVLW	B'00000011'	;CONFIGURA TODAS AS PORTAS DO GPIO (PINOS)
	MOVWF	TRISIO		;COMO SA�DAS
	CLRF	ANSEL 		;DEFINE PORTAS COMO Digital I/O
	MOVLW	B'00000111'
	MOVWF	OPTION_REG	;DEFINE OP��ES DE OPERA��O
	MOVLW	B'00000000'
	MOVWF	INTCON		;DEFINE OP��ES DE INTERRUP��ES
	BANK0			;RETORNA PARA O BANCO
	MOVLW	B'00000111'
	MOVWF	CMCON		;DEFINE O MODO DE OPERA��O DO COMPARADOR ANAL�GICO

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIALIZA��O DAS VARI�VEIS                 *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	
;GP0 - SCL
;GP1 - SDA
;GP5 - Led

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     ROTINA PRINCIPAL                            *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
MAIN
	CALL SET_OFFSET
	CALL START_BIT
	CALL SET_INICIAL
	CALL RECEIVE_DATA_ROUTINE
	BCF STATUS,C	
	RRF DATA_RECEIVED
	MOVLW SLAVE_ADDRESS	    
	SUBWF DATA_RECEIVED, W	    ;ENDERECO RECEBIDO - ENDERECO SALVO
	BTFSC STATUS, Z		    ;SE IGUAL A 0
	CALL RIGHT_ADDRESS	    ;MANDA O ACK E LIGA O LED
	
	GOTO	MAIN

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                       FIM DO PROGRAMA                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	END
