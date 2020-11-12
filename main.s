; ========================================================================================
; | Modulname: main.s 									| Prozessor: LPC1778 	 		 |
; |--------------------------------------------------------------------------------------|
; | Ersteller: 	Simon Hoffmann und Aleksei Svatko		| Datum: 20.10.2020      		 |
; |--------------------------------------------------------------------------------------|
; | Version: 1.0	| Projekt: 	LED Lauflicht			| Assembler: ARM-ASM 	 		 |
; |--------------------------------------------------------------------------------------|
; | Aufgabe: Ein LED Lauflicht erzeugen welches durch knopfdruck aktiviert werden	 |
; | 		kann, sowie die richtung der LEDs Aendern. Durch druecken zweier		 	 |
; | 		knoepfe, soll ein warnlicht erscheinen.					 					 |
; |--------------------------------------------------------------------------------------|
; | Bemerkungen: 									 									 |
; | 											 										 |
; | 											 										 |
; |--------------------------------------------------------------------------------------|
; | Aenderungen: 																		 |
; | 	22.10.2020 		Simon Hoffmann 		Blinkendes LED 			 				     |
; | 	29.10.2020		Aleksei Svatko		LED Lauflicht			 					 |
; |		05.11.2020		Simon Hoffmann		Aktivierung durch Taster					 |
; |		12.11.2020		Aleksei Svatko		LED Richtung und Warnblinker				 |
; ========================================================================================
; ------------------------------- includierte Dateien ------------------------------------
	include LPC1778_REG_ASM.inc	
; ------------------------------- exportierte Variablen ----------------------------------

; ------------------------------- importierte Variablen ----------------------------------

; ------------------------------- exportierte Funktionen ---------------------------------
	export  main
; ------------------------------- importierte Funktionen ---------------------------------

; ------------------------------- symbolische Konstanten ---------------------------------

; ------------------------------ Datensection / Variablen --------------------------------
	
; ------------------------------- Codesection / Programm ---------------------------------
	area	main_s,code
		
main
	;Setzt PINs 8 - 15 als Ausgaenge
	ldr R1, =LPC_GPIO0_DIR
	mov R2, #0x0000FF00
	str R2, [R1]
	
	;Laeuft bis Taster gedrueckt 
	;Ueberprueft ob Tasten gedrueckt wurden um Lauflicht zu starten in verschiedenen richtungen
	;oder wenn beide gedrückt werden ein Warnlicht auslöst
button
	;Prueft ob erster Taster gedrueckt wurde
	ldr R0, =LPC_GPIO0_PIN
	ldr R1, [R0]
	and R6, R1, #0x00010000
	
	;Wartezeit 200ms, Aufruf von Unterprogramm, Speichert naechste Befehl Adresse in LR 
	bl DELAY
	bl DELAY
	
	
	;Prueft ob zweiter Taster gedrueckt wurde
	ldr R0, =LPC_GPIO0_PIN
	ldr R1, [R0]
	and R7, R1, #0x00020000
	
	;Wartezeit 200ms
	bl DELAY
	bl DELAY
	
	
	;Prueft ob erster Taster gedrueckt wurde
	ldr R0, =LPC_GPIO0_PIN
	ldr R1, [R0]
	and R6, R1, #0x00010000
	
	;Beide knoepfe gedrueckt -> Warnblink unterprogramm
	add R8, R6, R7	
	cmp R8, #0x0
	beq WARNBLINK
	
	;Wenn nicht beide gleichzeitig gedrueckt, dann prueft ob erste oder zweite gedrueckt wurde
	cmp R6, #0x00010000
	bne continue
	cmp R7, #0x00020000
	bne continue
	b button

continue
	;Dass Licht 5 Mal durchlaufen lassen
	ldr R5, =0x0005			

	;Schleife fuer setzen des ersten LEDs
lightblink	
	ldr R1, =LPC_GPIO0_SET
	cmp R6, #0x00010000
	bne rightLED
	mov R2, #0x00008000 
	b leftLEDJump
rightLED
	mov R2, #0x00000100			
leftLEDJump
	str R2, [R1]
	
	;Wartezeit 100ms
	bl DELAY

	;Reihenweise LEDs anschalten
LEDsequence
	
	cmp R6, #0x00010000
	bne rightblink
	lsr R2, #0x00000001
	add R2, #0x00008000
	b leftblinkJump
	
rightblink
	lsl R2, #0x00000001
	add R2, #0x00000100
leftblinkJump	
	
	str R2, [R1]
	
	;Wartezeit 100ms
	bl DELAY
	
	;Compare ob alle LEDs leuchten
	cmp R2, #0x0000ff00
	bne LEDsequence
	
	;Wartezeit 200ms
	bl DELAY
	bl DELAY
	
	;Ausmachen der LEDs
	ldr R1, =LPC_GPIO0_PIN
	mov R2, #0x0
	str R2, [R1]
	
	;Dass Licht 5 Mal durchlaufen lassen, danach Program ende
	sub R5, #1
	cmp R5, #0
	bgt lightblink
	
	;Springt zurueck zu Taster abfrage
	b button

;Unterprogramm Warteschleife
DELAY
	;Wartezeit 100ms
	ldr R4, =0x000927C0
	align 4
delay100
	sub	R4, #1 		
	cmp R4, #0		
	bgt delay100
	
	;Springt zurueck zu PC der in LR gespeichert ist
	bx LR
	
;Unterprogramm Warnlicht
WARNBLINK 

;Dass Licht 5 Mal durchlaufen lassen
	ldr R5, =0x0005
	
warnblinkscleife
	ldr R1, =LPC_GPIO0_SET
	;Setzt LED von Innen nach Aussen
	mov R2, #0x00001800
	str R2, [R1]
	bl DELAY
	bl DELAY
	mov R2, #0x00002C00
	str R2, [R1]
	bl DELAY
	bl DELAY
	mov R2, #0x00007E00
	str R2, [R1]
	bl DELAY
	bl DELAY
	mov R2, #0x0000FF00
	str R2, [R1]
	bl DELAY
	bl DELAY
	bl DELAY
	
	;Ausschalten der LEDs
	ldr R1, =LPC_GPIO0_PIN
	mov R2, #0x0
	str R2, [R1]
	
	;Dass Licht 5 Mal durchlaufen lassen, danach Program ende
			
	sub R5, #1
	cmp R5, #0
	bgt warnblinkscleife
	
	b button

	end