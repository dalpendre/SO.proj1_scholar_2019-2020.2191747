#Final version 15th April

#!/usr/bin/env bash

#global variables
profiles_file="scholar_URLs.txt"

#removes '#' to scholar_URLs.txt text
#link used for reserach: http://www.theunixschool.com/2014/08/sed-examples-remove-delete-chars-from-line-file.html
profiles_file_clean=$(sed '/^ *#/d;s/#.*//' $profiles_file)

folder="Scholar"
bold=$(tput bold)
normal=$(tput sgr0)
underline=$(tput smul)
nounderline=$(tput rmul)

#separates links and file names and stores html files on folder Scholar
store_html_files()
{
    #link used for searching the functionality: https://devhints.io/bash
    if [ ! -f $profiles_file ]
    then
        echo "[ERRO] Não foi possível encontrar $profiles_file"
    fi

    if [[ ! -e $folder ]]
    then
        mkdir $folder
    fi

    printf "\n"

    # tr used for eliminating spaces on echo output
    for file in $(echo $profiles_file_clean | tr ' ' '\n')
    do
        file_link=$(echo $file | cut -d'|' -f1)
        file_name=$(echo $file | cut -d'|' -f2 | cut -d'.' -f1) #profile name only
        file_html=$(echo $file | cut -d'|' -f2) #file with extension
        file_db=$(echo $file | cut -d'|' -f2 | cut -d'.' -f1).db

        curl --silent --output $file_html $file_link
        touch $file_db

        citations=$(cat $file_html | tr '>' '\n' | grep -A25 'Citations' | tail -n27 | head -n5 | tail -n1 | cut -d'<' -f1)
        citations_five_years=$(cat $file_html | tr '>' '\n' | grep -A25 'Citations' | tail -n27 | head -n7 | tail -n1 | cut -d'<' -f1)
        h_index=$(cat $file_html | tr '>' '\n' | grep -A25 'Citations' | tail -n27 | head -n15 | tail -n1 | cut -d'<' -f1)
        h_index_five_years=$(cat $file_html | tr '>' '\n' | grep -A25 'Citations' | tail -n27 | head -n17 | tail -n1 | cut -d'<' -f1)

        file_creation_date=$(date +%Y.%m.%d)
        file_creation_time=$(date +%Hh%M:%S)
        file_creation_datetime=$(echo $file_creation_date $file_creation_time | tr ' ' '_')

        echo "--------------------------------------------------------------"
        echo "[A processar]: $file_link"
        echo "[INFO] A utilizar o ficheiro local '$file_html'"
        echo "Scholar: ${bold}'${underline}$file_name${nounderline}'${normal}"
        echo "Citacoes - Total: ${bold}${underline}$citations${nounderline}${normal}, ultimos 5 anos: ${underline}${bold}$citations_five_years${nounderline}${normal}"
        echo "H-Index - Total: ${bold}${underline}$h_index${nounderline}${normal}, ultimos 5 anos: ${underline}${bold}$h_index_five_years${nounderline}${normal}"

        printf "\n"

        #add info to db files
        echo "${bold}# Ficheiro: '$file_db'" >> $file_db
        echo "# Info $folder: '$file_name'" >> $file_db
        echo "# Criado em: $file_creation_datetime" >> $file_db
        echo "# Citacoes:Citacoes-5anos:h-index:h-index_5anos" >> $file_db
        echo "${normal}$file_creation_date:$citations:$citations_five_years:$h_index:$h_index_five_years" >> $file_db
        echo "${bold}# Ultima atualização: $file_creation_datetime" >> $file_db

        mv $file_html $folder
        mv $file_db $folder
    done
}

