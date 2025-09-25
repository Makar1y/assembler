.model small
.stack 100h

    LNew = 0ah
    LBack = 0dh

.data
    hello_world db 'Hello world!', '$'

.code 
PROGRAM:
    mov ax, @data
    mov ds, ax

    mov ah, 09h
    mov dx, offset hello_world
    int 21h

    mov ax, 4c00h
    int 21h

end PROGRAM
code ends