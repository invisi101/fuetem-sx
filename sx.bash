# bash completion for sx
_sx_completions() {
    local cur prev
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"

    case "$prev" in
        -t)
            COMPREPLY=($(compgen -W "day week month year" -- "$cur"))
            return ;;
        -c)
            COMPREPLY=($(compgen -W "general news videos images it science files music" -- "$cur"))
            return ;;
        -b)
            COMPREPLY=($(compgen -W "duckduckgo searxng searxng-public" -- "$cur"))
            return ;;
        -e)
            COMPREPLY=($(compgen -W "google duckduckgo brave bing wikipedia reddit github startpage qwant yahoo" -- "$cur"))
            return ;;
    esac

    if [[ "$cur" == -* ]]; then
        COMPREPLY=($(compgen -W "-t -c -i -e -b -o -h --setup" -- "$cur"))
        return
    fi
}
complete -F _sx_completions sx
