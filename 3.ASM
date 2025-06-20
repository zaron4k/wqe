format PE console
entry start

include 'win32a.inc'

section '.data' data readable writeable
    array_size = 8                   ; ������ ������� (����� ��������)
    array rd array_size              ; ������ ��� �������� ��������� ������
    input_prompt db 'Enter element %d: ', 0  ; ����������� ��� �����
    output_prompt db 10, 'Modified array: ', 0   ; ��������� ����� ������� �������
    format_input db '%d', 0          ; ������ ��� ����� �����
    format_output db '%d ', 0        ; ������ ��� ������ �����
    min_value dd 0                   ; ���������� ��� �������� ������������ ��������
    max_value dd 0                   ; ���������� ��� �������� ������������� ��������

section '.code' code readable executable
start:
    ; ��� 1: ������ �� ���� ��������� �������
    mov ecx, array_size              ; ���������� ��������� � �������
    lea esi, [array]                 ; ��������� �� ������ �������
    xor ebx, ebx                     ; ������� ��� ������ �������� (�������� � 0)

input_loop:
    inc ebx                          ; ����������� ������� ������ ��������
    push ebx                         ; ��������� ����� �������� ��� ������
    push input_prompt                ; ������ ������ ��� �����������
    call [printf]                    ; ������� ����������� ��� �����
    add esp, 8                       ; ������� ����

    lea eax, [esi + ebx*4 - 4]       ; ����� �������� �������� �������
    push eax                         ; ����� ��� ���������� ���������� �����
    push format_input                ; ������ ��� ����� �����
    call [scanf]                     ; ��������� �����
    add esp, 8                       ; ������� ����

    cmp ebx, array_size              ; ���������, ��� �� �������� �������
    jb input_loop                    ; ���� ���, ���������� ����

    ; ��� 2: ����� ������������ � ������������� ��������
    mov ecx, array_size              ; ���������� ��������� � �������
    lea esi, [array]                 ; ��������� �� ������ �������
    mov eax, [esi]                   ; ��������� ������ ������� �������
    mov ebx, eax                     ; �������������� min � max ������ ���������
    mov [min_value], eax
    mov [max_value], eax

find_min_max:
    lodsd                            ; ��������� ��������� ������� ������� � EAX
    cmp eax, [min_value]             ; ���������� � ������� ���������
    jge not_min                      ; ���� ������ ��� �����, ���������� ���������� ��������
    mov [min_value], eax             ; ��������� �������
not_min:
    cmp eax, [max_value]             ; ���������� � ������� ����������
    jle not_max                      ; ���� ������ ��� �����, ���������� ���������� ���������
    mov [max_value], eax             ; ��������� ��������
not_max:
    loop find_min_max                ; ��������� ��� ���� ���������

    ; ��� 3: ������ ������������ ��������� �� �����������
    mov ecx, array_size              ; ����� ���������� ���������
    lea esi, [array]                 ; ��������� �� ������ �������
replace_max_with_min:
    mov eax, [esi]                   ; ��������� ������� �������
    cmp eax, [max_value]             ; ���������� � ������������ ���������
    jne not_replace                  ; ���� �� �����, ���������� ������
    mov eax, [min_value]             ; �������� �� ����������� ��������
    mov [esi], eax                   ; ��������� ���������� ��������
not_replace:
    add esi, 4                       ; ��������� � ���������� ��������
    loop replace_max_with_min        ; ��������� ��� ���� ���������

    ; ��� 4: ����� ����������� �������
    push output_prompt               ; ��������� ����� ������� �������
    call [printf]                    ; ������� ���������
    add esp, 4                       ; ������� ����

    mov ecx, array_size              ; ���������� ���������
    lea esi, [array]                 ; ��������� �� ������ �������
print_array:
    lodsd                            ; ��������� ������� �������
    push ecx                         ; ��������� ������� �����
    push eax                         ; �������� ��� ������
    push format_output               ; ������ ������ ��� ������
    call [printf]                    ; �������� printf
    add esp, 8                       ; ������� ����
    pop ecx                          ; ��������������� ������� �����
    loop print_array                 ; ��������� ��� ���� ���������

    ; ��������� �������� ������� ������� ����� �����������
    push wait_message                ; ������� ��������� "Press any key to exit..."
    call [printf]
    add esp, 4                       ; ������� ����
    call [getch]                     ; ���� ������� �������

    ; ���������� ���������
    push 0                           ; ��� ��������
    call [ExitProcess]

section '.idata' import data readable
    library kernel32, 'kernel32.dll', msvcrt, 'msvcrt.dll'
    import kernel32, ExitProcess, 'ExitProcess'
    import msvcrt, printf, 'printf', scanf, 'scanf', getch, '_getch'

section '.rdata' data readable
    format_str db '%d ', 0           ; ������ ������ ��� ������ �����
    wait_message db 10, 'Press any key to exit...', 10, 0  ; ��������� ��������
