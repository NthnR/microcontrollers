;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*              MODIFICA��ES PARA USO COM 12F675                   *
;*                FEITAS PELO PROF. MARDSON                        *
;*                     MAR�O DE 2024                               *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                       NOME DO PROJETO                           *
;*                           CLIENTE                               *
;*         DESENVOLVIDO PELA MOSAICO ENGENHARIA E CONSULTORIA      *
;*   VERS�O: 1.0                           DATA: 17/06/03          *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     DESCRI��O DO ARQUIVO                        *
;*-----------------------------------------------------------------*
;*   MODELO PARA O PIC 12F675                                      *
;*                                                                 *
;*                                                                 *
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
		DADO		;ARMAZENA O DADO PARA A EEPROM
		
		TEMPO		; VARIAVEL ONDE O TAU DE CADA MEDI��O � GUARDADO
		ITERATOR	; NUMERO DE REPETI��ES
		DIV_FRAC_1	; PRIMEIRA CASA DECIMAL DA DIVISAO
		DIV_INTEIRA	; PARTE INTEIRA DA DIVISAO
		DIV_FRAC_2	; SEGUNDA CASA DECIMAL DA DIVISAO
		MEDIA_INTEIRA	; PARTE INTEIRA DA MEDIA
		MEDIA_FRAC_1	; PRIMEIRA CASA DECIMAL DA MEDIA
		MEDIA_FRAC_2	; SEGUNDA CASA DECIMAL DA MEDIA
		RESTO		; RESTO DA DIVISAO
		AUXILIAR	; AUXILIAR NO CALCULO DA DIVISAO
		FLAG		; FLAG PARA MULTIPLICACAO
		LEITURAS	; QUANTIDADE DE LEITURAS
		;NOVAS VARI�VEIS

	ENDC			;FIM DO BLOCO DE MEM�RIA
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                        FLAGS INTERNOS                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINI��O DE TODOS OS FLAGS UTILIZADOS PELO SISTEMA

#DEFINE CONVERSION_START ADCON0, 1
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                         CONSTANTES                              *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINI��O DE TODAS AS CONSTANTES UTILIZADAS PELO SISTEMA
; INICIALIZA��O DA EEPROM, DE ACORDO COM A DESCRI��O NO ARQUIVO "Def_Rega_Formigas.inc"

;A PARTIR DO ENDERE�O ZERO DA EEPROM, DADOS EM ORDEM ALEAT�RIA
	ORG 0x2100
	DE	0X89,0X1E,0X39,0X9F,0XC2,0X0C,0XAB,0X33,0X63,0XD3,0X95,0X7B,0X38,0XD6,0X1E,0X48
	DE	0XDB,0XD8,0X86,0XFD,0XA5,0XFC,0X0C,0XBE,0X68,0X9B,0XD9,0X10,0XD8,0XEC,0X90,0X91
	DE	0XAA,0XBB,0XCC,0XDD,0XEE,0XF1,0XC9,0X77

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
LE_EEPROM
;LER DADO DA EEPROM, CUJO ENDERE�O � INDICADO EM W
;O DADO LIDO RETORNA EM W
	ANDLW	.127		;LIMITA ENDERE�O MAX. 127
	BANK1			;ACESSO VIA BANK 1
	MOVWF	EEADR		;INDICA O END. DE LEITURA
	BSF	EECON1,RD	;INICIA O PROCESSO DE LEITURA
	MOVF	EEDATA,W	;COLOCA DADO LIDO EM W
	BANK0			;POSICIONA PARA BANK 0
	RETURN

GRAVA_EEPROM
;ESCREVE UM DADO NA EEPROM, CUJO ENDERE�O � INDICADO EM W
;O DADO A SER ESCRITO DEVE ESTAR ARMAZENADO NA VARI�VEL DADO
	
	ANDLW	.127		;LIMITA ENDERE�O MAX. 127
	BANK1			;ACESSO VIA BANK 1
	MOVWF	EEADR
	MOVF	DADO,W
	MOVWF	EEDATA
	BSF	EECON1,WREN	;HABILITA ESCRITA
	BCF	INTCON,GIE	;DESLIGA INTERRUP��ES
	MOVLW	B'01010101'	;DESBLOQUEIA ESCRITA
	MOVWF	EECON2		;
	MOVLW	B'10101010'	;DESBLOQUEIA ESCRITA
	MOVWF	EECON2		;
	BSF	EECON1,WR	;INICIA A ESCRITA
