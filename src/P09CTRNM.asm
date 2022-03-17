;---------------------------------------------------
TITLE       P09CTRNM (EXE) Center the given name on the screen
;---------------------------------------------------
            .MODEL  SMALL
            .STACK  64

;---------------------------------------------------
        .DATA
NAMEPAR     LABEL   BYTE
MAXNLEN     DB      20          ; name max length
NAMELEN     DB      ?           ; name actual length
NAMEFLD     DB      21 DUP(' ') ; name storage area

PROMPT      DB      'Name? ', '$'

;---------------------------------------------------
        .CODE

BEGIN   PROC    FAR

        MOV     AX, @data
        MOV     DS, AX
        MOV     ES, AX
        
        CALL    Q10CLR          ; clear screen

A20LOOP:
        MOV     DX, 0000
        CALL    Q20CURS
        
        CALL    B10PRMP
        CALL    D10INPT
        CALL    Q10CLR

        CMP     NAMELEN, 00     ; name entered ?
        JE      A30             ; no: exit
        CALL    E10CODE         ; si: parse entered text
        CALL    F10CENT         ; text display
        JMP     A20LOOP
A30:
        MOV     AX, 4C00h       ; exit
        INT     21h
BEGIN   ENDP


; name prompt
;---------------------------------------------------
B10PRMP PROC    NEAR
        MOV     AH, 09h
        LEA     DX, PROMPT
        INT     21h             ; display prompt
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


; name processing
;---------------------------------------------------
E10CODE PROC    NEAR
        MOV     BH, 00
        MOV     BL, NAMELEN
        MOV     NAMEFLD[BX], 07
        MOV     NAMEFLD[BX+1], '$' ; delimiter append
        RET
E10CODE ENDP


; centers the name
;---------------------------------------------------
F10CENT PROC NEAR
        MOV     DL, NAMELEN
        SHR     DL, 1           ; half length
        NEG     DL
        ADD     DL, 40
        MOV     DH, 12          ; central row
        CALL    Q20CURS

        MOV     AH, 09h
        LEA     DX, NAMEFLD
        INT     21h             ; text display
        RET
F10CENT ENDP


; clear screen
;---------------------------------------------------
Q10CLR  PROC NEAR
        MOV     AX, 0600h       ; screen scroll
        MOV     BH, 07h         ; white letters, black background
        MOV     CX, 0000        ; upper-left corner
        MOV     DX, 184Fh       ; bottom-right corner
        INT     10h             ; clear screen
        RET
Q10CLR  ENDP


; set cursor position
;---------------------------------------------------
Q20CURS PROC NEAR
        MOV     AH, 02h
        MOV     BH, 00          ; page
        INT     10h
        RET
Q20CURS ENDP

        END BEGIN

