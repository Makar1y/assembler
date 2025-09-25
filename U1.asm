.model small
.stack 100h

.data
    buffer db 255           ;  Buferio max ilgis
           db 0             ;  Ivesto eilucio ilgis     
           db 255 dup(?)    ;  Rezervacija

    welcome db 'Please enter text: $'
    result db 0ah, 0dh, 'Result: $'

    
.code 
PROGRAM:
    mov ax, @data
    mov ds, ax

    mov ah, 09h
    mov dx, offset welcome
    int 21h

    mov dx, offset buffer ; Buferis
    call readL

    mov ah, 09h
    mov dx, offset result
    int 21h

    xor cx, cx
    xor dx, dx
    xor ax, ax
    mov dl, [buffer + 1]

    COUNT:
        cmp cl, dl
        jae EXIT
            xor bx, bx
            mov si, cx
            mov bl, [buffer + 2 + si]

            mov bh, 32
            cmp bl, bh
            jne ELSE1
                call PrintNum
                xor ax, ax
                jmp ENDIF1
            ELSE1:
                inc ax
            ENDIF1:

            inc cl
        jmp COUNT

    EXIT:
        call PrintNum
        mov ax, 4c00h
        int 21h



    ; Read line to dx buffer
readL PROC
    push ax
    mov ah, 0ah
    int 21h

    pop ax
ret
readL ENDP

; Print num in ax.
PrintNum PROC
    push bx
    push cx
    push dx

    xor cx, cx
    xor dx, dx
    xor bx, bx
    mov bx, 10

    WHILE1:
    cmp ax, 0
    je NEXT1
        div bx ;  ax/bx -> dx - module, ax - result
        push dx
        inc cx
        jmp WHILE1
    NEXT1:

    WHILE2:
    cmp cx, 0
    je NEXT2
        pop dx
        mov ah, 02h ; Print char
        add dl, 48
        int 21h
        dec cx
        jmp WHILE2
    NEXT2:

    mov ah, 02h
    mov dx, 32
    int 21h

    pop dx
    pop cx
    pop bx
ret
PrintNum ENDP

end PROGRAM


    ; mov ah, 40h
    ; mov bx, (1)
    ; mov cl, [buffer+1]
    ; xor ch, ch
    ; mov dx, offset buffer + 2
    ; int 21h
