;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*              MODIFICAÇÕES PARA USO COM 12F675                   *
;*                FEITAS PELO PROF. MARDSON                        *
;*                      OUTUBRO DE 2022                            *
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
		ITERADOR_2s	;VARIAVEL QUE CONTROLA O LOOP NA FUNCAO DELAY
		ITERADOR_0.5s	;VARIAVEL QUE CONTROLA O LOOP NA FUNCAO DELAY
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

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                           ENTRADAS                              *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINIÇÃO DE TODOS OS PINOS QUE SERÃO UTILIZADOS COMO ENTRADA
; RECOMENDAMOS TAMBÉM COMENTAR O SIGNIFICADO DE SEUS ESTADOS (0 E 1)

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

	
SET_ITERADORES			;FUNÇÃO QUE INICIA AS VARIAVEIS DE CONTROLE
	MOVLW .8		;DOS LOOPS DAS FUNCOES DE DELAY
	MOVWF ITERADOR_0.5s
	MOVLW .34
	MOVWF ITERADOR_2s
	
	RETURN
	
SET_OFFSET_2s			;FUNÇÃO QUE INICIA O OFFSET PARA O DELAY DE 2 SEGUNDOS
	MOVLW .26
	MOVWF TMR0
	
	RETURN

SET_OFFSET_0.5s			;FUNÇÃO QUE INICIA O OFFSET PARA O DELAY DE 0.5 SEGUNDO
	MOVLW .12
	MOVWF TMR0
	
	RETURN
	
TIME_WAIT			;FUNCAO QUE TEM O PAPEL DE ESPERAR/CONTAR
				;PEQUENAS FRAÇÕES DE TEMPO
	BTFSS INTCON, T0IF
	GOTO TIME_WAIT
	BCF INTCON, T0IF
	RETURN

DELAY_2s			;FUNÇÃO RESPONSAVEL POR ESPERAR 2 SEGUNDOS
				;ATRAVES DE PEQUENAS FRAÇÕES DE TEMPO EM LOOP
	CALL SET_OFFSET_2s
	CALL TIME_WAIT		;FRAÇÃO DE TEMPO
	
	DECFSZ ITERADOR_2s, F	;CONTROLANDO A QUANTIDADE DE LOOPS
	GOTO DELAY_2s
	
	MOVLW .34
	MOVWF ITERADOR_2s
	
	RETURN

DELAY_0.5s			;FUNÇÃO RESPONSAVEL POR ESPERAR 0.5 SEGUNDO
				;ATRAVES DE PEQUENAS FRAÇÕES DE TEMPO EM LOOP
	
	CALL NOPS_SEGUIDOS	;NOPS SEGUINDOS PARA ALCANÇAR COM PRECISÃO O TEMPO ESPERADO 
	CALL SET_OFFSET_0.5s
	CALL TIME_WAIT		;FRAÇÃO DE TEMPO
	
	DECFSZ ITERADOR_0.5s, F	;CONTROLANDO A QUANTIDADE DE LOOPS
	GOTO DELAY_0.5s
	
	MOVLW .8
	MOVWF ITERADOR_0.5s

	RETURN

SEM1_RED_ON_SEM2_GREEN_ON	
	
	BSF GPIO, GP0		;LIGA A LED VERMELHA DO SEMÁFORO 1 E A LED VERDE DO SEMÁFORO 2
	RETURN
	
SEM1_GREEN_ON_SEM2_RED_ON
	
	BSF GPIO, GP2		;LIGA A LED VERDE DO SEMÁFORO 1 E A LED VERMELHA DO SEMÁFORO 2
	RETURN
	
SEM_1_CLEAN_LEDS		;DESLIGA TODAS AS LEDS DO SEMÁFORO 1
	
	BCF GPIO, GP0
	BCF GPIO, GP1
	BCF GPIO, GP2
	RETURN
	
SEM_2_CLEAN_LEDS		;DESLIGA TODAS AS LEDS DO SEMÁFORO 2
	
	BCF GPIO, GP2
	BCF GPIO, GP4
	BCF GPIO, GP0
	RETURN	
	
NOPS_SEGUIDOS			;NOPS SEGUIDOS UTILIZADOS NA FUNÇÃO DE 0.5 SEGUNDOS
	
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
	MOVWF	TRISIO		;COMO SAÍDAS
	CLRF	ANSEL 		;DEFINE PORTAS COMO Digital I/O
	MOVLW	B'00000111'
	MOVWF	OPTION_REG	;DEFINE OPÇÕES DE OPERAÇÃO
	MOVLW	B'00000000'
	MOVWF	INTCON		;DEFINE OPÇÕES DE INTERRUPÇÕES
	BANK0				;RETORNA PARA O BANCO
	MOVLW	B'00000111'
	MOVWF	CMCON		;DEFINE O MODO DE OPERAÇÃO DO COMPARADOR ANALÓGICO

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIALIZAÇÃO DAS VARIÁVEIS                 *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	CALL SET_ITERADORES
	
	;RELAÇÃO DAS PORTAS E SEUS REPECTIVOS LEDS
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
	
	BSF GPIO, GP4			    ;LIGA O LED AMARELO DO SEMÁFORO 2
	
	CALL DELAY_0.5s			    ;ESPERA 0.5 SEGUNDO

	CALL SEM_1_CLEAN_LEDS		    ;DESLIGA TODAS AS LEDS DO SEMAFORO 1
	CALL SEM_2_CLEAN_LEDS		    ;DESLIGA TODAS AS LEDS DO SEMAFORO 2
	
	CALL SEM1_GREEN_ON_SEM2_RED_ON

	CALL DELAY_2s			    ;ESPERA 2 SEGUNDOS
	
	BSF GPIO, GP1			    ;LIGA O LED AMARELO DO SEMÁFORO 1
	
	CALL DELAY_0.5s			    ;ESPERA 0.5 SEGUNDO

	CALL SEM_1_CLEAN_LEDS		    ;DESLIGA TODAS AS LEDS DO SEMAFORO 1
	CALL SEM_2_CLEAN_LEDS		    ;DESLIGA TODAS AS LEDS DO SEMAFORO 2
	
	GOTO	MAIN

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                       FIM DO PROGRAMA                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	END