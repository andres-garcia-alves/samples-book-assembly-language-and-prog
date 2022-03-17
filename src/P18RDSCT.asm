;---------------------------------------------------
TITLE       P18RDSCT (EXE) Read disk sector (DOS Interrupt)
;---------------------------------------------------
            .MODEL  SMALL
            .STACK 64

;---------------------------------------------------
        .DATA
ROW         DB      00
COL         DB      00
XLATAB      DB      30h, 31h, 32h, 33h, 34h, 35h, 36h, 37h, 38h, 39h
            DB      41h, 42h, 43h, 44h, 45h, 46h
READMSG     DB      '*** Read error ***', 0Dh, 0Ah

RDBLOCK     DB      0               ; block struc
RDHEAD      DW      0
RDCYLR      DW      0
RDSECT      DW      8
RDNOSEC     DW      1
RDBUFFR     DW      IOBUFFR
            DW      SEG _DATA
IOBUFFR     DB      512 DUP(' ')    ; disk sector area

;---------------------------------------------------
        .386
        .CODE

MAIN    PROC    FAR

        MOV     AX, @data
        MOV     DS, AX
        MOV     ES, AX

        CALL    Q10SCR
        CALL    Q20CURS

        CALL    B10READ         ; read disk sector

        JNC     A80             ; carry flag disbled ?
        LEA     DX, READMSG     ; no: read error
        CALL    X10ERR
        JMP     A90

A80:
        CALL    C10CONV

A90:
        MOV     AX, 4C00h
        INT     21h             ; exit
MAIN    ENDP


; Read disk sector
;---------------------------------------------------
B10READ PROC    NEAR
        MOV     AX, 440Dh       ; IOCTL for block device
        MOV     BX, 00          ; default drive
        MOV     CH, 08          ; device category
        MOV     CL, 61h         ; function 440Dh, secondary code 61h: read sector
        LEA     DX, RDBLOCK
        INT     21h
        RET
B10READ ENDP


; display character
;---------------------------------------------------
C10CONV PROC    NEAR
        LEA     SI, IOBUFFR
C20:
        MOV     AL, [SI]
        SHR     AL, 04          ; divide by 16
        LEA     BX, XLATAB      ; translation table
        XLAT                    ; translate to HEX
        CALL    Q30DISP         ; display a character

        INC     COL
        MOV     AL, [SI]
        AND     AL, 0Fh         ; clear upper nibble
        XLAT                    ; translate to HEX
        CALL    Q30DISP         ; display a character

        INC     SI
        INC     COL

        CMP     COL, 64         ; column <= 64 ?
        JBE     C20             ; no: loop
        INC     ROW
        MOV     COL, 00
        CALL    Q20CURS
        CMP     ROW, 16         ; row <= 16 ?
        JBE     C20             ; no: loop
        RET
C10CONV ENDP


; clear the screen
;---------------------------------------------------
Q10SCR  PROC    NEAR
        MOV     AX, 0600h
        MOV     BH, 1Eh
        MOV     CX, 0000
        MOV     DX, 184Fh       ; clear screen
        INT     10h
        RET
Q10SCR  ENDP


; set cursor position
;---------------------------------------------------
Q20CURS PROC    NEAR
        MOV     AH, 02h
        MOV     BH, 00
        MOV     DH, ROW
        MOV     DL, COL
        INT     10h
        RET
Q20CURS  ENDP


; display a character
;---------------------------------------------------
Q30DISP PROC    NEAR
        MOV     AH, 02h
        MOV     DL, AL
        INT     21h
        RET
Q30DISP ENDP


; display disk error message
;---------------------------------------------------
X10ERR  PROC    NEAR
        MOV     AH, 40h
        MOV     BX, 01          ; STDOUT
        MOV     CX, 20          ; message length
        INT     21h             ; display message
        INC     ROW
        RET
X10ERR  ENDP

        END MAIN
