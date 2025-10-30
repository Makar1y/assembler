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

ax_m dw ?
bx_m dw ?
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
    lea dx, overflow_msg
    mov ah, 09h
    int 21h

    mov word ptr ax_m, ax
    mov word ptr bx_m, bx

    pop bx
    pop ax
    push ax
    push bx
    sub bx, 1

    call PrintNum
    push dx
    mov ah, 02h
    mov dl, ':'
    int 21h
    pop dx
    mov ax, bx
    call PrintNum

iret
INT_4 endp

;   -----------------------------
; /
; |     Print num in ax.
; \
;   -----------------------------
PrintNum PROC
push ax
push bx
push cx
push dx
push di

    mov bx, 16          ; divisor = 16 for hex
    xor cx, cx          ; digit count = 0

convert_loop:
    xor dx, dx
    div bx              ; AX / 16 → AX = quotient, DX = remainder
    push dx             ; save remainder
    inc cx              ; count digit
    cmp ax, 0
    jne convert_loop

    lea di, buffer
    add di, 4
    sub di, cx
print_loop:
    pop dx
    cmp dl, 9
    jbe digit_is_number
    add dl, 55          ; 10–15 → 'A'–'F' (10+55=65='A')
    jmp print_digit
digit_is_number:
    add dl, 48          ; 0–9 → '0'–'9'
print_digit:
    mov [di], dl
    inc di
    loop print_loop

    ; print
    mov ah, 09h
    lea dx, buffer
    int 21h
    call CLEAR_BUFF

pop di
pop dx
pop cx
pop bx
pop ax
ret
PrintNum ENDP

;description
CLEAR_BUFF PROC
    lea di, buffer

Clear_loop:
    cmp ds:[di], '$'
    je Return
    mov byte ptr [di], '0'
    inc di
    jmp Clear_loop

    Return:
ret
CLEAR_BUFF ENDP

; ---------------------------------------------------------------- END ---------------------------------------------------------------------------
end program
