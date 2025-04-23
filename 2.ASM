 format PE console
entry start

include 'D:\fasn\INCLUDE\win32ax.inc'

section '.data' data readable writable
    array rd 10               ; Array to store 10 integers
    len = 10                  ; Length of the array
    count dd 0                ; Counter for pairs
    input_msg db "Enter element %d: ", 0
    output_msg db "Number of adjacent pairs with the same sign: %d", 0

section '.code' code readable executable
start:
    ; Input array elements
    mov ecx, len              ; Loop counter
    lea esi, [array]          ; Address of the array
input_loop:
    push ecx                  ; Save loop counter
    mov eax, len
    sub eax, ecx              ; Calculate current index
    inc eax                   ; Convert to 1-based index for display
    cinvoke printf, input_msg, eax
    lea eax, [esi]            ; Address of the current element
    cinvoke scanf, "%d", eax  ; Read integer from user
    add esi, 4                ; Move to the next element
    pop ecx                   ; Restore loop counter
    loop input_loop

    ; Count pairs of adjacent elements with the same sign
    mov ecx, len - 1          ; Loop counter (length - 1)
    lea esi, [array]          ; Address of the array

count_pairs:
    mov eax, [esi]            ; Load current element
    mov ebx, [esi + 4]        ; Load next element
    xor eax, ebx              ; Check signs (result < 0 if signs differ)
    js skip                   ; If signs differ, skip
    inc dword [count]         ; Increment pair counter
skip:
    add esi, 4                ; Move to the next pair
    loop count_pairs          ; Continue the loop

    ; Output the result
    mov eax, [count]
    cinvoke printf, output_msg, eax

    ; Keep the console open indefinitely
    jmp $                     ; Infinite loop to prevent program exit

section '.idata' import data readable
    library kernel32, 'kernel32.dll', msvcrt, 'msvcrt.dll'
    import kernel32, ExitProcess, 'ExitProcess'
    import msvcrt, printf, 'printf', scanf, 'scanf'