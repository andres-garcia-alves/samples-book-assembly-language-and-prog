;---------------------------------------------------
TITLE       P21MOUSE (EXE) Mouse handling
;---------------------------------------------------
            .MODEL  SMALL
            .STACK 64

;---------------------------------------------------
        .DATA
XBINARY     DW      0
YBINARY     DW      0
ASCVAL      DW      ?

DISPDATA    LABEL   BYTE
XMSG        DB      'X = '
XASCII      DW      ?
            DB      '  '
YMSG        DB      'Y = '
YASCII      DW      ?

;---------------------------------------------------
        .286
        .CODE

MAIN    PROC    FAR

        MOV     AX, @data
        MOV     DS, AX
        MOV     ES, AX

        CALL    Q10CLR          ; clear screen
        CALL    B10INIT         ; mouse init

        CMP     AX, 00          ; installed mouse ?
        JE      A90             ; no: exit

A10:
        CALL    D10PTR          ; get mouse pointer

        CMP     BX, 01          ; any clicked botton ?
        JE      A80             ; yes: exit

        CALL    Q20CURS         ; set cursor position
        MOV     AX, XBINARY
        CALL    G10CONV         ; X to ASCII
        MOV     AX, ASCVAL
        MOV     XASCII, AX

        MOV AX, YBINARY
        CALL    G10CONV         ; Y to ASCII
        MOV     AX, ASCVAL
        MOV     YASCII, AX

        CALL    Q30DISP         ; display (X, Y) mouse positions
        JMP     A10

A80:
        CALL    H10HIDE         ; hide mouse pointer

A90:
        CALL    Q10CLR          ; clear screen
        MOV     AX, 4C00h
        INT     21h             ; exit
MAIN    ENDP


; mouse init
;---------------------------------------------------
B10INIT PROC    NEAR
        MOV     AX, 00h
        INT     33h             ; mouse init
        
        CMP     AX, 00          ; installed mouse ?
        JE      B90             ; no: return
        MOV     AX, 01h         ; show mouse pointer
        INT     33h
B90:
        RET
B10INIT ENDP


; get and process mouse positions
;---------------------------------------------------
D10PTR  PROC    NEAR
D20:
        MOV     AX, 03h
        INT     33h             ; get mouse position

        CMP     BX, 01          ; right button clicked?
        JE      D90             ; yes: return

        SHR     CX, 03          ; divide pixels by 8
        SHR     DX, 03          ; divide pixels by 8

        CMP     CX, XBINARY
        JNE     D30

        CMP     DX, YBINARY
        JNE     D20

D30:
        MOV     XBINARY, CX     ; save new position
        MOV     YBINARY, DX

D90:
        RET
D10PTR  ENDP


; convert numbers to ASCII chars
;---------------------------------------------------
G10CONV PROC    NEAR
        MOV     ASCVAL, 2020h   ; fill with empty spaces
        MOV     CX, 10
        LEA     SI, ASCVAL+1

        CMP     AX, CX          ; compare position with 10
        JB      G30             ; lower, skip
        DIV     CL              ; greater, divide by 10
        OR      AH, 30h         ; append the '3' for a numeric ASCII
        MOV     [SI], AH        ; store right byte
        DEC     SI

G30:
        OR      AL, 30h         ; append the '3' for a numeric ASCII
        MOV     [SI], AL        ; store left byte
        RET
G10CONV ENDP


; hide mouse pointer
;---------------------------------------------------
H10HIDE PROC    NEAR
        MOV     AX, 02h
        INT     33h             ; hide mouse pointer
        RET
H10HIDE ENDP


; clear the screen
;---------------------------------------------------
Q10CLR  PROC    NEAR
        MOV     AX, 0600h
        MOV     BH, 30h
        MOV     CX, 0000
        MOV     DX, 184Fh
        INT     10h             ; clear screen
        RET
Q10CLR  ENDP


; set cursor position
;---------------------------------------------------
Q20CURS PROC    NEAR
        MOV     AH, 02h
        MOV     BH, 00
        MOV     DH, 00
        MOV     DL, 25
        INT     10h
        RET
Q20CURS ENDP


; display a message
;---------------------------------------------------
Q30DISP PROC    NEAR
        MOV     AH, 40h
        MOV     BX, 01          ; STDOUT
        MOV     CX, 14          ; message length
        LEA     DX, DISPDATA    ; error message
        INT     21h             ; display
        RET
Q30DISP ENDP

        END MAIN
