;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*              MODIFICAÇÕES PARA USO COM 12F675                   *
;*                FEITAS PELO PROF. MARDSON                        *
;*                      OUTUBRO DE 2022                            *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                       NOME DO PROJETO                           *
;*                           CLIENTE                               *
;*         DESENVOLVIDO PELA MOSAICO ENGENHARIA E CONSULTORIA      *
;*   VERSÃO: 1.0                           DATA: 17/06/03          *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     DESCRIÇÃO DO ARQUIVO                        *
;*-----------------------------------------------------------------*
;*   MODELO PARA O PIC 12F675                                      *
;*                                                                 *
;*                                                                 *
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
		DADO		;ARMAZENA O DADO PARA A EEPROM
		
		;NOVAS VARIÁVEIS
		ADRESS_EEPROM
		ITERATOR
		FLAG
		DIV_FRAC_1
		DIV_INTEIRA
		DIV_FRAC_2
		MEDIA_INTEIRA
		MEDIA_FRAC_1
		MEDIA_FRAC_2
		RESTO
		AUXILIAR
		
	ENDC			;FIM DO BLOCO DE MEMÓRIA
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                        FLAGS INTERNOS                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINIÇÃO DE TODOS OS FLAGS UTILIZADOS PELO SISTEMA

#DEFINE CONVERSION_START ADCON0, 1 	

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                         CONSTANTES                              *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINIÇÃO DE TODAS AS CONSTANTES UTILIZADAS PELO SISTEMA
; INICIALIZAÇÃO DA EEPROM, DE ACORDO COM A DESCRIÇÃO NO ARQUIVO "Def_Rega_Formigas.inc"

;A PARTIR DO ENDEREÇO ZERO DA EEPROM, DADOS EM ORDEM ALEATÓRIA
	ORG 0x2100
	DE	0X89,0X1E,0X39,0X9F,0XC2,0X0C,0XAB,0X33,0X63,0XD3,0X95,0X7B,0X38,0XD6,0X1E,0X48
	DE	0XDB,0XD8,0X86,0XFD,0XA5,0XFC,0X0C,0XBE,0X68,0X9B,0XD9,0X10,0XD8,0XEC,0X90,0X91
	DE	0XAA,0XBB,0XCC,0XDD,0XEE,0XF1,0XC9,0X77

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
	
LE_EEPROM
;LER DADO DA EEPROM, CUJO ENDEREÇO É INDICADO EM W
;O DADO LIDO RETORNA EM W
	
	ANDLW	.127		;LIMITA ENDEREÇO MAX. 127
	BANK1			;ACESSO VIA BANK 1
	MOVWF	EEADR		;INDICA O END. DE LEITURA
	BSF	EECON1,RD	;INICIA O PROCESSO DE LEITURA
	MOVF	EEDATA,W	;COLOCA DADO LIDO EM W
	BANK0			;POSICIONA PARA BANK 0
	RETURN

GRAVA_EEPROM
;ESCREVE UM DADO NA EEPROM, CUJO ENDEREÇO É INDICADO EM W
;O DADO A SER ESCRITO DEVE ESTAR ARMAZENADO NA VARIÁVEL DADO
	
	ANDLW	.127		;LIMITA ENDEREÇO MAX. 127
	BANK1			;ACESSO VIA BANK 1
	MOVWF	EEADR
	MOVF	DADO,W
	MOVWF	EEDATA
	BSF	EECON1,WREN	;HABILITA ESCRITA
	BCF	INTCON,GIE	;DESLIGA INTERRUPÇÕES
	MOVLW	B'01010101'	;DESBLOQUEIA ESCRITA
	MOVWF	EECON2		;
	MOVLW	B'10101010'	;DESBLOQUEIA ESCRITA
	MOVWF	EECON2		;
	BSF	EECON1,WR	;INICIA A ESCRITA
AGUARDA
	BTFSC	EECON1,WR	;TERMINOU?
	GOTO	AGUARDA
	BSF	INTCON,GIE	;HABILITA INTERRUPÇÕES
	BANK0			;POSICIONA PARA BANK 0
	RETURN

