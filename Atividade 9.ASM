;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*              MODIFICAÇÕES PARA USO COM 12F675                   *
;*                FEITAS PELO PROF. MARDSON                        *
;*                     MARÇO DE 2024                               *
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

;Aplicar um divisor de tensão onde, R1 = 2R e R2 = R, ou seja,
;R1 deve possuir o dobro da resistência de R2, tal que a tensão que alimenta
;o PIC seja a tensão em R2	
	
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     ARQUIVOS DE DEFINIÇÕES                      *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
#INCLUDE <p12f675.inc>	;ARQUIVO PADRÃO MICROCHIP PARA 12F675

	__CONFIG _BODEN_OFF & _CP_OFF & _PWRTE_ON & _WDT_ON & _MCLRE_ON & _INTRC_OSC_NOCLKOUT

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
		COUNT_WDT	;CONTADOR DE WATCHDOG
		COUNT_LOW	;CONTADOR DE TENSÃO MENOR QUE 9V
		;NOVAS VARIÁVEIS

	ENDC			;FIM DO BLOCO DE MEMÓRIA
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                        FLAGS INTERNOS                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINIÇÃO DE TODOS OS FLAGS UTILIZADOS PELO SISTEMA

#DEFINE CONVERSION_START ADCON0, 1
#DEFINE CONV_ON_OFF	 ADCON0, 0	
	
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
	
	BANK1				;TRANFORMA A PORTA DE COMUCAÇÃO EM SAIDA
	BCF TRISIO, 4			;E MANDA SINAL 0V, PARA SINALIZAR QUE 
					;EXISTE UM PIC ATIVO
	BANK0
	BCF GPIO, GP4		    
	BCF INTCON, GPIE		;DESATIVA A INTERRUPÇÃO POR PORTA
	BCF INTCON, GPIF		;LIMPA O BIT DE INTERRUPÇÃO POR PORTA
	BSF INTCON, GPIE		;ATIVA A INTERRUPÇÃO POR PORTA
	
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
	BANK1				;ACESSO VIA BANK 1
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

VERIFICA_SINAL_GP4			    ;VERIFICA A PORTA DE COMUNICAÇÃO
					    ;SE A PORTA ESTIVER LOW, EXISTE UM PIC ATIVO
	BANK1				    ;SE A PORTA ESTIVER HIGH, NÃO HÁ PICS ATIVOS
	BSF TRISIO, 4
	BANK0
	
	BTFSS GPIO, GP4
	GOTO PICS_SIMULTANEOS
	GOTO PIC_UNICO
	
PICS_SIMULTANEOS			    ;FAZ COM QUE O PIC ADORMEÇA POIS JÁ
					    ;EXISTE UM PIC ATIVO
	SLEEP
	NOP
	GOTO VERIFICA_SINAL_GP4

PIC_UNICO				    ;TRANSFORMA GP4 EM SAIDA, E MANDA 0V
					    ;E LIGA O LED GP5
	BANK1				    ;PARA SINALIZAR QUE HÁ UM PIC ATIVO
	BCF TRISIO, 4
	BANK0
	BCF GPIO, GP4
	
	BSF GPIO, GP5
	
	GOTO INICIO_VERIFICACAO

VERIFICA_ALARME
	CLRWDT
	ALARME
	
	    BSF CONV_ON_OFF			; LIGA O MODULO DE CONVERSÃO
	    BSF CONVERSION_START		; INICIA A CONVERSÃO 
	    BTFSC CONVERSION_START		; E ESPERA ATÉ O TÉRMINO
	    GOTO $-1
	    
	    MOVFW   ADRESH
	    BCF	    CONV_ON_OFF			; DESLIGA O MODULO DE CONVERSÃO
	    
	    SUBLW   .153			;VERIFICA SE A TENSÃO É MAIOR QUE
	    BTFSS   STATUS, C			;3V, QUE CORRESPONDE A 9V,
	    BCF	    GPIO, GP1			;SE SIM, DESLIGA O LED GP1
	    
	    MOVFW   ADRESH
	    SUBLW   .153			;VERIFICA SE A TENSÃO É MENOR QUE
	    BTFSC   STATUS, C			;3V, QUE CORRESPONDE A 9V,
	    CALL    TENSAO_MENOR_9		;SE SIM, LIGA O LED GP1 E INCREMENTA CONTADOR
	    
	    MOVFW   COUNT_WDT
	    SUBLW   .1				;CONTROLA QUANTO TEMPO O PIC
	    BTFSS   STATUS, C			;QUE ESTÁ ATIVO, CONTINUARÁ ATIVO
	    GOTO    $+2
	    GOTO    ALARME
	    
	    CLRF COUNT_WDT
	    CALL COMUTACAO
	    RETURN
	    
TENSAO_MENOR_9					;LIGA LED E INCREMENTA CONTADOR
	    
	INCF	COUNT_LOW
	BSF	GPIO, GP1
	RETURN
	    
VERIFICA_WDT					;CONTROLA A QUANTIDADE DE WDT
	    
	BTFSC STATUS, 4
	RETURN
	
	INCF COUNT_WDT
	RETURN

COMUTACAO					;ROTINA QUE CONTROLA A COMUTAÇÃO ENTRE OS PICS
						;GERA UMA MUDANÇA NA PORTA COMUM, QUE GERARÁ
	BSF GPIO, GP4				;UMA INTERRUPÇÃO NO PIC ADORMECIDO, E O ACORDARÁ
	BCF GPIO, GP5				
	
	CALL WRITE_LOW			    ;ESCREVE NA EEPROM			
	
	BANK1				   
	BSF TRISIO, 4
	BANK0
	
	RETURN
	
WRITE_LOW				    ;ESCREVE O CONTADOR DE TENSAO MENOR 9V
					    ;NA EEPROM
	MOVFW	COUNT_LOW
	MOVWF	DADO
	MOVLW	0x1F
	CALL	GRAVA_EEPROM
	
	RETURN
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIO DO PROGRAMA                          *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	
INICIO
	BANK1				;ALTERA PARA O BANCO 1
	MOVLW	B'00010001'	;CONFIGURA TODAS AS PORTAS DO GPIO (PINOS)
	MOVWF	TRISIO		;COMO SAÍDAS
	MOVLW	B'00010001'
	MOVWF	ANSEL 		;DEFINE PORTAS COMO Digital I/O
	MOVLW	B'00001111'
	MOVWF	OPTION_REG	;DEFINE OPÇÕES DE OPERAÇÃO
	MOVLW	B'10001000'
	MOVWF	INTCON		;DEFINE OPÇÕES DE INTERRUPÇÕES
	MOVLW	B'00010000'
	MOVWF	IOC
	BANK0				;RETORNA PARA O BANCO
	MOVLW	B'00000111'
	MOVWF	CMCON		;DEFINE O MODO DE OPERAÇÃO DO COMPARADOR ANALÓGICO
	MOVLW	B'00000000'	   
	MOVWF	ADCON0 

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIALIZAÇÃO DAS VARIÁVEIS                 *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     ROTINA PRINCIPAL                            *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
MAIN

	CALL VERIFICA_SINAL_GP4
INICIO_VERIFICACAO
	CALL VERIFICA_WDT
	CALL VERIFICA_ALARME
	GOTO MAIN
FIM
	GOTO FIM

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                       FIM DO PROGRAMA                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	END
