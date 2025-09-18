.model small
.stack 100h

StdOut = 1
BackL = 0Dh
NewL = 0Ah

.data
welcome db 'Write text: ', '$' ; test
echoMSG db  NewL, BackL, 'Entered: ', '$', NewL, BackL
inputBuf db 255
         db ?
         db 255 dup('$')

.code
main:
    mov ax, @data
    mov ds, ax                  

    mov ah, 09h
    mov dx, offset welcome
    int 21h

    ; Read user input
    mov ah, 0Ah        ; DOS function to read a buffered string
    mov dx, offset inputBuf
    int 21h

    mov ah, 09h
    mov dx, offset echoMSG
    int 21h

    ; The user input length is at inputBuf+1
    ; The user input string starts at inputBuf+2
    ; We need to terminate the string with '$' for function 09h
    mov bl, [inputBuf+1]
    mov bh, 0
    mov si, offset inputBuf+2
    add si, bx
    mov byte ptr [si], '$'

    ; Print the entered string
    mov ah, 09h
    mov dx, offset inputBuf+2
    int 21h

    ; End of program
    mov ah, 4ch
    int 21h
END main
