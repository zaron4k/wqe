format PE console
entry start

include 'D:\fasn\INCLUDE\win32ax.inc'

section '.data' data readable writable
    array rd 10               ; ������ ��� �������� 10 ����� �����
    len = 10                  ; ������ ������� (10 ���������)
    product dd 1              ; ���������� ��� �������� ������������ (��������� �������� = 1)
    odd_found dd 0            ; ����, �����������, ������� �� �������� ��������
    input_msg db "Enter element %d: ", 0
    output_msg db "Product of odd elements: %d", 0
    no_odds_msg db "No odd elements found.", 0  ; ���������, ���� ��� �������� ���������

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

    ; ���������� ������������ �������� ���������
    mov ecx, len              ; ������������� ������� ����� (10 ��������)
    lea esi, [array]          ; ��������� ����� ������ �������

calculate_product:
    lodsd                     ; ��������� ������� ������� � EAX
    test eax, 1               ; ��������� ������� ��� (���� 1, ����� ��������)
    jz skip                   ; ���� ����� ������, ���������� ���������
    mov ebx, [product]        ; ��������� ������� ������������ � EBX
    imul ebx, eax             ; �������� EBX (������� ������������) �� EAX (�������� �������)
    mov [product], ebx        ; ��������� ��������� ������� � [product]
    inc dword [odd_found]     ; ����������� ������� ��������� �������� ���������
skip:
    loop calculate_product    ; ��������� � ���������� ��������

    ; �������� ������� �������� ���������
    cmp dword [odd_found], 0  ; ��������� ���� ������� �������� ���������
    je no_odds                ; ���� ���� == 0, �������� ��������� ���

    ; ����� ����������
    mov eax, [product]
    cinvoke printf, output_msg, eax  ; ������� ������������ �������� ���������
    jmp end_program           ; ��������� � ���������� ���������

no_odds:
    cinvoke printf, no_odds_msg  ; ������� ��������� �� ���������� �������� ���������

end_program:
    ; �������� ������� ������� ����� �����������
    cinvoke getch             ; ���� ������� �������

    ; ���������� ���������
    invoke ExitProcess, 0

section '.idata' import data readable
    library kernel32, 'kernel32.dll', msvcrt, 'msvcrt.dll'
    import kernel32, ExitProcess, 'ExitProcess'
    import msvcrt, printf, 'printf', scanf, 'scanf', getch, '_getch'