# zsh completion for sx
_sx() {
    local -a opts backends timeranges categories engines
    opts=('-t:time range' '-c:search category' '-i:image search' '-e:engine filter'
          '-b:backend override' '-o:open first result' '-h:show help' '--setup:configure backend'
          '--status:show current config')
    backends=(duckduckgo searxng searxng-public)
    timeranges=(day week month year)
    categories=(general news videos images it science files music)
    engines=(google duckduckgo brave bing wikipedia reddit github startpage qwant yahoo)

    case "$words[CURRENT-1]" in
        -t) _describe 'time range' timeranges ;;
        -c) _describe 'category' categories ;;
        -b) _describe 'backend' backends ;;
        -e) _describe 'engine' engines ;;
        *)
            if [[ "$PREFIX" == -* ]]; then
                _describe 'option' opts
            fi ;;
    esac
}
compdef _sx sx