#shows command help to the user
show_help()
{
    printf "\n"

    echo "${bold}MENU DE AJUDA AO UTILIZADOR (informação sobre comandos que pode usar no script google_scholar.sh)${normal}"
    printf "\n"

    echo "${bold}./google_scholar -i${normal}"
    printf "\n"
    echo "Cria a pasta $folder, se a mesma não existir, e guarda os ficheiros html e db dentro dela.
Mostra também informação extraida de cada perfil (ficheiro, nome do ficheiro, citações e h-index).
Se a pasta $folder existir, é mostrada uma mensagem de erro (Pasta já existe)"
    printf "\n"

    echo "${bold}./google_scholar -h${normal}"
    printf "\n"
    echo "Mostra o menu de ajuda de comandos possíveis a realizar no google_scholar"
    printf "\n"

    echo "${bold}./google_scholar${normal}"
    printf "\n"
    echo "Consulta a pasta Scholar e os ficheiros asssociados. Caso não encontre um ou mais ficheiros, devolve
uma mensagem de erro do(s) ficheiro(s) em falta, senão mostra dados do ficheiro (como exemplificado na opção -i)"
    printf "\n"

    echo "- Qualquer outra opção indicada sem ser -i, -h ou vazio, é indicada uma mensagem de erro 'ERRO: parâmetro(s) não suportado(s)'"
    printf "\n"
}

#searches "Scholar" folder and the html files
search_files()
{
    printf "\n"

    for file in $(echo $profiles_file_clean | tr ' ' '\n')
    do
        file_link=$(echo $file | cut -d'|' -f1)
        file_name=$(echo $file | cut -d'|' -f2 | cut -d'.' -f1)
        file_html=$(echo $file | cut -d'|' -f2)
        file_db=$(echo $file | cut -d'|' -f2 | cut -d'.' -f1).db

        file_html_search=$(find $folder/$file_html 2> /dev/null) #error message is hidden

        if $file_html_search 2> /dev/null  #due to permission error, redirect is repetead here
        then
            echo "[ERRO] Não foi possível encontrar o ficheiro '$file_name'"
            printf "\n"
        else
            citations=$(cat $folder/$file_html | tr '>' '\n' | grep -A25 'Citations' | tail -n27 | head -n5 | tail -n1 | cut -d'<' -f1)
            citations_five_years=$(cat $folder/$file_html | tr '>' '\n' | grep -A25 'Citations' | tail -n27 | head -n7 | tail -n1 | cut -d'<' -f1)
            h_index=$(cat $folder/$file_html | tr '>' '\n' | grep -A25 'Citations' | tail -n27 | head -n15 | tail -n1 | cut -d'<' -f1)
            h_index_five_years=$(cat $folder/$file_html | tr '>' '\n' | grep -A25 'Citations' | tail -n27 | head -n17 | tail -n1 | cut -d'<' -f1)

            #the same for last update datetime
            file_creation_date=$(date +%Y.%m.%d)
            file_creation_time=$(date +%Hh%M:%S)
            file_creation_datetime=$(echo $file_creation_date $file_creation_time | tr ' ' '_')

            #removes last line for add new update datetime
            sed -i '$d' $folder/$file_db
            echo "${bold}# Ultima atualização: $file_creation_datetime" >> $folder/$file_db

            echo "--------------------------------------------------------------"
            echo "[A processar]: $file_link"
            echo "[INFO] A utilizar o ficheiro local '$file_html'"
            echo "Scholar: ${bold}'${underline}$file_name${nounderline}'${normal}"
            echo "Citacoes - Total: ${bold}${underline}$citations${nounderline}${normal}, ultimos 5 anos: ${underline}${bold}$citations_five_years${nounderline}${normal}"
            echo "H-Index - Total: ${bold}${underline}$h_index${nounderline}${normal}, ultimos 5 anos: ${underline}${bold}$h_index_five_years${nounderline}${normal}"

            printf "\n"
        fi
   done
}

#argument input check
if [[ $1 == "-i" ]]
then
    store_html_files
elif [[ $1 == "-h" ]]
then
    show_help
elif [[ $1 == "" ]]
then
    search_files
else
    echo "ERRO: parâmetro(s) não suportado(s)"
fi
