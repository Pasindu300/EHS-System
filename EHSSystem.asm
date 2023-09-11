ORG 0000H
LJMP 0300H
ORG 0003H
    LCALL ISR
    LJMP 0300H
    RETI

ORG 000BH
     DJNZ R4, DOWN
     CLR P1.2           ; V3 Closes
     CLR P1.3           ; M1 Stops
     LJMP STOP
DOWN:LJMP HERE3
     RETI
     
ORG 0300H

 WaterLVL EQU  P0.0
 SOAPLVL  EQU  P0.1
 LEDWATER EQU  P1.4
 LEDSOAP  EQU  P1.6
 BUZZER   EQU  P1.5
 Valve1   EQU  P1.0
 Valve2   EQU  P1.1
 Valve3   EQU  P1.2
 AIRBLWR  EQU  P1.3
 IROUT    EQU  P0.2
 STRTBTN  EQU  P0.3
 TMPLED   EQU  P1.7

CLR P1.4
CLR P1.5
CLR P1.6
CLR P1.0
CLR P1.1
CLR P1.2
CLR P1.3
SETB P0.0
SETB P0.1
SETB P0.2
SETB P0.3
START: JB P0.3,START
       MOV IP, #01H
       MOV TCON, #01H
       MOV IE, #81H
       
WATER: JB P0.0,NEXT    ; Check if water is empty
       SJMP SOAP
NEXT: SETB P1.4         ; Turn on LED Indicator for water level
      SETB P1.5         ; Sound Alarm
      SJMP WATER 
SOAP: JB P0.1,NEXT1    ; Check if soap is empty  
      SJMP MAIN         
NEXT1:SETB P1.6         ; Turn on LED indicator for soap level
      SETB P1.5         ; Sound Alarm
      SJMP SOAP
      
ALARM:SETB P1.5
      SETB P1.7
MAIN: MOV P2,#0FFH     ; P2 Input
      CLR P3.7 ; make CS=0
      SETB P3.6 ; Make RD High
      CLR P3.5  ; Make WR low
      SETB P3.5 ; WR low to high
WAIT: JB P3.4,WAIT ; polls until INTR = 0
      CLR P3.7 
      CLR P3.6 
      MOV A,P2
      MOV R1,A
      CJNE R1,#1AH ,ALARM

BEGIN: JNB P0.2,BEGIN     ; Waiting for Human arm
       SETB P1.0          ; V1 Open
       ACALL DELAY
       CLR P1.0           ; V1 Close
       SETB P1.1          ; V2 Open
       ACALL DELAY
       CLR P1.1           ; V2 Close
       MOV R2,#14H
AGAIN: ACALL DELAY        ; Wait for 20 seconds
       DJNZ R2, AGAIN
       SETB P1.0          ; V1 opens for 20 seconds
       MOV R3,#14H
AGAIN1:ACALL DELAY
       DJNZ R3, AGAIN1
       CLR P1.0           ; V1 Closes
       
       MOV R4,#08CH
       SETB P1.2          ; V3 Opens for 10 seconds
HERE3: MOV TMOD, #11H
       MOV TH0, #00H
       MOV TL0, #00H
       MOV IE, #82H
       SETB TR0
       
MOTOR: SETB P1.3          ; M1 Starts
       MOV R1,#10H
NEXT2: ACALL DELAY1
       DJNZ R1,NEXT2
       CLR P1.3
       MOV R2,#04H 
NEXT3: ACALL DELAY1 
       DJNZ R2,NEXT3
       SJMP MOTOR      
DELAY1: MOV R6,#73H
       MOV R7,#73H
LOOP1: DJNZ R6,LOOP1
LOOP2: DJNZ R7,LOOP2
        RET  

DELAY: MOV R5, #0EH
LOOP:  MOV TMOD,#11H
       MOV TH1,#00H
       MOV TL1,#00H
       SETB TR1
HERE1: JNB TF1,HERE1
       CLR TR1
       CLR TF1
       DJNZ R5,LOOP
       RET

STOP:  SETB P1.5        ; Sound Alarm for 2 seconds
       MOV R4,#02H
HERE:  ACALL DELAY
       DJNZ R4, HERE
       LJMP 0300H

ISR: CLR P1.0
     CLR P1.1
     CLR P1.2
     CLR P1.3
     CLR P1.4
     CLR P1.5
     CLR P1.6
     CLR P1.7
STOP1: JB P0.3, STOP1
     RET
     END
     
                             
