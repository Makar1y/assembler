.model small

.data
s_hello db 'Hello world!', '$'

.code
    mov ax, @data
    mov ds, ax

    mov ah, 09h
    mov dx, offset s_hello
    int 21h

    mov ah, 4ch
    int 21h
end