;---------------------------------------------------
TITLE       P10NMSCR (EXE) Inverse video, blink and screen scroll
;---------------------------------------------------
            .MODEL  SMALL
            .STACK  64

;---------------------------------------------------
        .DATA
NAMEPAR     LABEL   BYTE
MAXNLEN     DB      20          ; name max lenght
ACTNLEN     DB      ?           ; name actual lenght
NAMEFLD     DB      20 DUP(' ') ; name storage area

COUNT       DB      ?
PROMPT      DB      'Name? '

COL         DB      00
ROW         DB      00

;---------------------------------------------------
        .CODE

BEGIN   PROC FAR

        MOV     AX, @data
        MOV     DS, AX
        MOV     ES, AX
        
        MOV     AX, 0600h
        CALL    Q10SCR          ; clear screen

A20LOOP:
        MOV     COL, 00
        CALL    Q20CURS         ; set cursor position

        CALL    B10PRMP         ; name prompt
        CALL    D10INPT
        
        CMP     ACTNLEN, 00     ; name entered ?
        JNE     A30             ; no: display name

        MOV     AX, 0600h
        CALL    Q10SCR          ; yes: clear screen
        
        MOV     AX, 4C00h       ; exit
        INT     21h

A30:
        CALL    E10NAME
        JMP     A20LOOP
BEGIN   ENDP


; name prompt
;---------------------------------------------------
B10PRMP PROC    NEAR
        LEA     SI, PROMPT
        MOV     COUNT, 06

B20:
        MOV     BL, 71h         ; inverse video
        CALL    F10DISP         ; display name
        INC     SI
        
        INC     COL
        CALL    Q20CURS         ; set cursor position
        
        DEC     COUNT
        JNZ     B20             ; loop 05 times
        RET
B10PRMP ENDP


; name imput
;---------------------------------------------------
D10INPT PROC    NEAR
        MOV     AH, 0Ah
        LEA     DX, NAMEPAR
        INT     21h             ; keyboard input
        RET
D10INPT ENDP


; name display
;---------------------------------------------------
E10NAME PROC    NEAR
        LEA     SI, NAMEFLD
        MOV     COL, 40
E20:
        CALL    Q20CURS
        MOV     BL, 0F1h        ; blink, inverted video
        CALL    F10DISP         ; display name
        INC     SI
        INC     COL

        DEC     ACTNLEN
        JNZ     E20             ; loop

        CMP     ROW, 20         ; row >= 20 ?
        JAE     E30             ; yes: diplay trail
        INC     ROW             ; no: next row
        RET
E30:
        MOV     AX, 0601h
        CALL    Q10SCR          
        RET
E10NAME  ENDP


; display a character
;---------------------------------------------------
F10DISP PROC    NEAR
        MOV     AH, 09h
        MOV     AL, [SI]        ; name pointer
        MOV     BH, 00          ; page 0
        MOV     CX, 01          ; 1 char
        INT     10h             ; display a char of the name
        RET
F10DISP ENDP


; clear screen
;---------------------------------------------------
Q10SCR  PROC    NEAR
        MOV     BH, 17h         ; white letters, blue background
        MOV     CX, 0000        ; upper-left corner
        MOV     DX, 184Fh       ; bottom-right corner
        INT     10h             ; full screen
        RET
Q10SCR  ENDP


; set cursor position
;---------------------------------------------------
Q20CURS PROC    NEAR
        MOV     AH, 02h
        MOV     BH, 00          ; page
        MOV     DH, ROW         ; row
        MOV     DL, COL         ; column
        INT     10h
        RET
Q20CURS ENDP

        END BEGIN

