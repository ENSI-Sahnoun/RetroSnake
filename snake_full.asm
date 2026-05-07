org 100h
jmp start

MAX_LEN equ 200

snake_x db 20,19,18,17
times MAX_LEN-4 db 0
snake_y db 12,12,12,12
times MAX_LEN-4 db 0

length db 4
dir db 1
food_x db 30
food_y db 10
old_tail_x db 0
old_tail_y db 0
tmp_x db 0
tmp_y db 0
tmp_color db 0
score dw 0

msg_score db 'SCORE : $'
msg_game_over db 'FIN DE PARTIE$'
msg_final db 'SCORE FINAL : $'
msg_exit db 'APPUYER SUR UNE TOUCHE$'

start:
    mov ax, 0013h
    int 10h
    call new_food

main_loop:
    call input
    call update
    call draw
    call delay
    jmp main_loop

input:
    mov ah, 01h
    int 16h
    jz no_key

    mov ah, 00h
    int 16h

    cmp al, 1Bh
    je quit_game

    cmp ah, 4Dh
    je set_right
    cmp ah, 4Bh
    je set_left
    cmp ah, 48h
    je set_up
    cmp ah, 50h
    je set_down
    ret

set_right:
    cmp byte [dir], 2
    je no_key
    mov byte [dir], 1
    ret

set_left:
    cmp byte [dir], 1
    je no_key
    mov byte [dir], 2
    ret

set_up:
    cmp byte [dir], 4
    je no_key
    mov byte [dir], 3
    ret

set_down:
    cmp byte [dir], 3
    je no_key
    mov byte [dir], 4
    ret

no_key:
    ret

update:
    mov cl, [length]
    xor ch, ch
    dec cx
    mov si, cx
    mov al, [snake_x + si]
    mov [old_tail_x], al
    mov al, [snake_y + si]
    mov [old_tail_y], al

    cmp cx, 0
    je update_head

shift_loop:
    mov di, si
    dec di
    mov al, [snake_x + di]
    mov [snake_x + si], al
    mov al, [snake_y + di]
    mov [snake_y + si], al
    dec si
    jnz shift_loop

update_head:
    mov al, [dir]
    cmp al, 1
    je move_right
    cmp al, 2
    je move_left
    cmp al, 3
    je move_up
    cmp al, 4
    je move_down
    jmp check_game

move_right:
    inc byte [snake_x]
    jmp check_game

move_left:
    dec byte [snake_x]
    jmp check_game

move_up:
    dec byte [snake_y]
    jmp check_game

move_down:
    inc byte [snake_y]

check_game:
    mov al, [snake_x]
    cmp al, 40
    jae game_over

    mov al, [snake_y]
    cmp al, 1
    jb game_over
    cmp al, 25
    jae game_over

    mov cl, [length]
    xor ch, ch
    dec cx
    jz check_food
    mov si, 1

self_loop:
    mov al, [snake_x]
    cmp al, [snake_x + si]
    jne self_next
    mov al, [snake_y]
    cmp al, [snake_y + si]
    je game_over
self_next:
    inc si
    loop self_loop

check_food:
    mov al, [snake_x]
    cmp al, [food_x]
    jne update_done
    mov al, [snake_y]
    cmp al, [food_y]
    jne update_done

    inc word [score]

    mov al, [length]
    cmp al, MAX_LEN
    jae food_only
    xor ah, ah
    mov si, ax
    mov al, [old_tail_x]
    mov [snake_x + si], al
    mov al, [old_tail_y]
    mov [snake_y + si], al
    inc byte [length]

food_only:
    call new_food

update_done:
    ret

new_food:
make_food:
    mov ah, 00h
    int 1Ah

    mov ax, dx
    xor dx, dx
    mov bx, 40
    div bx
    mov [food_x], dl

    xor dx, dx
    mov bx, 24
    div bx
    inc dl
    mov [food_y], dl

    mov cl, [length]
    xor ch, ch
    xor si, si

food_check_loop:
    mov al, [food_x]
    cmp al, [snake_x + si]
    jne food_next
    mov al, [food_y]
    cmp al, [snake_y + si]
    je make_food
food_next:
    inc si
    loop food_check_loop
    ret

draw:
    call clear_screen

    mov al, [food_x]
    mov bl, [food_y]
    mov dl, 12
    call draw_cell

    mov cl, [length]
    xor ch, ch
    xor si, si

snake_draw_loop:
    mov al, [snake_x + si]
    mov bl, [snake_y + si]
    mov dl, 10
    cmp si, 0
    jne draw_part
    mov dl, 14

draw_part:
    call draw_cell
    inc si
    loop snake_draw_loop

    call print_score
    ret

clear_screen:
    push ax
    push cx
    push di
    push es
    mov ax, 0A000h
    mov es, ax
    xor di, di
    xor ax, ax
    mov cx, 32000
    rep stosw
    pop es
    pop di
    pop cx
    pop ax
    ret

draw_cell:
    push ax
    push bx
    push cx
    push dx
    push di
    push es

    mov [tmp_x], al
    mov [tmp_y], bl
    mov [tmp_color], dl

    mov ax, 0A000h
    mov es, ax

    mov al, [tmp_y]
    xor ah, ah
    mov bx, 2560
    mul bx
    mov di, ax

    mov al, [tmp_x]
    xor ah, ah
    mov cl, 3
    shl ax, cl
    add di, ax

    mov al, [tmp_color]
    mov dx, 8

cell_row:
    mov cx, 8
    rep stosb
    add di, 312
    dec dx
    jnz cell_row

    pop es
    pop di
    pop dx
    pop cx
    pop bx
    pop ax
    ret

print_score:
    mov ah, 02h
    mov bh, 0
    mov dh, 0
    mov dl, 0
    int 10h

    mov si, msg_score
    call print_string
    mov ax, [score]
    call print_number
    ret

print_string:
    lodsb
    cmp al, '$'
    je print_string_done
    mov ah, 0Eh
    mov bh, 0
    mov bl, 15
    int 10h
    jmp print_string
print_string_done:
    ret

print_number:
    push ax
    push bx
    push cx
    push dx

    cmp ax, 0
    jne number_loop_start
    mov al, '0'
    mov ah, 0Eh
    mov bh, 0
    mov bl, 15
    int 10h
    jmp number_done

number_loop_start:
    xor cx, cx
    mov bx, 10

number_loop:
    xor dx, dx
    div bx
    push dx
    inc cx
    cmp ax, 0
    jne number_loop

number_print:
    pop dx
    add dl, '0'
    mov al, dl
    mov ah, 0Eh
    mov bh, 0
    mov bl, 15
    int 10h
    loop number_print

number_done:
    pop dx
    pop cx
    pop bx
    pop ax
    ret

delay:
    push ax
    push cx
    mov ax, 3
slow_outer:
    mov cx, 0FFFFh
slow_inner:
    loop slow_inner
    dec ax
    jnz slow_outer
    pop cx
    pop ax
    ret

game_over:
    call clear_screen

    mov ah, 02h
    mov bh, 0
    mov dh, 10
    mov dl, 15
    int 10h
    mov si, msg_game_over
    call print_string

    mov ah, 02h
    mov bh, 0
    mov dh, 12
    mov dl, 12
    int 10h
    mov si, msg_final
    call print_string
    mov ax, [score]
    call print_number

    mov ah, 02h
    mov bh, 0
    mov dh, 15
    mov dl, 9
    int 10h
    mov si, msg_exit
    call print_string

    mov ah, 00h
    int 16h
    jmp quit_game

quit_game:
    mov ax, 0003h
    int 10h
    mov ax, 4C00h
    int 21h
