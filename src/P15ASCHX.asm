;---------------------------------------------------
TITLE       P15ASCHX (COM) Display ASCII characters and their hexadecimal value
;---------------------------------------------------
            .MODEL  SMALL

;---------------------------------------------------
        .DATA
DISPROW     DB      16 DUP(5 DUP (' ')), 0Dh
HEXCTR      DB      00
XLATAB      DB      30h, 31h, 32h, 33h, 34h, 35h, 36h, 37h, 38h, 39h
            DB      41h, 42h, 43h, 44h, 45h, 46h

;---------------------------------------------------
        .CODE

MAIN    PROC    FAR

        MOV     AX, @data
        MOV     DS, AX
        MOV     ES, AX

        CALL    Q10CLR
        LEA     SI, DISPROW

A20LOOP:
        CALL    C10HEX
        CALL    D10DISP

        CMP     HEXCTR, 0FFh    ; last character ?
        JE      A90             ; yes: exit
        INC     HEXCTR          ; no: next char
        JMP     A20LOOP

A90:
        MOV     AX, 4C00h
        INT     21h             ; exit
MAIN    ENDP


; ASCII to HEX
;---------------------------------------------------
C10HEX  PROC    NEAR
        MOV     AH, 00
        MOV     AL, HEXCTR

        MOV     CL, 04
        SHR     AX, CL          ; division by 16

        LEA     BX, XLATAB
        XLAT                    ; traslation
        MOV     [SI], AL        ; store left character

        MOV     AL, HEXCTR
        AND     AL, 0Fh         ; clear upper nibble
        XLAT                    ; translation
        MOV     [SI]+1, AL      ; store right charater
        RET
C10HEX  ENDP


; display character
;---------------------------------------------------
D10DISP PROC    NEAR
        MOV     AL, HEXCTR
        MOV     [SI]+3, AL
        
        CMP     AL, 1Ah         ; EOF character ?
        JE      D20
        CMP     AL, 07h         ; lower than 7 ?
        JB      D30
        CMP     AL, 10h         ; greater or equal than 16 ?
        JAE     D30
D20:
        MOV     BYTE PTR [SI]+3, 20h
D30:
        ADD     SI, 05          ; next cell on the row
        LEA     DI, DISPROW+80
        CMP     DI, SI          ; row is full ?
        JNE     D40             ; no: exit

        MOV     AH, 40h         ; file-handler
        MOV     BX, 01          ; STDOUT (console)
        MOV     CX, 81
        LEA     DX, DISPROW
        INT     21h             ; display
        
        LEA     SI, DISPROW
D40:
        RET
D10DISP ENDP


; clear the screen
;---------------------------------------------------
Q10CLR  PROC    NEAR
        MOV     AX, 0600h
        MOV     BH, 02h         ; green letters, black background
        MOV     CX, 0000        ; upper-left corner
        MOV     DX, 184Fh       ; bottom-right corner
        INT     10h             ; clear screen
        RET
Q10CLR  ENDP

        END MAIN