AGUARDA
	BTFSC	EECON1,WR	;TERMINOU?
	GOTO	AGUARDA
	BSF	INTCON,GIE	;HABILITA INTERRUP��ES
	BANK0			;POSICIONA PARA BANK 0
	RETURN
	
PULSE
	BSF GPIO, GP2
	
	CALL WAIT_400MS
	
	BCF GPIO, GP2
	
	CONVERSION_AD_ROUTINE_3V 
	
	    BSF CONVERSION_START		; INICIA A CONVERS�O 
	    BTFSC CONVERSION_START		; E ESPERA AT� O T�RMINO
	    GOTO $-1
	    
	    MOVFW ADRESH			; VERIFICA SE A CONVERS�O
	    SUBLW .152				; EQUIVALENTE � MENOR IGUAL A 3V
	    BTFSS STATUS, C			; SE N�O, CONTINUA AS CONVERS�ES
	    GOTO CONVERSION_AD_ROUTINE_3V 
	    
	    MOVLW .0
	    MOVWF TMR0				; SE SIM, INICIA O TIMER
	    GOTO CONVERSION_AD_ROUTINE_1_1V
	    
	CONVERSION_AD_ROUTINE_1_1V
	
	    BSF CONVERSION_START		; INICIA A CONVERS�O 
	    BTFSC CONVERSION_START		; E ESPERA AT� O T�RMINO
	    GOTO $-1
	    
	    MOVFW TMR0
	    SUBLW .2				; TESTA SE O TMR � > 2
	    BTFSC STATUS, C			; SE SIM, 1 MS SE PASSOU
	    CALL COUNT_1MS			; TAU � INCREMENTADO EM 1 UNIDADE
	    
	    MOVFW ADRESH			; VERIFICA SE A CONVERS�O
	    SUBLW .55				; EQUIVALENTE � MENOR IGUAL A 1.1V
	    BTFSS STATUS, C			; SE N�O, CONTINUA AS CONVERS�ES
	    GOTO CONVERSION_AD_ROUTINE_1_1V 
	    
	    MOVFW TEMPO			
	    MOVWF INDF			; MOVE O VALOR DO TAU PARA RAM
	    INCF FSR			; APONTA PRA UM NOVO ENDERE�O NA RAM
	    CLRF TEMPO			; LIMPA O TAU PARA UMA NOVA MEDI��O
	    
	CALL WAIT_400MS
	
	RETURN

DIVISAO_ROTINA
	
    MOVLW .32				;MOVE O DIVISOR PARA W
    SUBWF RESTO, W			;SUBTRAI W DO DIVIDENDO

    BTFSS STATUS, C			    ;GUARDA APENAS O RESTO DA SUBTRACAO
    MOVFW RESTO			    ;EM RESTO
    MOVWF RESTO

    BTFSC STATUS, C			    ;INCREMENTA A VARIAVEL DE SAIDA
    INCF AUXILIAR, F		    ;ENQUANTO HOUVEREM SUBTRACOES POSSIVEIS

    BTFSC STATUS, C			    ;CONTINUA AS SUBTRACOES SUCESSIVAS
    GOTO DIVISAO_ROTINA		    ;ENQUANTO O DIVIDENDO > DIVISOR
    RETURN

MULT_10					    ;MULTIPLICA O RESTO DA DIVISAO POR 10
    ADDWF RESTO, W

    DECFSZ FLAG, F			    ;DECREMENTA A FLAG A CADA SOMA AT� UM TOTAL
    GOTO MULT_10			    ;DE 10 SOMA SUCESSIVAS

    MOVWF RESTO			    ;GUARDA O VALOR MULTIPLICADO PARA
    MOVLW .9			    ;UMA NOVA DIVISAO E RESETA A VARIAVEL
    MOVWF FLAG			    ;DE CONTROLE DA MULTIPICACAO PARA UMA
					;NOVA MULTIPLICACAO POR 10
    RETURN

