#!/bin/bash

dirpath="."
mask="*"
number=$(nproc)
command=""

while [[ $# -gt 0 ]]
do
    case $1 in
        --path)
            dirpath=$2
            shift 2
        ;;
        --mask)
            mask=$2
            shift 2
        ;;
        --number)
            number=$2
            shift 2
        ;;
        *)
            command=$1
            shift
        ;;
    esac
done

if [[ -z "$command" ]]
then
    echo "Ошибка: не указана команда"
    exit 1
fi

if [[ ! -d "$dirpath" ]]
then
    echo "Ошибка: каталог $dirpath не существует"
    exit 1
fi

if [[ -z "$mask" ]]
then
    echo "Ошибка: маска пустая"
    exit 1
fi

if [[ ! "$number" =~ ^[0-9]+$ ]] || (( number < 1 ))
then
    echo "Ошибка: number должно быть целым числом больше 0"
    exit 1
fi

if [[ ! -x "$command" ]]
then
    command=$(which "$command")
fi
if [[ -z "$command" || ! -x "$command" ]]
then
    echo "Ошибка: команда не найдена или не исполняемая"
    exit 1
fi

dirpath=$(cd "$dirpath" && pwd)
cd "$dirpath"

running=0

for file in $mask
do
    if [[ ! -f "$file" || -L "$file" ]]
    then
        continue
    fi

    if (( running >= number ))
    then
        wait -n
        running=$((running - 1))
    fi

    "$command" "$dirpath/$file" &
    running=$((running + 1))
done

wait
