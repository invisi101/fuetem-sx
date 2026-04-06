#!/usr/bin/env bash
# install.sh — Install sx (terminal web search)

set -e

BOLD='\033[1m'
DIM='\033[2m'
YELLOW='\033[33m'
GREEN='\033[32m'
RESET='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
INSTALL_DIR="${HOME}/.local/bin"
CONFIG_DIR="${HOME}/.config/sx"
CONFIG_FILE="${CONFIG_DIR}/config.json"

# --- Install the script -----------------------------------------------------

mkdir -p "$INSTALL_DIR"
cp "$SCRIPT_DIR/sx" "$INSTALL_DIR/sx"
chmod +x "$INSTALL_DIR/sx"

echo ""
echo -e "  ${BOLD}sx installed${RESET} to $INSTALL_DIR/sx"

# Check if ~/.local/bin is on PATH
if ! echo "$PATH" | tr ':' '\n' | grep -qx "$INSTALL_DIR"; then
    echo ""
    echo -e "  ${YELLOW}Warning:${RESET} $INSTALL_DIR is not on your PATH."
    echo "  Add this to your shell profile:"
    echo "    export PATH=\"\$HOME/.local/bin:\$PATH\""
fi

# --- Pick a backend ---------------------------------------------------------

echo ""
echo -e "  ${BOLD}Choose your default search backend:${RESET}"
echo ""
echo -e "    ${BOLD}1.${RESET} DuckDuckGo            ${DIM}no setup needed${RESET}"
echo -e "    ${BOLD}2.${RESET} SearXNG (public)       ${DIM}no setup, less reliable${RESET}"
echo -e "    ${BOLD}3.${RESET} SearXNG (local)        ${DIM}your own instance — best results${RESET}"
echo ""
read -rp "  Choose backend [1-3] (default 1): " PICK
PICK="${PICK:-1}"

BACKEND="duckduckgo"
SEARXNG_URL="http://127.0.0.1:8888"
SEARXNG_PUBLIC_URL=""

case "$PICK" in
    1)
        BACKEND="duckduckgo"
        ;;
    2)
        BACKEND="searxng-public"
        echo ""
        echo -e "  ${DIM}Browse https://searx.space/ and pick an instance with green uptime.${RESET}"
        echo -e "  ${DIM}Not all instances support JSON — we'll test it for you.${RESET}"
        echo ""
        read -rp "  Paste an instance URL (or leave blank to use built-in list): " PUB_URL
        if [ -n "$PUB_URL" ]; then
            SEARXNG_PUBLIC_URL="$PUB_URL"
        fi
        ;;
    3)
        BACKEND="searxng"
        echo ""
        read -rp "  SearXNG URL (enter for http://127.0.0.1:8888): " URL_INPUT
        if [ -n "$URL_INPUT" ]; then
            SEARXNG_URL="$URL_INPUT"
        fi
        ;;
    *)
        echo "  Invalid choice, defaulting to DuckDuckGo."
        BACKEND="duckduckgo"
        ;;
esac

# --- Save config ------------------------------------------------------------

mkdir -p "$CONFIG_DIR"
cat > "$CONFIG_FILE" << EOF
{
  "backend": "$BACKEND",
  "searxng_url": "$SEARXNG_URL",
  "searxng_public_url": "$SEARXNG_PUBLIC_URL"
}
EOF

# --- Test the connection ----------------------------------------------------

echo ""
TEST_OK=1

if [ "$BACKEND" = "duckduckgo" ]; then
    echo -n "  Testing DuckDuckGo... "
    if curl -sf "https://html.duckduckgo.com/html/?q=test" -o /dev/null 2>/dev/null; then
        echo -e "${GREEN}OK${RESET}"
    else
        echo -e "${YELLOW}failed${RESET}"
        echo "  Check your internet connection."
        TEST_OK=0
    fi