DIVISAO
    CLRF AUXILIAR
    
    MOVLW .9
    MOVWF FLAG			    ;INICIANDO A VARIAVEL DE CONTROLE DA MULTIPLICACAO POR 10

    CALL DIVISAO_ROTINA			    ;CHAMADA RESPONSAVEL PELA DIVISAO INTEIRA

    CALL MULT_10			    ;MULTIPLICA O RESTO DA DIVISAO POR 10 P/ UMA NOVA DIVISAO

    MOVFW AUXILIAR			    ;GUARDA O RESULTADO DA DIVISAO INTEIRA
    MOVWF DIV_INTEIRA			    ;NA VARIAVEL DESTINADA A ARMAZENAR TEMPORARIAMENTE A SAIDA
    CLRF AUXILIAR

    CALL DIVISAO_ROTINA			    ;CHAMADA RESPONSAVEL PELA DIVISAO FRACIONARIA
					    ;DA PRIMEIRA CASA DECIMAL

    CALL MULT_10			    ;MULTIPLICA O RESTO DA DIVISAO POR 10 P/ UMA NOVA DIVISAO

    MOVFW AUXILIAR			    ;GUARDA O RESULTADO DA DIVISAO FRACIONARIA
    MOVWF DIV_FRAC_1			    ;NA VARIAVEL DESTINADA A ARMAZENAR TEMPORARIAMENTE A SAIDA
    CLRF AUXILIAR				    

    CALL DIVISAO_ROTINA			    ;CHAMADA RESPONSAVEL PELA SEGUNDA CASA DECIMAL DA DIVISAO

    MOVFW AUXILIAR
    MOVWF DIV_FRAC_2
    SUBLW .9			    ;SUBTRAI 9 PELA 2 CASA DECIMAL DA DIVISAO

    BTFSS STATUS, C			;SE O RESTO DA DIVISAO DA 2 CASA
    INCF DIV_FRAC_1, F			;FOR MAIOR QUE 9, INCREMENTA EM 1
					;A PRIMEIRA CASA DECIMAL
    MOVFW AUXILIAR
    SUBLW .9
    
    BTFSS STATUS, C
    CLRF DIV_FRAC_2

    MOVFW DIV_FRAC_1
    SUBLW .9

    BTFSS STATUS, C			    ;SE O RESTO DA DIVISAO DA 2 CASA
    CLRF DIV_FRAC_1			    ;FOR MAIOR QUE 9, INCREMENTA EM 1
					;A PARTE INTEIRA

    BTFSC DIV_FRAC_1, Z
    INCF DIV_INTEIRA

    RETURN
    
    
MEDIA					    ; MEDIA CALCULADA COM 2 CASAS DECIMAIS
    MOVLW .32
    MOVWF ITERATOR
    MOVLW h'2F'
    MOVWF FSR
    CLRF RESTO
    
    MEDIA_ROUTINE
    
	MOVFW INDF			    ; LE O VALOR DA RAM PARA DIVISAO POR 32
	MOVWF RESTO
	
	CALL DIVISAO
	
	CALL SALVA_MEDIA
	
	DECFSZ ITERATOR, F
	GOTO MEDIA_ROUTINE
	
	MOVLW .32
	MOVWF ITERATOR
	
	MOVFW MEDIA_INTEIRA
	MOVWF DADO
	MOVLW h'2A'
	
	CALL GRAVA_EEPROM
	
	RETURN   
	
	
