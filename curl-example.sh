#/usr/bin/env bash
set -eu -o pipefail
# Ice only accepts 16-byte `Sec-WebSocket-Key` or else returns empty body
curl -v --include --no-buffer --header "Connection: Upgrade" --header "Upgrade: websocket" --header "Host: 127.0.0.1:10000" --header "Origin: http://127.0.0.1:10000" --header "Sec-WebSocket-Protocol: ice.zeroc.com" --header "Sec-WebSocket-Version: 13" --header "Sec-WebSocket-Key: Cfh/QP6zJNGutT8Go/bM7g==" http://127.0.0.1:10000/
