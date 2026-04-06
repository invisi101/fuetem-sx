# sx

Search the web from your terminal. Linux only.

Works out of the box with DuckDuckGo (no setup needed), or connect it to your own SearXNG instance for the best results. No API keys required.

For the best experience, run a local SearXNG instance. If you don't have one, see [searxng-local](https://github.com/invisi101/searxng-local) for a quick install script.

## Install

```
git clone https://github.com/invisi101/fuetem-sx.git
cd fuetem-sx
./install.sh
```

The installer copies `sx` to `~/.local/bin/` and walks you through picking a search backend.

To uninstall:

```
./uninstall.sh
```

## Usage

```
sx <query>                          search with default backend
sx -10 python asyncio               top 10 results only
sx -t week rust release             results from the past week
sx -o python docs pathlib           open first result in browser
sx -b duckduckgo quantum computing  one-off search via DuckDuckGo
sx -h                               full help
```

### Flags

| Flag | Description |
|------|-------------|
| `-N` | Show top N results (e.g. `-10`, `-5`, `-20`) |
| `-t RANGE` | Time range: `day`, `week`, `month`, `year` |
| `-c CATEGORY` | Search category (SearXNG only): `general`, `news`, `videos`, `images`, `it`, `science`, `files`, `music` |
| `-e ENGINE` | Restrict to engine(s) (SearXNG only), comma-separated |
| `-b BACKEND` | Override backend for this search |
| `-o` | Open the first result in your browser |
| `-h` | Show help |
| `--setup` | Configure default backend |

## Backends

The installer asks you to pick a backend. You can change it anytime with `sx --setup` or override per-search with `-b`.

### DuckDuckGo (default)

Works immediately, no setup needed. Scrapes DuckDuckGo's HTML search with ads filtered out.

### SearXNG (local)

Use your own SearXNG instance. Best results — aggregates multiple search engines, includes infoboxes and suggestions.

Pick option 3 during install or in `sx --setup` and enter your instance URL (e.g. `http://127.0.0.1:8888`).

Your instance needs two config changes in `settings.yml`:

1. Enable the JSON API — add `json` to the formats list:
   ```yaml
   search:
     formats:
       - html
       - json
   ```

2. Disable the rate limiter (recommended for local use):
   ```yaml
   server:
     limiter: false
   ```

3. Restart SearXNG (depends on how it is installed on your system):
   - **systemd:** `sudo systemctl restart searxng`
   - **Docker:** `docker restart searxng`
   - **Manual:** stop and re-run your start script

The installer and setup wizard test your connection and walk you through this if anything is wrong.

### SearXNG (public)

Uses public SearXNG instances. No setup needed, but less reliable — many instances block the JSON API or rate limit heavily.

If you leave the instance URL blank during setup, sx will cycle through a built-in list of instances and use the first one that responds. You can also pick a specific instance yourself.

#### Finding a working public instance

This is unfortunately trial and error. Go to [searx.space](https://searx.space/) and look for instances that:

- Have **green uptime** (high availability)
- Are hosted in a region close to you (lower latency)
- Don't require CAPTCHAs or Cloudflare challenges

There's no easy way to tell from the listing whether an instance has JSON enabled. The installer and `sx --setup` will test the instance for you and tell you if it works. Common errors:

- **403 Forbidden** — JSON API is disabled on that instance. Try another.
- **429 Too Many Requests** — the instance is rate limiting you. Try another.
- **Could not connect** — the instance is down. Try another.

If you can't find a working public instance, consider running your own local SearXNG (option 3) or using DuckDuckGo (option 1) instead.

## Config

Settings are stored in `~/.config/sx/config.json`. You can edit this directly or use `sx --setup`.

## Requirements

- Python 3 (no pip dependencies)
