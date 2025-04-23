format PE console
entry start

include 'win32a.inc'

section '.data' data readable writeable
    array_size = 8                   ; Размер массива (можно изменить)
    array rd array_size              ; Массив для хранения введенных данных
    input_prompt db 'Enter element %d: ', 0  ; Приглашение для ввода
    output_prompt db 10, 'Modified array: ', 0   ; Сообщение перед выводом массива
    format_input db '%d', 0          ; Формат для ввода чисел
    format_output db '%d ', 0        ; Формат для вывода чисел
    min_value dd 0                   ; Переменная для хранения минимального значения
    max_value dd 0                   ; Переменная для хранения максимального значения

section '.code' code readable executable
start:
    ; Шаг 1: Запрос на ввод элементов массива
    mov ecx, array_size              ; Количество элементов в массиве
    lea esi, [array]                 ; Указатель на начало массива
    xor ebx, ebx                     ; Счетчик для номера элемента (начинаем с 0)

input_loop:
    inc ebx                          ; Увеличиваем счетчик номера элемента
    push ebx                         ; Сохраняем номер элемента для вывода
    push input_prompt                ; Формат строки для приглашения
    call [printf]                    ; Выводим приглашение для ввода
    add esp, 8                       ; Очищаем стек

    lea eax, [esi + ebx*4 - 4]       ; Адрес текущего элемента массива
    push eax                         ; Адрес для сохранения введенного числа
    push format_input                ; Формат для ввода чисел
    call [scanf]                     ; Считываем число
    add esp, 8                       ; Очищаем стек

    cmp ebx, array_size              ; Проверяем, все ли элементы введены
    jb input_loop                    ; Если нет, продолжаем цикл

    ; Шаг 2: Поиск минимального и максимального значений
    mov ecx, array_size              ; Количество элементов в массиве
    lea esi, [array]                 ; Указатель на начало массива
    mov eax, [esi]                   ; Загружаем первый элемент массива
    mov ebx, eax                     ; Инициализируем min и max первым элементом
    mov [min_value], eax
    mov [max_value], eax

find_min_max:
    lodsd                            ; Загружаем следующий элемент массива в EAX
    cmp eax, [min_value]             ; Сравниваем с текущим минимумом
    jge not_min                      ; Если больше или равно, пропускаем обновление минимума
    mov [min_value], eax             ; Обновляем минимум
not_min:
    cmp eax, [max_value]             ; Сравниваем с текущим максимумом
    jle not_max                      ; Если меньше или равно, пропускаем обновление максимума
    mov [max_value], eax             ; Обновляем максимум
not_max:
    loop find_min_max                ; Повторяем для всех элементов

    ; Шаг 3: Замена максимальных элементов на минимальные
    mov ecx, array_size              ; Снова количество элементов
    lea esi, [array]                 ; Указатель на начало массива
replace_max_with_min:
    mov eax, [esi]                   ; Загружаем текущий элемент
    cmp eax, [max_value]             ; Сравниваем с максимальным значением
    jne not_replace                  ; Если не равно, пропускаем замену
    mov eax, [min_value]             ; Заменяем на минимальное значение
    mov [esi], eax                   ; Сохраняем измененное значение
not_replace:
    add esi, 4                       ; Переходим к следующему элементу
    loop replace_max_with_min        ; Повторяем для всех элементов

    ; Шаг 4: Вывод измененного массива
    push output_prompt               ; Сообщение перед выводом массива
    call [printf]                    ; Выводим сообщение
    add esp, 4                       ; Очищаем стек

    mov ecx, array_size              ; Количество элементов
    lea esi, [array]                 ; Указатель на начало массива
print_array:
    lodsd                            ; Загружаем элемент массива
    push ecx                         ; Сохраняем счетчик цикла
    push eax                         ; Значение для вывода
    push format_output               ; Формат строки для вывода
    call [printf]                    ; Вызываем printf
    add esp, 8                       ; Очищаем стек
    pop ecx                          ; Восстанавливаем счетчик цикла
    loop print_array                 ; Повторяем для всех элементов

    ; Добавляем ожидание нажатия клавиши перед завершением
    push wait_message                ; Выводим сообщение "Press any key to exit..."
    call [printf]
    add esp, 4                       ; Очищаем стек
    call [getch]                     ; Ждем нажатия клавиши

    ; Завершение программы
    push 0                           ; Код возврата
    call [ExitProcess]

section '.idata' import data readable
    library kernel32, 'kernel32.dll', msvcrt, 'msvcrt.dll'
    import kernel32, ExitProcess, 'ExitProcess'
    import msvcrt, printf, 'printf', scanf, 'scanf', getch, '_getch'

section '.rdata' data readable
    format_str db '%d ', 0           ; Формат строки для вывода чисел
    wait_message db 10, 'Press any key to exit...', 10, 0  ; Сообщение ожидания
