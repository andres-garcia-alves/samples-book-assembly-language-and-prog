;---------------------------------------------------
TITLE   P21SOUND (COM) Plays sounds using the speaker
;---------------------------------------------------
        .MODEL SMALL
        .STACK 64

;---------------------------------------------------
        .DATA

DURTION     DW  1000
TONE        DW  256h


;---------------------------------------------------
        .CODE

MAIN    PROC    FAR
        MOV     AX, @data
        MOV     DS, AX          ; set DS
        MOV     ES, AX          ; set ES

        IN      AL, 61
        PUSH    AX
        CLI                     ; disable interrupts

        CALL    B10SPKR
        
        POP     AX
        OUT     61h, AL
        STI                     ; enable interrupts

        MOV     AX, 4C00h
        INT     21h             ; exit

MAIN    ENDP


; play sounds
;---------------------------------------------------
B10SPKR PROC    NEAR
B20:
        MOV     DX, DURTION

B30:
        AND     AL, 11111100b
        OUT     61h, AL
        MOV     CX, TONE

B40:
        LOOP    B40
        OR      AL, 00000010b
        OUT     61h, AL
        MOV     CX, TONE

B50:
        LOOP    B50
        DEC     DX
        JNZ     B30
        SHL     DURTION, 1
        SHR     TONE, 1
        JNZ     B20
        RET
B10SPKR ENDP

        END MAIN
