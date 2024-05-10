;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*              MODIFICAÇÕES PARA USO COM 12F675                   *
;*                FEITAS PELO PROF. MARDSON                        *
;*                      DEZEMBRO DE 2023                           *
;*                 BASEADO NO EXEMPLO DO LIVRO                     *
;*           Desbravando o PIC. David José de Souza                *
;*-----------------------------------------------------------------*
;*   MODELO PARA O PIC 12F675                                      *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     ARQUIVOS DE DEFINIÇÕES                      *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
#INCLUDE <p12f675.inc>	;ARQUIVO PADRÃO MICROCHIP PARA 12F675

	__CONFIG _BODEN_OFF & _CP_OFF & _PWRTE_ON & _WDT_OFF & _MCLRE_ON & _INTRC_OSC_NOCLKOUT

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                    PAGINAÇÃO DE MEMÓRIA                         *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;DEFINIÇÃO DE COMANDOS DE USUÁRIO PARA ALTERAÇÃO DA PÁGINA DE MEMÓRIA
#DEFINE	BANK0	BCF STATUS,RP0	;SETA BANK 0 DE MEMÓRIA
#DEFINE	BANK1	BSF STATUS,RP0	;SETA BANK 1 DE MAMÓRIA

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                         VARIÁVEIS                               *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINIÇÃO DOS NOMES E ENDEREÇOS DE TODAS AS VARIÁVEIS UTILIZADAS 
; PELO SISTEMA

	CBLOCK	0x20	;ENDEREÇO INICIAL DA MEMÓRIA DE
					;USUÁRIO
		W_TEMP		;REGISTRADORES TEMPORÁRIOS PARA USO
		STATUS_TEMP	;JUNTO ÀS INTERRUPÇÕES
		
		DATA_RECEIVED	    ;VARIAVEL QUE RECEBE O DATA
		COUNT_BITS	    ;VARIAVEL QUE CONTA OS BITS DO DATA
		;COLOQUE AQUI SUAS NOVAS VARIÁVEIS
		;NÃO ESQUEÇA COMENTÁRIOS ESCLARECEDORES

	ENDC			;FIM DO BLOCO DE DEFINIÇÃO DE VARIÁVEIS

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                        FLAGS INTERNOS                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINIÇÃO DE TODOS OS FLAGS UTILIZADOS PELO SISTEMA

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                         CONSTANTES                              *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINIÇÃO DE TODAS AS CONSTANTES UTILIZADAS PELO SISTEMA

#DEFINE SLAVE_ADDRESS H'53'	;ENDERECO DO SLAVE

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                           ENTRADAS                              *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINIÇÃO DE TODOS OS PINOS QUE SERÃO UTILIZADOS COMO ENTRADA
; RECOMENDAMOS TAMBÉM COMENTAR O SIGNIFICADO DE SEUS ESTADOS (0 E 1)
	
#DEFINE SCL GPIO, GP0		;PORTA QUE REPRESENTA O SCL
#DEFINE SCL_IN_OUT TRISIO, 0	;BIT QUE CONTROLA INPUT/OUTPUT DO SCL
#DEFINE SDA GPIO, GP1		;PORTA QUE REPRESENTA O SDA
#DEFINE SDA_IN_OUT TRISIO, 1	;BIT QUE CONTROLA INPUT/OUTPUT DO SDA

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                           SAÍDAS                                *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINIÇÃO DE TODOS OS PINOS QUE SERÃO UTILIZADOS COMO SAÍDA
; RECOMENDAMOS TAMBÉM COMENTAR O SIGNIFICADO DE SEUS ESTADOS (0 E 1)

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                       VETOR DE RESET                            *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	ORG	0x00			;ENDEREÇO INICIAL DE PROCESSAMENTO
	GOTO	INICIO
	
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                    INÍCIO DA INTERRUPÇÃO                        *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; ENDEREÇO DE DESVIO DAS INTERRUPÇÕES. A PRIMEIRA TAREFA É SALVAR OS
; VALORES DE "W" E "STATUS" PARA RECUPERAÇÃO FUTURA

	ORG	0x04			;ENDEREÇO INICIAL DA INTERRUPÇÃO
	MOVWF	W_TEMP		;COPIA W PARA W_TEMP
	SWAPF	STATUS,W
	MOVWF	STATUS_TEMP	;COPIA STATUS PARA STATUS_TEMP

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                    ROTINA DE INTERRUPÇÃO                        *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; AQUI SERÃO ESCRITAS AS ROTINAS DE RECONHECIMENTO E TRATAMENTO DAS
; INTERRUPÇÕES

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                 ROTINA DE SAÍDA DA INTERRUPÇÃO                  *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; OS VALORES DE "W" E "STATUS" DEVEM SER RECUPERADOS ANTES DE 
; RETORNAR DA INTERRUPÇÃO

SAI_INT
	SWAPF	STATUS_TEMP,W
	MOVWF	STATUS		;MOVE STATUS_TEMP PARA STATUS
	SWAPF	W_TEMP,F
	SWAPF	W_TEMP,W	;MOVE W_TEMP PARA W
	RETFIE

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*	            	 ROTINAS E SUBROTINAS                      *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; CADA ROTINA OU SUBROTINA DEVE POSSUIR A DESCRIÇÃO DE FUNCIONAMENTO
; E UM NOME COERENTE ÀS SUAS FUNÇÕES.

SUBROTINA1

	;CORPO DA ROTINA

	RETURN
	
SDA_DOWN				;ESPERA ATÉ A DESCIDA DO SDA
	
	BTFSS	SDA	    
	GOTO	$-1
	BTFSC	SDA
	GOTO	$-1

	RETURN

SLC_DOWN				;ESPERA ATÉ A DESCIDA DO SLC
	
	BTFSS	SCL	    
	GOTO	$-1
	BTFSC	SCL
	GOTO	$-1

	RETURN

SLC_UP					;ESPERA ATÉ A SUBIDA DO SLC
	
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
	
	BCF STATUS, C			;LIMPA O BIT DE CARRY DA ROTAÇÂO
	BTFSC SDA			;VERIFICA SE O DADO ENVIADO É 0/1
	BSF STATUS, C			;SETA O BIT DE CARRY DA ROTAÇÃO
	
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
	BCF SCL_IN_OUT			;ALTERA A PORTA SCL PARA SAÍDA
	
	BANK0
	BCF SCL				;FORÇA O CLOCK PARA LOW
	
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
	MOVWF	TRISIO		;COMO SAÍDAS
	CLRF	ANSEL 		;DEFINE PORTAS COMO Digital I/O
	MOVLW	B'00000111'
	MOVWF	OPTION_REG	;DEFINE OPÇÕES DE OPERAÇÃO
	MOVLW	B'00000000'
	MOVWF	INTCON		;DEFINE OPÇÕES DE INTERRUPÇÕES
	BANK0			;RETORNA PARA O BANCO
	MOVLW	B'00000111'
	MOVWF	CMCON		;DEFINE O MODO DE OPERAÇÃO DO COMPARADOR ANALÓGICO

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIALIZAÇÃO DAS VARIÁVEIS                 *
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
