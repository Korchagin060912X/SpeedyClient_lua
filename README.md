# Speedy Client

Набор клиентских скриптов и интерфейсов для **Roblox**. Проект написан на **Luau** — языке Roblox, основанном на Lua и расширенном для работы с Roblox API.

> **Важно:** скрипты предназначены для Roblox и конкретных игр, перечисленных ниже. `FPSBoost.client.lua` пока содержит только интерфейс и кнопку меню — он не меняет настройки графики и сам по себе не повышает FPS.

## Игры и файлы

| Игра / раздел | Файл | Назначение |
|---|---|---|
| **DOORS** | [`Doors_Scripts/Main.client.lua`](./Doors_Scripts/Main.client.lua) | Клиентский скрипт с игровыми функциями, настройками интерфейса и уведомлениями для DOORS. Использует UI-библиотеки Linoria/Obsidian и ESP-модуль. |
| **Murder Mystery 2 (MM2)** | [`MM2_Scripts/Main.client.lua`](./MM2_Scripts/Main.client.lua) | Основной клиентский скрипт с меню, настройками и игровыми функциями, включая AutoFarm монет и Anti-AFK. |
| **Murder Mystery 2 (MM2)** | [`MM2_Scripts/Safe.client.lua`](./MM2_Scripts/Safe.client.lua) | Облегчённый вариант с меню Speedy Client, переключением разделов и настройкой клавиши меню. |
| **Roblox — интерфейс FPS Boost** | [`Utilities_Scripts/FPSBoost.client.lua`](./Utilities_Scripts/FPSBoost.client.lua) | Заготовка интерфейса Speedy Client с кнопкой открытия и закрытия. Функции оптимизации FPS пока нет. |

## На чём и как сделано

- **Язык:** Luau — диалект Lua для Roblox.
- **Платформа:** клиентская среда Roblox; файлы `.client.lua` рассчитаны на запуск как клиентские скрипты.
- **Интерфейс:** создаётся средствами Roblox UI (`ScreenGui`, `Frame`, кнопки и другие элементы).
- **Анимации и ввод:** для анимаций используется `TweenService`, для клавиш и управления — сервисы Roblox.
- **DOORS:** UI-библиотека и ESP-модуль загружаются скриптом во время выполнения.

## Как запустить

Добавьте сюда свои инструкции по запуску. У каждого блока кода в GitHub есть кнопка копирования — замените текст-заполнитель нужной инструкцией.

### DOORS

```text
Добавьте сюда инструкцию запуска скрипта DOORS.
```

### Murder Mystery 2 (MM2)

```text
Добавьте сюда инструкцию запуска основного или Safe-скрипта MM2.
```

### Roblox — FPS Boost UI

```text
Добавьте сюда инструкцию запуска интерфейса FPS Boost.
```

## Структура проекта

```text
SpeedyClient_lua/
├── Doors_Scripts/
│   └── Main.client.lua
├── MM2_Scripts/
│   ├── Main.client.lua
│   └── Safe.client.lua
├── Utilities_Scripts/
│   └── FPSBoost.client.lua
└── README.md
```
