.model small
.stack 100h
INT_No = 04h
CRET = 13
CF = 10


.data
old_INT dd 4 dup(0)

welcome_message db ' ----------------------------------------------------------', CRET, CF
                db '|                                                          |', CRET, CF
                db '|               Author - Makariy Sinyavskiy                |', CRET, CF
                db '|                                                          |', CRET, CF
                db '|       Program processing overflow procedure (INT 4)      |', CRET, CF
                db '|                                                          |',, CRET, CF
                db ' ----------------------------------------------------------', CRET, CF, CF,'$'

overflow_msg db 'Overflow! $'

; ax_m dw ?
; bx_m dw ?
; fs_m dw ?
buffer db 4 dup('0'), '$'




.code
program:
mov dx, @data
mov ds, dx

lea dx, welcome_message
mov ah, 09h
int 21h

;   -----------------------------
; /
; |     Replace standard interrupt with custom
; \
;   -----------------------------
mov ah, 35h
mov al, INT_No
int 21h

mov word ptr old_INT, bx
mov word ptr old_INT + 2, es
push ds

mov ah, 25h
mov al, INT_No
mov dx, seg INT_4
mov ds, dx
lea dx, INT_4
int 21h

pop ds

;   -----------------------------
; /
; |     Tests)
; \
;   -----------------------------

mov ax, 5FFFh
add ax, 5fffh
into



;   -----------------------------
; /     Replace custom interrupt with standard
; |     Exit program
; \ 
;   -----------------------------
lds dx, old_INT
mov ah, 25h
mov al, INT_No
int 21h

mov ax, 4c00h
int 21h

;   -----------------------------
; /
; |     Custom INT 4 procedure
; \
;   -----------------------------
INT_4 proc far
push bp
mov bp, sp
push ax

    lea dx, overflow_msg
    mov ah, 09h
    int 21h

    mov ax, [bp + 4]
    call PrintNum

    push dx
    mov ah, 02h
    mov dl, ':'
    int 21h
    pop dx

    mov ax, [bp + 2]
    call PrintNum

pop ax
pop bp
iret
INT_4 endp

;   -----------------------------
; /
; |     Print hex num in ax.
; \
;   -----------------------------
PrintNum PROC
push ax
push bx
push cx
push dx
push di

    mov cx, 4           ; Always loop 4 times for 4 hex digits
    mov bx, 16          ; Divisor = 16 (for hex)
    lea di, buffer + 3  ; Start at the rightmost character slot (before '$')

convert_loop:
    xor dx, dx
    div bx              ; AX / 16 -> AX = quotient, DX = remainder (current digit)

    cmp dl, 9
    jbe digit_is_number
    add dl, 55          ; 10–15 -> 'A'–'F' (10+55=65='A')
    jmp store_digit
digit_is_number:
    add dl, 48          ; 0–9 -> '0'–'9'
store_digit:
    mov [di], dl        ; Store digit in buffer (right to left)
    dec di              ; Move to the next slot (left)
    loop convert_loop

    ; print the 4-digit result
    mov ah, 09h
    lea dx, buffer
    int 21h

    ; No need to call CLEAR_BUFF since the entire 4-byte string was overwritten

pop di
pop dx
pop cx
pop bx
pop ax
ret
PrintNum ENDP

; ---------------------------------------------------------------- END ---------------------------------------------------------------------------
end program
