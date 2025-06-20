format PE console
entry start

include 'D:\fasn\INCLUDE\win32ax.inc'

section '.data' data readable writable
    array rd 10               ; ������ ��� �������� 10 ����� �����
    len = 10                  ; ������ ������� (10 ���������)
    duplicate dd 0            ; ���������� ��� �������� ���������� ���������
    input_msg db "Enter element %d: ", 0
    output_msg db "Two identical elements: %d", 0
    no_duplicates_msg db "No duplicates found.", 0  ; ��������� �� ���������� ����������

section '.code' code readable executable
start:
    ; ���� ��������� �������
    mov ecx, len              ; ������������� ������� ����� (10 ��������)
    lea esi, [array]          ; ��������� ����� ������ �������

input_loop:
    push ecx                  ; ��������� ������� �����
    mov eax, len
    sub eax, ecx              ; ��������� ������� ������ (�� 0 �� 9)
    inc eax                   ; ����������� ������ � 1-based (�� 1 �� 10) ��� �����������
    cinvoke printf, input_msg, eax  ; ������� ����������� ��� �����
    lea eax, [esi]            ; ����� �������� �������� �������
    cinvoke scanf, "%d", eax  ; ������ ����� �� ������������
    add esi, 4                ; ��������� � ���������� �������� �������
    pop ecx                   ; ��������������� ������� �����
    loop input_loop           ; ��������� ���� ��� ���� ���������

    ; ����� ���� ���������� ���������
    mov ecx, len - 1          ; ������������� ������� �������� ����� (9 ��������)
    lea esi, [array]          ; ��������� ����� ������ �������
    xor ebx, ebx              ; ���� ��� �������� ������� ���������� (0 = ��� ����������)

outer_loop:
    mov eax, [esi]            ; ������� ������� �������
    mov edx, esi              ; ����� �������� ��������
    add edx, 4                ; ������ ����������� ����� (��������� �������)

inner_loop:
    mov edi, [edx]            ; ��������� ������� �������
    cmp eax, edi              ; ���������� ������� ������� � ����������
    je found_duplicate        ; ���� ������ ��������, ��������� � ����� `found_duplicate`
    add edx, 4                ; ��������� � ���������� �������� �� ���������� �����
    cmp edx, array + len * 4  ; ���������, �� ����� �� �� ������� �������
    jb inner_loop             ; ���� ���, ���������� ���������� ����
    add esi, 4                ; ��������� � ���������� �������� �� ������� �����
    loop outer_loop           ; ��������� ������� ����

    ; ���� ��������� �� �������
    cmp ebx, 0                ; ��������� ���� ����������
    je no_duplicates          ; ���� ���� == 0, ��������� �����������

found_duplicate:
    mov [duplicate], eax      ; ��������� ��������� �������� � ���������� `duplicate`

    ; ����� ����������
    mov eax, [duplicate]
    cinvoke printf, output_msg, eax  ; ������� ��������� � ��������� ���������
    jmp end_program           ; ��������� � ���������� ���������

no_duplicates:
    cinvoke printf, no_duplicates_msg  ; ������� ��������� �� ���������� ����������

end_program:
    ; �������� ������� ������� ����� �����������
    cinvoke getch             ; ���� ������� �������

    ; ���������� ���������
    invoke ExitProcess, 0

section '.idata' import data readable
    library kernel32, 'kernel32.dll', msvcrt, 'msvcrt.dll'
    import kernel32, ExitProcess, 'ExitProcess'
    import msvcrt, printf, 'printf', scanf, 'scanf', getch, '_getch'