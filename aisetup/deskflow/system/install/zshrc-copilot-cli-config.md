---
name: zshrc-copilot-cli-config.md
version: 00.00
updated: 2026-08-03
status: proposal — paste this block into your ~/.zshrc
---

# Copilot CLI Config in .zshrc

Copy the block below into your ~/.zshrc to configure and provide options for Copilot CLI.

```sh
################################################################
# > MARK: Copilot CLI
################################################################
active_copilot_model="openai/gpt-5.6-luna"          # $0.05 , 51 iq = 1020 , md*,h,xh,mx
# active_copilot_model="z-ai/glm-5.2"               # $0.59 , 51 iq = 86   , h*,xh
# active_copilot_model="moonshotai/kimi-k3"         # $0.86 , 57 iq = 66   , h,mx*
# active_copilot_model="anthropic/claude-fable-5"   # $3.15 , 60 iq = 19   , h*,xh,mx
# active_copilot_model="anthropic/claude-opus-4.6"  # $2.15 , 44 iq = 20   , h*,mx

if command -v copilot &> /dev/null; then
  # for effort == max default:
  # active_copilot_effort="max"
  # [[ "$active_copilot_model" == "z-ai/glm-5.2" ]] && active_copilot_effort="xhigh"

  # for effort == xhigh default:
  active_copilot_effort="xhigh"
  [[ "$active_copilot_model" == "moonshotai/kimi-k3" || "$active_copilot_model" == "anthropic/claude-opus-4.6" ]] && active_copilot_effort="high"

  # always max for luna
  [[ "$active_copilot_model" == "openai/gpt-5.6-luna" ]] && active_copilot_effort="max"

  copilot() {
    COPILOT_PROVIDER_BASE_URL="${COPILOT_PROVIDER_BASE_URL:-https://openrouter.ai/api/v1}" \
    COPILOT_PROVIDER_API_KEY="${COPILOT_PROVIDER_API_KEY:-$(security find-generic-password -s openrouter-me-ghcp -w)}" \
    COPILOT_MODEL="${COPILOT_MODEL:-$active_copilot_model}" \
    command copilot --effort $active_copilot_effort "$@"
  }
fi
```
