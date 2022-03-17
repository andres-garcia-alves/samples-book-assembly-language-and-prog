;---------------------------------------------------
TITLE   P10GRAFX (COM) Fill the screen with horizontal colored lines
;---------------------------------------------------
        .MODEL SMALL


;---------------------------------------------------
        .CODE

        ORG     100h

BEGIN   PROC NEAR

        MOV     AH, 0Fh     
        INT     10h
        PUSH    AX              ; save original video mode

        CALL    B10MODE         ; set graphic mode
        CALL    C10DISP         ; on color
        CALL    D10KEY          ; wait for a keyboard char

        POP     AX
        MOV     AH, 00h
        INT     10h             ; restore original video mode
        
        MOV     AX, 4C00h       ; exit
        INT     21h
BEGIN   ENDP


; set graphic mode
;---------------------------------------------------
B10MODE PROC NEAR
        MOV     AH, 00h
        MOV     AL, 10h
        INT     10h             ; set graphic mode to 640x350

        MOV     AH, 0Bh
        MOV     BH, 00h
        MOV     BL, 07h
        INT     10h             ; gray background
B10MODE ENDP


; lines display
;---------------------------------------------------
C10DISP PROC NEAR
        MOV     BX, 00h         ; page 0
        MOV     CX, 64          ; color, column
        MOV     DX, 70          ; row
C20:
        MOV     AH, 0Ch
        MOV     AL, BL          
        INT     10h             ; color set
        
        INC     CX
        CMP     CX, 576         ; column == 576 ?
        JNE     C20             ; no: repeat
        MOV     CX, 64          ; yes: initial column
        INC     BL              ; next color
        INC     DX              ; next row
        CMP     DX, 280         ; row == 280 ?
        JNE     C20             ; no: repeat
        RET                     ; yes: return
C10DISP ENDP


; wait for a keyboard input
;---------------------------------------------------
D10KEY  PROC NEAR
        MOV     AH, 10h
        INT     16h             ; wait for a keyboard char
        RET
D10KEY  ENDP

        END BEGIN
