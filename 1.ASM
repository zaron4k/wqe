format PE console
entry start

include 'D:\fasn\INCLUDE\win32ax.inc'

section '.data' data readable writable
    array rd 10               ; Массив для хранения 10 целых чисел
    len = 10                  ; Размер массива (10 элементов)
    product dd 1              ; Переменная для хранения произведения (начальное значение = 1)
    odd_found dd 0            ; Флаг, указывающий, найдены ли нечетные элементы
    input_msg db "Enter element %d: ", 0
    output_msg db "Product of odd elements: %d", 0
    no_odds_msg db "No odd elements found.", 0  ; Сообщение, если нет нечетных элементов

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

    ; Вычисление произведения нечетных элементов
    mov ecx, len              ; Устанавливаем счетчик цикла (10 итераций)
    lea esi, [array]          ; Загружаем адрес начала массива

calculate_product:
    lodsd                     ; Загружаем элемент массива в EAX
    test eax, 1               ; Проверяем младший бит (если 1, число нечетное)
    jz skip                   ; Если число четное, пропускаем умножение
    mov ebx, [product]        ; Загружаем текущее произведение в EBX
    imul ebx, eax             ; Умножаем EBX (текущее произведение) на EAX (нечетный элемент)
    mov [product], ebx        ; Сохраняем результат обратно в [product]
    inc dword [odd_found]     ; Увеличиваем счетчик найденных нечетных элементов
skip:
    loop calculate_product    ; Переходим к следующему элементу

    ; Проверка наличия нечетных элементов
    cmp dword [odd_found], 0  ; Проверяем флаг наличия нечетных элементов
    je no_odds                ; Если флаг == 0, нечетных элементов нет

    ; Вывод результата
    mov eax, [product]
    cinvoke printf, output_msg, eax  ; Выводим произведение нечетных элементов
    jmp end_program           ; Переходим к завершению программы

no_odds:
    cinvoke printf, no_odds_msg  ; Выводим сообщение об отсутствии нечетных элементов

end_program:
    ; Ожидание нажатия клавиши перед завершением
    cinvoke getch             ; Ждем нажатия клавиши

    ; Завершение программы
    invoke ExitProcess, 0

section '.idata' import data readable
    library kernel32, 'kernel32.dll', msvcrt, 'msvcrt.dll'
    import kernel32, ExitProcess, 'ExitProcess'
    import msvcrt, printf, 'printf', scanf, 'scanf', getch, '_getch'