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
                db '|                                                          |', CRET, CF
                db ' ----------------------------------------------------------', CRET, CF, CF,'$'

overflow_msg db ' ! Overflow !   $'
ax_ db 'ax = $'
bx_ db 'bx = $'
cx_ db 'cx = $'
dx_ db 'dx = $'

ss_ db 'ss = $'
ds_ db 'ds = $'
es_ db 'es = $'
cs_ db 'cs = $'

sf_of db 'OF = $'
sf_df db 'DF = $'
sf_if db 'IF = $'
sf_tf db 'TF = $'
sf_sf db 'SF = $'
sf_zf db 'ZF = $'
sf_af db 'AF = $'
sf_pf db 'PF = $'
sf_cf db 'CF = $'


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

mov al, 0ffh
mov bl, 1fh
add al, bl
int 4h

into

int 4h

;   -----------------------------
; /     
; |     Replace custom interrupt with standard
; \ 
;   -----------------------------
lds dx, old_INT
mov ah, 25h
mov al, INT_No
int 21h

; Exit
mov ax, 4c00h
int 21h


;   -----------------------------
; /
; |     Custom INT 4 procedure
; \
;   -----------------------------
INT_4 proc far
push ds
push es
push ss
push bp
push sp
push ax
push bx
push cx
push dx
 ; bp + 0 = dx
 ; bp + 2 = cx
 ; bp + 4 = bx
 ; bp + 6 = ax
 ; bp + 8 = sp
 ; bp + 10 = bp
 ; bp + 12 = ss
 ; bp + 14 = es
 ; bp + 16 = ds
 ; bp + 18 = ip
 ; bp + 20 = cs
 ; bp + 22 = sf

    lea dx, overflow_msg
    mov ah, 09h
    int 21h

    mov bp, sp

    mov ax, [bp + 20]
    call PrintNum

    mov ah, 02h
    mov dl, ':'
    int 21h

    mov ax, [bp + 18]
    sub ax, 1
    call PrintNum

    mov ah, 02h
    mov dl, ' '
    int 21h

    mov ax, [bp + 18]
    sub ax, 1
    mov bx, ax
    xor ax, ax
    mov ax, cs:[bx]
    call PrintNum

    mov ah, 02h
    mov dx, CF
    int 21h
    mov dx, CRET
    int 21h

    call PrintRegs
    call PrintSF

pop dx
pop cx
pop bx
pop ax
pop sp
pop bp
pop ss
pop es
pop ds
jmp old_INT
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

;   -----------------------------
; /
; |     Print registers.
; \
;   -----------------------------
PrintRegs PROC
 ; bp + 0 = dx
 ; bp + 2 = cx
 ; bp + 4 = bx
 ; bp + 6 = ax
 ; bp + 8 = sp
 ; bp + 10 = bp
 ; bp + 12 = ss
 ; bp + 14 = es
 ; bp + 16 = ds
 ; bp + 18 = ip
 ; bp + 20 = cs
 ; bp + 22 = sf

    ; --------- base registers
    lea dx, ax_
    mov ah, 09h
    int 21h
    mov ax, [bp + 6]
    call PrintNum
    mov ah, 02h
    mov dl, ' '
    int 21h

    lea dx, bx_
    mov ah, 09h
    int 21h
    mov ax, [bp + 4]
    call PrintNum
    mov ah, 02h
    mov dl, ' '
    int 21h

    lea dx, cx_
    mov ah, 09h
    int 21h
    mov ax, [bp + 2]
    call PrintNum
    mov ah, 02h
    mov dl, ' '
    int 21h

    lea dx, dx_
    mov ah, 09h
    int 21h
    mov ax, [bp + 0]
    call PrintNum

    mov ah, 02h
    mov dl, CF
    int 21h
    mov dl, CRET
    int 21h

    ; ---------- segments
    lea dx, cs_
    mov ah, 09h
    int 21h
    mov ax, [bp + 20]
    call PrintNum
    mov ah, 02h
    mov dl, ' '
    int 21h

    lea dx, ds_
    mov ah, 09h
    int 21h
    mov ax, [bp + 16]
    call PrintNum
    mov ah, 02h
    mov dl, ' '
    int 21h

    lea dx, es_
    mov ah, 09h
    int 21h
    mov ax, [bp + 14]
    call PrintNum
    mov ah, 02h
    mov dl, ' '
    int 21h

    lea dx, ss_
    mov ah, 09h
    int 21h
    mov ax, [bp + 12]
    call PrintNum

    mov ah, 02h
    mov dl, CF
    int 21h
    mov dl, CRET
    int 21h
ret
PrintRegs ENDP

;   -----------------------------
; /
; |     Print registers.
; \
;   -----------------------------
PrintSF PROC
    mov bx, [bp + 22]

    lea dx, sf_of
    mov ah, 09h
    int 21h
    mov dx, bx
    and dx, 0800h  ; 0000 1000 0000 0000
    mov cl, 11
    shr dx, cl
    add dl, 48
    mov ah, 02h
    int 21h
    mov dl, ' '
    int 21h

    lea dx, sf_df
    mov ah, 09h
    int 21h
    mov dx, bx
    and dx, 0400h  ; 0000 0100 0000 0000
    mov cl, 10
    shr dx, cl
    add dl, 48
    mov ah, 02h
    int 21h
    mov dl, ' '
    int 21h

    lea dx, sf_if
    mov ah, 09h
    int 21h
    mov dx, bx
    and dx, 0200h  ; 0000 0010 0000 0000
    mov cl, 9
    shr dx, cl
    add dl, 48
    mov ah, 02h
    int 21h
    mov dl, ' '
    int 21h

    lea dx, sf_tf
    mov ah, 09h
    int 21h
    mov dx, bx
    and dx, 0100h  ; 0000 0001 0000 0000
    mov cl, 8
    shr dx, cl
    add dl, 48
    mov ah, 02h
    int 21h
    mov dl, ' '
    int 21h

    lea dx, sf_sf
    mov ah, 09h
    int 21h
    mov dx, bx
    and dx, 0080h  ; 0000 0000 1000 0000
    mov cl, 7
    shr dx, cl
    add dl, 48
    mov ah, 02h
    int 21h
    mov dl, ' '
    int 21h

    lea dx, sf_zf
    mov ah, 09h
    int 21h
    mov dx, bx
    and dx, 0040h  ; 0000 0000 0100 0000
    mov cl, 6
    shr dx, cl
    add dl, 48
    mov ah, 02h
    int 21h
    mov dl, ' '
    int 21h

    lea dx, sf_af
    mov ah, 09h
    int 21h
    mov dx, bx
    and dx, 0010h  ; 0000 0000 0001 0000
    mov cl, 4
    shr dx, cl
    add dl, 48
    mov ah, 02h
    int 21h
    mov dl, ' '
    int 21h

    lea dx, sf_pf
    mov ah, 09h
    int 21h
    mov dx, bx
    and dx, 0004h  ; 0000 0000 0000 0100
    mov cl, 2
    shr dx, cl
    add dl, 48
    mov ah, 02h
    int 21h
    mov dl, ' '
    int 21h

    lea dx, sf_pf
    mov ah, 09h
    int 21h
    mov dx, bx
    and dx, 0001h  ; 0000 0000 0000 0001
    add dl, 48
    mov ah, 02h
    int 21h
    mov dl, ' '
    int 21h

    mov dl, CRET
    int 21h
    mov dl, CF
    int 21h
    mov dl, CF
    int 21h

ret
PrintSF ENDP
; ---------------------------------------------------------------- END ---------------------------------------------------------------------------
end program
