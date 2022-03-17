;---------------------------------------------------
TITLE       P19BIORDT (EXE) Read disk sector (BIOS Interrupt)
;---------------------------------------------------
            .MODEL  SMALL
            .STACK 64

;---------------------------------------------------
        .DATA
CURADR      DW      0304h           ; start track/sector
ENDADR      DW      0501h           ; end track/sector
ENDCDE      DB      00              ; end flag
READMSG     DB      '*** Read error ***', '$'
RECDIN      DB      512 DUP(' ')    ; disk sector area
SIDE        DB      00

;---------------------------------------------------
        .CODE

MAIN    PROC    FAR

        MOV     AX, @data
        MOV     DS, AX
        MOV     ES, AX

        MOV     AX, 0600h

A20LOOP:
        CALL    Q10SCR
        CALL    Q20CURS

        CALL    C10ADDR
        MOV     CX, CURADR
        MOV     DX, ENDADR

        CMP     CX, DX          ; final sector ?
        JE      A90             ; yes: exit

        CALL    F10READ         ; read disk sector

        CMP     ENDCDE, 00      ; successful reading ?
        JNZ     A90             ; no: exit

        CALL    G10DISP         ; display sector
        JMP     A20LOOP

A90:
        MOV     AX, 4C00h
        INT     21h             ; exit
MAIN    ENDP


; calculate disk address
;---------------------------------------------------
C10ADDR PROC    NEAR
        MOV     CX, CURADR      ; gets track/sector

        CMP     CL, 10          ; last sector ?
        JNE     C90             ; no: end
        MOV     CL, 01          ; sector = 1

        CMP     SIDE, 00        ; skip side 0
        JE      C20
        INC     CH              ; track +1
C20:
        XOR     SIDE, 01        ; change side
        MOV     CURADR, CX
C90:
        RET
C10ADDR ENDP


; read disk sector
;---------------------------------------------------
F10READ PROC    NEAR
        MOV     AH, 02h         ; read function
        MOV     AL, 01          ; sector count
        LEA     BX, RECDIN      ; buffer
        MOV     CX, CURADR      ; track/sector
        MOV     DH, SIDE        ; side
        MOV     DL, 02          ; unit C:
        INT     13h

        CMP     AH, 00          ; successful reading ?
        JZ      F90             ; yes
        MOV     ENDCDE, 01      ; no: display error msg
        CALL    X10ERR
F90:
        INC     CURADR          ; sector +1
        RET
F10READ ENDP


; display character
;---------------------------------------------------
G10DISP PROC    NEAR
        MOV     AH, 40h
        MOV     BX, 01          ; STDOUT
        MOV     CX, 512         ; message length
        LEA     DX, RECDIN      ; sector data
        INT     21h             ; display
        RET
G10DISP ENDP


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
        MOV     DX, 0000
        INT     10h
        RET
Q20CURS  ENDP


; display disk error message
;---------------------------------------------------
X10ERR  PROC    NEAR
        MOV     AH, 40h
        MOV     BX, 01          ; STDOUT
        MOV     CX, 18          ; message length
        LEA     DX, READMSG     ; error message
        INT     21h             ; display
        RET
X10ERR  ENDP

        END MAIN
