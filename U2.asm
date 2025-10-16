.model small
.stack 100h

.data
input_filename1 db 20 dup(0)
input_filename2 db 20 dup(0)
output_filename db 20 dup(0)

help_message db 'Usage: program_name input_file1 input_file2 output_file',13,10,'$'
newline db 13,10,'$'

; ERRORS messages
unknown_err db ' -> ERROR: unknown error!',13,10,'$'
access_denied_err db ' -> ERROR: access denied!',13,10,'$'
not_found_err db ' -> ERROR: file not found!',13,10,'$'
too_much_files_err db ' -> ERROR: too much opened files!',13,10,'$'
incorrect_access db ' -> ERROR: incorrect access mode!',13,10,'$'


.code
program:
    mov ax, @data
    mov ds, ax

    call CL_PARAMS_READ
    cmp al, 1
    je PRINT_HELP

    mov ax, 3d00h       ; Open for reading
    mov dx, offset input_filename1
    call OPEN_ERROR
         jc CALL_ERROR
    push ax             ; Save file descriptor

    mov ax, 3d00h       ; Open for reading
    mov dx, offset input_filename2
        jc CALL_ERROR
    push ax             ; Save file descriptor




EXIT: 
    mov ah, 4Ch
    int 21h

PRINT_HELP:
    mov ah, 09h
    mov dx, offset help_message
    int 21h
    mov al, 01
    jmp EXIT

OPEN_ERROR:
    mov bx, ax      ; save error code
    mov ah, 09h 
    int 21h

    cmp bx, 03h     ; Incorrect path 
    je INC_PATH
    cmp bx, 04h     ; Too much opened files
    je TOO_MUCH_O_F
    cmp bx, 05h     ; Access denied 
    je ACCESS_DENIED
    cmp bx, 0ch     ; Incorrect access mode
    je INC_ACCESS_MODE

    mov dx, offset unknown_err
    jmp ERR_PRINT

INC_PATH:
    mov dx, offset not_found_err
    mov al, 44
    jmp ERR_PRINT

TOO_MUCH_O_F:
    mov dx, offset too_much_files_err
    mov al, 50
    jmp ERR_PRINT

ACCESS_DENIED:
    mov dx, offset access_denied_err
    mov al, 43
    jmp ERR_PRINT

INC_ACCESS_MODE:
    mov dx, offset incorrect_access
    mov al, 51
    jmp ERR_PRINT

ERR_PRINT:
    int 21h     ; Print error
    jmp EXIT    ; Exit program

; --------------------------------------------------------------------
; Read 3 filenames from command line
; Return: AL=0 -> OK, AL=1 -> error/help, jump back
; --------------------------------------------------------------------
CL_PARAMS_READ PROC
    mov si, 80h           ; CL length
    mov cl, es:[si]
    cmp cl, 0
    je ERR_RET            ; no params

    mov si, 82h           ; start of CL text
    call SKIP_SPACES
    mov di, offset input_filename1
    call READ_WORD
    mov byte ptr [di], '$'  ; EOS

    call SKIP_SPACES
    mov di, offset input_filename2
    call READ_WORD
    mov byte ptr [di], '$'  ; EOS

    call SKIP_SPACES
    mov di, offset output_filename
    call READ_WORD
    mov byte ptr [di], '$'  ; EOS

    xor al, al
    ret

ERR_RET:
    mov al, 1
    ret
CL_PARAMS_READ ENDP

; --------------------------------------------------------------------
; Just skip spaces
; Return -> jump back
; --------------------------------------------------------------------
SKIP_SPACES PROC
SKIP_LOOP:
    mov al, es:[si]
    cmp al, ' '
    jne S_DONE
    inc si
    jmp SKIP_LOOP
S_DONE:
    ret
SKIP_SPACES ENDP

; --------------------------------------------------------------------
; Read word to di until space or \n
; Return -> jump back
; --------------------------------------------------------------------
READ_WORD PROC
READ_LOOP:
    mov al, es:[si]
    cmp al, ' '
    je READ_DONE
    cmp al, 13
    je READ_DONE
    mov [di], al
    inc di
    inc si
    jmp READ_LOOP
READ_DONE:
    ret
READ_WORD ENDP

end program