elif [ "$BACKEND" = "searxng-public" ]; then
    if [ -n "$SEARXNG_PUBLIC_URL" ]; then
        echo -n "  Testing ${SEARXNG_PUBLIC_URL}... "
        HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "${SEARXNG_PUBLIC_URL}/search?q=test&format=json" 2>/dev/null || echo "000")
        if [ "$HTTP_CODE" = "200" ]; then
            echo -e "${GREEN}OK${RESET}"
        elif [ "$HTTP_CODE" = "403" ]; then
            echo -e "${YELLOW}JSON API disabled on this instance${RESET}"
            echo "  Try a different one from https://searx.space/ or run 'sx --setup'."
            TEST_OK=0
        elif [ "$HTTP_CODE" = "429" ]; then
            echo -e "${YELLOW}rate limited by this instance${RESET}"
            echo "  Try a different one from https://searx.space/ or run 'sx --setup'."
            TEST_OK=0
        elif [ "$HTTP_CODE" = "000" ]; then
            echo -e "${YELLOW}could not connect${RESET}"
            TEST_OK=0
        else
            echo -e "${YELLOW}HTTP ${HTTP_CODE}${RESET}"
            TEST_OK=0
        fi
    else
        echo -n "  Testing public SearXNG instances... "
        OK=0
        for INST in "https://searx.be" "https://search.ononoki.org" "https://paulgo.io"; do
            if curl -sf "${INST}/search?q=test&format=json" -o /dev/null 2>/dev/null; then
                OK=1
                break
            fi
        done
        if [ "$OK" = "1" ]; then
            echo -e "${GREEN}OK${RESET}"
        else
            echo -e "${YELLOW}no instances responded${RESET}"
            echo "  This backend can be unreliable. You can switch anytime with 'sx --setup'."
            TEST_OK=0
        fi
    fi

elif [ "$BACKEND" = "searxng" ]; then
    echo -n "  Testing ${SEARXNG_URL}... "
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "${SEARXNG_URL}/search?q=test&format=json" 2>/dev/null || echo "000")

    if [ "$HTTP_CODE" = "200" ]; then
        echo -e "${GREEN}OK${RESET}"
    elif [ "$HTTP_CODE" = "403" ]; then
        echo -e "${YELLOW}403 Forbidden — JSON API is not enabled${RESET}"
        echo ""
        echo "  To fix this, edit your SearXNG settings.yml:"
        echo ""
        echo -e "    1. Add ${BOLD}json${RESET} to the formats list:"
        echo -e "       ${DIM}search:${RESET}"
        echo -e "       ${DIM}  formats:${RESET}"
        echo -e "       ${DIM}    - html${RESET}"
        echo -e "       ${DIM}    - json${RESET}"
        echo ""
        echo -e "    2. Disable the rate limiter (recommended for local use):"
        echo -e "       ${DIM}server:${RESET}"
        echo -e "       ${DIM}  limiter: false${RESET}"
        echo ""
        echo "    3. Restart SearXNG (depends on how it is installed on your system):"
        echo -e "       ${DIM}systemd:  sudo systemctl restart searxng${RESET}"
        echo -e "       ${DIM}docker:   docker restart searxng${RESET}"
        echo -e "       ${DIM}manual:   stop and re-run your start script${RESET}"
        echo ""
        echo "  Once fixed, run 'sx hello world' to test."
        TEST_OK=0
    elif [ "$HTTP_CODE" = "000" ]; then
        echo -e "${YELLOW}could not connect${RESET}"
        echo "  Make sure SearXNG is running at ${SEARXNG_URL}"
        TEST_OK=0
    else
        echo -e "${YELLOW}HTTP ${HTTP_CODE}${RESET}"
        TEST_OK=0
    fi
fi

# --- Done -------------------------------------------------------------------

echo ""
if [ "$TEST_OK" = "1" ]; then
    echo -e "  ${BOLD}You're all set!${RESET} Try: ${BOLD}sx hello world${RESET}"
else
    echo -e "  ${BOLD}sx is installed${RESET} but the backend needs fixing (see above)."
fi
echo -e "  ${DIM}Run 'sx --setup' anytime to change backend.${RESET}"
echo ""