SALVA_MEDIA

    MOVFW DIV_FRAC_2
    ADDWF MEDIA_FRAC_2, F		; GUARDA E SOMA A SEGUNDA CASA DAS M�DIAS PARCIAIS
    
    MOVFW DIV_FRAC_1
    ADDWF MEDIA_FRAC_1, F		; GUARDA E SOMA A PRIMEIRA CASA DAS M�DIAS PARCIAIS
    
    MOVFW DIV_INTEIRA
    ADDWF MEDIA_INTEIRA, F		; GUARDA E SOMA A PARTE INTEIRA DAS M�DIAS PARCIAIS
    
    SALVA_MEDIA_FRAC_2			;TRANSFORMA A 2 CASA EM 1 DIGITO
    
	MOVLW .10
	SUBWF MEDIA_FRAC_2, W

	BTFSS STATUS, C
	GOTO SALVA_MEDIA_FRAC_1
	GOTO SALVA_MEDIA_FRAC_2_SEM_ESTOURO
	
	
	SALVA_MEDIA_FRAC_2_SEM_ESTOURO
	
	    MOVWF MEDIA_FRAC_2
	    INCF MEDIA_FRAC_1
	    GOTO SALVA_MEDIA_FRAC_2
	
    SALVA_MEDIA_FRAC_1			;TRANSFORMA A 1 CASA EM 1 DIGITO
    
	MOVLW .10
	SUBWF MEDIA_FRAC_1, W

	BTFSS STATUS, C
	RETURN
	GOTO SALVA_MEDIA_FRAC_1_SEM_ESTOURO
	
	
	SALVA_MEDIA_FRAC_1_SEM_ESTOURO
	
	    MOVWF MEDIA_FRAC_1
	    INCF MEDIA_INTEIRA
	    GOTO SALVA_MEDIA_FRAC_1
	    
    RETURN	
	
COUNT_1MS				; INCREMENTA O TAU A CADA 1MS 
	INCF TEMPO
	MOVLW .0
	MOVWF TMR0
	RETURN
	
WAIT_400MS				; ESPERA 400MS
	
	MOVLW .60
	MOVWF TMR0
	CALL TIME_WAIT
	MOVLW .60			    
	MOVWF TMR0
	CALL TIME_WAIT
	
	MOVLW .60
	MOVWF TMR0
	CALL TIME_WAIT
	MOVLW .60			    
	MOVWF TMR0
	CALL TIME_WAIT
	
	MOVLW .60
	MOVWF TMR0
	CALL TIME_WAIT
	MOVLW .60			    
	MOVWF TMR0
	CALL TIME_WAIT
	
	MOVLW .124
	MOVWF TMR0
	CALL TIME_WAIT
	
	
TIME_WAIT			;FUNCAO QUE TEM O PAPEL DE ESPERAR
				
	BTFSS INTCON, T0IF
	GOTO TIME_WAIT
	BCF INTCON, T0IF
	RETURN

ROTINA_LEITURAS
	
	CALL PULSE
	DECFSZ LEITURAS, F
	GOTO ROTINA_LEITURAS
	
	RETURN
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIO DO PROGRAMA                          *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	
INICIO
	BANK1				;ALTERA PARA O BANCO 1
	MOVLW	B'00000010'	;CONFIGURA TODAS AS PORTAS DO GPIO (PINOS)
	MOVWF	TRISIO		;COMO SA�DAS
	MOVLW	B'00010010'
	MOVWF	ANSEL 		;DEFINE PORTAS COMO Digital I/O
	MOVLW	B'00000111'
	MOVWF	OPTION_REG	;DEFINE OP��ES DE OPERA��O
	MOVLW	B'00000000'
	MOVWF	INTCON		;DEFINE OP��ES DE INTERRUP��ES
	MOVLW	B'10001011'		;CONFIGURA O COMPARADOR
	MOVWF	VRCON			;HIGH - N 11 - VREF = 2.97 V
	BANK0				;RETORNA PARA O BANCO
	MOVLW	B'00000111'
	MOVWF	CMCON		;DEFINE O MODO DE OPERA��O DO COMPARADOR ANAL�GICO
	MOVLW	B'00000101'
	MOVWF	ADCON0 
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIALIZA��O DAS VARI�VEIS                 *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     ROTINA PRINCIPAL                            *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
MAIN
	MOVLW h'2F'
	MOVWF FSR
	MOVLW .33
	MOVWF LEITURAS
	CALL ROTINA_LEITURAS
	CALL MEDIA

FIM
	GOTO FIM

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                       FIM DO PROGRAMA                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	END
