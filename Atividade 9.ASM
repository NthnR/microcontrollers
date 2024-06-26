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

;Aplicar um divisor de tens�o onde, R1 = 2R e R2 = R, ou seja,
;R1 deve possuir o dobro da resist�ncia de R2, tal que a tens�o que alimenta
;o PIC seja a tens�o em R2	
	
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     ARQUIVOS DE DEFINI��ES                      *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
#INCLUDE <p12f675.inc>	;ARQUIVO PADR�O MICROCHIP PARA 12F675

	__CONFIG _BODEN_OFF & _CP_OFF & _PWRTE_ON & _WDT_ON & _MCLRE_ON & _INTRC_OSC_NOCLKOUT

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
		COUNT_WDT	;CONTADOR DE WATCHDOG
		COUNT_LOW	;CONTADOR DE TENS�O MENOR QUE 9V
		;NOVAS VARI�VEIS

	ENDC			;FIM DO BLOCO DE MEM�RIA
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                        FLAGS INTERNOS                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINI��O DE TODOS OS FLAGS UTILIZADOS PELO SISTEMA

#DEFINE CONVERSION_START ADCON0, 1
#DEFINE CONV_ON_OFF	 ADCON0, 0	
	
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
	
	BANK1				;TRANFORMA A PORTA DE COMUCA��O EM SAIDA
	BCF TRISIO, 4			;E MANDA SINAL 0V, PARA SINALIZAR QUE 
					;EXISTE UM PIC ATIVO
	BANK0
	BCF GPIO, GP4		    
	BCF INTCON, GPIE		;DESATIVA A INTERRUP��O POR PORTA
	BCF INTCON, GPIF		;LIMPA O BIT DE INTERRUP��O POR PORTA
	BSF INTCON, GPIE		;ATIVA A INTERRUP��O POR PORTA
	
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
	BANK1				;ACESSO VIA BANK 1
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

VERIFICA_SINAL_GP4			    ;VERIFICA A PORTA DE COMUNICA��O
					    ;SE A PORTA ESTIVER LOW, EXISTE UM PIC ATIVO
	BANK1				    ;SE A PORTA ESTIVER HIGH, N�O H� PICS ATIVOS
	BSF TRISIO, 4
	BANK0
	
	BTFSS GPIO, GP4
	GOTO PICS_SIMULTANEOS
	GOTO PIC_UNICO
	
PICS_SIMULTANEOS			    ;FAZ COM QUE O PIC ADORME�A POIS J�
					    ;EXISTE UM PIC ATIVO
	SLEEP
	NOP
	GOTO VERIFICA_SINAL_GP4

PIC_UNICO				    ;TRANSFORMA GP4 EM SAIDA, E MANDA 0V
					    ;E LIGA O LED GP5
	BANK1				    ;PARA SINALIZAR QUE H� UM PIC ATIVO
	BCF TRISIO, 4
	BANK0
	BCF GPIO, GP4
	
	BSF GPIO, GP5
	
	GOTO INICIO_VERIFICACAO

VERIFICA_ALARME
	CLRWDT
	ALARME
	
	    BSF CONV_ON_OFF			; LIGA O MODULO DE CONVERS�O
	    BSF CONVERSION_START		; INICIA A CONVERS�O 
	    BTFSC CONVERSION_START		; E ESPERA AT� O T�RMINO
	    GOTO $-1
	    
	    MOVFW   ADRESH
	    BCF	    CONV_ON_OFF			; DESLIGA O MODULO DE CONVERS�O
	    
	    SUBLW   .153			;VERIFICA SE A TENS�O � MAIOR QUE
	    BTFSS   STATUS, C			;3V, QUE CORRESPONDE A 9V,
	    BCF	    GPIO, GP1			;SE SIM, DESLIGA O LED GP1
	    
	    MOVFW   ADRESH
	    SUBLW   .153			;VERIFICA SE A TENS�O � MENOR QUE
	    BTFSC   STATUS, C			;3V, QUE CORRESPONDE A 9V,
	    CALL    TENSAO_MENOR_9		;SE SIM, LIGA O LED GP1 E INCREMENTA CONTADOR
	    
	    MOVFW   COUNT_WDT
	    SUBLW   .1				;CONTROLA QUANTO TEMPO O PIC
	    BTFSS   STATUS, C			;QUE EST� ATIVO, CONTINUAR� ATIVO
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

COMUTACAO					;ROTINA QUE CONTROLA A COMUTA��O ENTRE OS PICS
						;GERA UMA MUDAN�A NA PORTA COMUM, QUE GERAR�
	BSF GPIO, GP4				;UMA INTERRUP��O NO PIC ADORMECIDO, E O ACORDAR�
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
	MOVWF	TRISIO		;COMO SA�DAS
	MOVLW	B'00010001'
	MOVWF	ANSEL 		;DEFINE PORTAS COMO Digital I/O
	MOVLW	B'00001111'
	MOVWF	OPTION_REG	;DEFINE OP��ES DE OPERA��O
	MOVLW	B'10001000'
	MOVWF	INTCON		;DEFINE OP��ES DE INTERRUP��ES
	MOVLW	B'00010000'
	MOVWF	IOC
	BANK0				;RETORNA PARA O BANCO
	MOVLW	B'00000111'
	MOVWF	CMCON		;DEFINE O MODO DE OPERA��O DO COMPARADOR ANAL�GICO
	MOVLW	B'00000000'	   
	MOVWF	ADCON0 

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIALIZA��O DAS VARI�VEIS                 *
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
