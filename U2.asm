.model small
.stack 100h

; --------------------------- DATA ----------------------------------
CF = 10
CR = 13

.data
    buffer db 255           ;  Buffer max length
           db 0             ;  String length    
           db 255 dup(?)    ;  Reservation



    help_message db 'Start program with "program_name input_file output_file" command', CR, CF
                 db 'Where program_name - program file name (example: u2.exe)', CR, CF
                 db 'Input_file - file with text where search (example: input.txt)', CR, CF
                 db 'Output_file - file where replaced text will be saved (example: output.txt)', CR, CF, '$'

    result_message db 'Results saved to: $'

; ---------------------------- CODE ---------------------------------------

.code 
    PROGRAM:
        mov ax, @data
        mov ds, ax

        mov cl, es:80h  ; Get length of input parameters
        cmp cl, 0
        je PRINT_HELP
        
        mov si, 82h  ; Start of parameters string

        WHILE1:
            mov ax, es:[si]

            cmp al, 20h  ; Space handling
            je CONTINUE1

            cmp al, 13  ; Enter handling
            je EXIT

            cmp ax, "?/"
            je PRINT_HELP

            CONTINUE1:  ; Read next
            inc si 
            jmp WHILE1



    PRINT_HELP:
        mov ax, 0900h
        mov dx, offset help_message
        int 21h
        mov al, 44 ; Exit code

    EXIT:
        mov ah, 4ch
        int 21h
end PROGRAM

; ------------------------ PROCEDURES --------------------------------