WRITE_EEPROM
    MOVLW 0x01
    MOVWF ADRESS_EEPROM
    MOVLW .33
    MOVWF ITERATOR
    MOVLW h'2F'
    MOVWF FSR

    WRITE_ROTINE
    
	MOVFW INDF			; MOVE O CONTEUDO DA RAM PARA DADO
	MOVWF DADO			; PARA QUE POSSA SER GRAVADO NA EEPROM
	MOVFW ADRESS_EEPROM
	
	CALL GRAVA_EEPROM
	
	INCF FSR			; INCREMENTA ENDEREÇO DA RAM E DA EEPROM
	INCF ADRESS_EEPROM
	
	DECFSZ ITERATOR, F    
	GOTO WRITE_ROTINE		; CONTROLA A QUANTIDADE DE CONVERSÕES
					; QUE ESTÃO SENDO GRAVADAS NA EEPROM
	
	MOVLW .33
	MOVWF ITERATOR

	RETURN
	    
CONVERSION_AD
    MOVLW .33
    MOVWF ITERATOR
    MOVLW h'2F'
    MOVWF FSR
	
    CONVERSION_AD_ROUTINE
    
	BSF CONVERSION_START		; INICIA A CONVERSÃO 
	BTFSC CONVERSION_START		; E ESPERA ATÉ O TÉRMINO
	GOTO $-1
	
	MOVFW ADRESH			; MOVE O VALOR DA CONVERSÃO PARA RAM
	MOVWF INDF
	
	INCF FSR			; APONTA PRA UM NOVO ENDEREÇO NA RAM
	
	DECFSZ ITERATOR, F		; CONTROLA A QUANTIDADE DE CONVERSÕES			
	GOTO CONVERSION_AD_ROUTINE		
	
	MOVLW .33			; REINICIALIZA A QUANTIDADE DE CONVERSÕES
	MOVWF ITERATOR
	
	RETURN
	
DIVISAO_ROTINA
	
    MOVLW .32			    ;MOVE O DIVISOR PARA W
    SUBWF RESTO, W			    ;SUBTRAI W DO DIVIDENDO

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

    DECFSZ FLAG, F			    ;DECREMENTA A FLAG A CADA SOMA ATÉ UM TOTAL
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
	MOVLW 0x00
	
	CALL GRAVA_EEPROM
	
	RETURN

SALVA_MEDIA

    MOVFW DIV_FRAC_2
    ADDWF MEDIA_FRAC_2, F		; GUARDA E SOMA A SEGUNDA CASA DAS MÉDIAS PARCIAIS
    
    MOVFW DIV_FRAC_1
    ADDWF MEDIA_FRAC_1, F		; GUARDA E SOMA A PRIMEIRA CASA DAS MÉDIAS PARCIAIS
    
    MOVFW DIV_INTEIRA
    ADDWF MEDIA_INTEIRA, F		; GUARDA E SOMA A PARTE INTEIRA DAS MÉDIAS PARCIAIS
    
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
	
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIO DO PROGRAMA                          *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	
INICIO
	BANK1			;ALTERA PARA O BANCO 1
	MOVLW	B'00000100'	;CONFIGURA TODAS AS PORTAS DO GPIO (PINOS)
	MOVWF	TRISIO		;COMO SAÍDAS
	MOVLW	B'00010100'
	MOVWF	ANSEL 		;DEFINE PORTAS COMO Digital I/O
	MOVLW	B'00000000'
	MOVWF	OPTION_REG	;DEFINE OPÇÕES DE OPERAÇÃO
	MOVLW	B'00000000'
	MOVWF	INTCON		;DEFINE OPÇÕES DE INTERRUPÇÕES
	BANK0			;RETORNA PARA O BANCO
	MOVLW	B'00000111'
	MOVWF	CMCON		;DEFINE O MODO DE OPERAÇÃO DO COMPARADOR ANALÓGICO
	MOVLW	B'00001001'
	MOVWF	ADCON0 
	
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIALIZAÇÃO DAS VARIÁVEIS                 *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     ROTINA PRINCIPAL                            *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
MAIN

	CALL CONVERSION_AD
	CALL WRITE_EEPROM
	CALL MEDIA
FIM
	GOTO FIM

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                       FIM DO PROGRAMA                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	END