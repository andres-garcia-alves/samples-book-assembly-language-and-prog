;---------------------------------------------------
TITLE   P04ASM2 (EXE) MOV & AND operations
;---------------------------------------------------
        .MODEL SMALL
        .STACK 64

;---------------------------------------------------
        .DATA

FLDA        DW  250
FLDB        DW  125
FLDC        DW  ?


;---------------------------------------------------
        .CODE

BEGIN   PROC    FAR
        MOV     AX, @data
        MOV     DS, AX          ; set DS

        MOV     AX, FLDA        ; a few MOV & AND operations
        ADD     AX, FLDB
        MOV     FLDC, AX

        MOV     AX, 4C00h
        INT     21h             ; exit

BEGIN   ENDP

        END BEGIN
