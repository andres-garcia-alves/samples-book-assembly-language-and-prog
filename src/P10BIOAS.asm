;---------------------------------------------------
TITLE       P10BIOAS (COM) Display ASCII characters
;---------------------------------------------------
            .MODEL  SMALL

;---------------------------------------------------
        .DATA
CTR         DB      00
ROW         DB      04
COL         DB      24
MODE        DB      ?

;---------------------------------------------------
        .CODE

BEGIN   PROC    FAR

        MOV     AX, @data
        MOV     DS, AX
        MOV     ES, AX
        
        CALL    B10MODE
        CALL    C10CLR

A20:
        CALL    D10SET
        CALL    E10DISP
        
        CMP     CTR, 0FFh       ; last character ?
        JE      A30             ; yes: exit
        INC     CTR             ; continue
        ADD     COL, 02

        CMP     COL, 56         ; last column ?
        JNE     A20             ; no: continue
        INC     ROW
        
        MOV     COL, 24
        JMP     A20

A30:
        CALL    F10READ         ; wait for a keyboard char
        CALL    G10MODE         ; restore mode mode
        MOV     AX, 4C00h
        INT     21h             ; exit
BEGIN   ENDP


; save current & change the video mode
;---------------------------------------------------
B10MODE PROC    NEAR
        MOV     AH, 0Fh
        INT     10h             ; current video mode
        MOV     MODE, AL        ; save video mode
        
        MOV     AH, 00h
        MOV     AL, 03h
        INT     10h             ; new video mode        
        RET
B10MODE ENDP


; clear the screen, draw a window
;---------------------------------------------------
C10CLR PROC     NEAR
        MOV     AH, 08h
        INT     10h             ; current attibute
        MOV     BH, AH
        
        MOV     AX, 0600h
        MOV     CX, 0000
        MOV     DX, 184Fh
        INT     10h             ; clear screen

        MOV     AX, 0610h
        MOV     BH, 20h         ; green foreground, black background 17h
        MOV     CX, 0417h       ; position 04:24
        MOV     DX, 1337h       ; position 19:54
        INT     10h             ; 
        RET
C10CLR ENDP


; set cursor position
;---------------------------------------------------
D10SET  PROC    NEAR
        MOV     AH, 02h
        MOV     BH, 00          ; page
        MOV     DH, ROW         ; row
        MOV     DL, COL         ; column
        INT     10h
        RET
D10SET  ENDP


; display a character
;---------------------------------------------------
E10DISP PROC    NEAR
        MOV     AH, 0Ah
        MOV     AL, CTR         ; ASCII character
        MOV     BH, 00          ; page 0
        MOV     CX, 01          ; 1 char
        INT     10h             ; display
        RET
E10DISP ENDP


; wait for a keyboard input
;---------------------------------------------------
F10READ PROC    NEAR
        MOV     AH, 10h
        INT     16h             ; wait for a keyboard char
        RET
F10READ ENDP


; wait for a keyboard input
;---------------------------------------------------
G10MODE PROC    NEAR
        MOV     AH, 00h
        MOV     AL, MODE
        INT     10h             ; restore video mode
        RET
G10MODE ENDP

        END BEGIN
