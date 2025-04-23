format PE console
entry start

include 'D:\fasn\INCLUDE\win32ax.inc'

section '.data' data readable writable
    array rd 10               ; Массив для хранения 10 целых чисел
    len = 10                  ; Размер массива (10 элементов)
    duplicate dd 0            ; Переменная для хранения найденного дубликата
    input_msg db "Enter element %d: ", 0
    output_msg db "Two identical elements: %d", 0
    no_duplicates_msg db "No duplicates found.", 0  ; Сообщение об отсутствии дубликатов

section '.code' code readable executable
start:
    ; Ввод элементов массива
    mov ecx, len              ; Устанавливаем счетчик цикла (10 итераций)
    lea esi, [array]          ; Загружаем адрес начала массива

input_loop:
    push ecx                  ; Сохраняем счетчик цикла
    mov eax, len
    sub eax, ecx              ; Вычисляем текущий индекс (от 0 до 9)
    inc eax                   ; Преобразуем индекс в 1-based (от 1 до 10) для отображения
    cinvoke printf, input_msg, eax  ; Выводим приглашение для ввода
    lea eax, [esi]            ; Адрес текущего элемента массива
    cinvoke scanf, "%d", eax  ; Читаем число от пользователя
    add esi, 4                ; Переходим к следующему элементу массива
    pop ecx                   ; Восстанавливаем счетчик цикла
    loop input_loop           ; Повторяем цикл для всех элементов

    ; Поиск двух одинаковых элементов
    mov ecx, len - 1          ; Устанавливаем счетчик внешнего цикла (9 итераций)
    lea esi, [array]          ; Загружаем адрес начала массива
    xor ebx, ebx              ; Флаг для проверки наличия дубликатов (0 = нет дубликатов)

outer_loop:
    mov eax, [esi]            ; Текущий элемент массива
    mov edx, esi              ; Адрес текущего элемента
    add edx, 4                ; Начало внутреннего цикла (следующий элемент)

inner_loop:
    mov edi, [edx]            ; Следующий элемент массива
    cmp eax, edi              ; Сравниваем текущий элемент с остальными
    je found_duplicate        ; Если найден дубликат, переходим к метке `found_duplicate`
    add edx, 4                ; Переходим к следующему элементу во внутреннем цикле
    cmp edx, array + len * 4  ; Проверяем, не вышли ли за пределы массива
    jb inner_loop             ; Если нет, продолжаем внутренний цикл
    add esi, 4                ; Переходим к следующему элементу во внешнем цикле
    loop outer_loop           ; Повторяем внешний цикл

    ; Если дубликаты не найдены
    cmp ebx, 0                ; Проверяем флаг дубликатов
    je no_duplicates          ; Если флаг == 0, дубликаты отсутствуют

found_duplicate:
    mov [duplicate], eax      ; Сохраняем найденный дубликат в переменной `duplicate`

    ; Вывод результата
    mov eax, [duplicate]
    cinvoke printf, output_msg, eax  ; Выводим сообщение о найденном дубликате
    jmp end_program           ; Переходим к завершению программы

no_duplicates:
    cinvoke printf, no_duplicates_msg  ; Выводим сообщение об отсутствии дубликатов

end_program:
    ; Ожидание нажатия клавиши перед завершением
    cinvoke getch             ; Ждем нажатия клавиши

    ; Завершение программы
    invoke ExitProcess, 0

section '.idata' import data readable
    library kernel32, 'kernel32.dll', msvcrt, 'msvcrt.dll'
    import kernel32, ExitProcess, 'ExitProcess'
    import msvcrt, printf, 'printf', scanf, 'scanf', getch, '_getch'