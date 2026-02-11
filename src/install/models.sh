#!/bin/bash

# --- Model Selection & Setup ---
# Requires: USE_OLLAMA, lib/models.sh (verify_local_models_health), ywizz

run_model_setup() {
    # Build option lists based on USE_OLLAMA
    local CLOUD_GENERAL="zai/glm-4.7
zai/glm-4.6v
zai/glm-4.6
zai/glm-4.7-flash
google/gemini-flash-latest
google/gemini-3-pro-preview
google/gemini-2.5-pro
google-antigravity/gemini-3-pro-high
google-antigravity/gemini-3-flash
google-antigravity/claude-sonnet-4-5
anthropic/claude-sonnet-4-5
anthropic/claude-haiku-4-5
anthropic/claude-3-7-sonnet-latest
custom
I will setup later myself"

    local CLOUD_LITE="zai/glm-4.7-flash
zai/glm-4.5-flash
zai/glm-4.5-air
google/gemini-3-flash-preview
google/gemini-flash-latest
google/gemini-2.5-flash-lite
google-antigravity/gemini-3-flash
anthropic/claude-haiku-4-5
anthropic/claude-3-5-haiku-latest
custom
I will setup later myself"

    local CLOUD_HEAVY="zai/glm-4.7
zai/glm-4.6
zai/glm-4.6v
google/gemini-3-pro-preview
google/gemini-2.5-pro
google-antigravity/gemini-3-pro-high
google-antigravity/claude-opus-4-5-thinking
google-antigravity/claude-sonnet-4-5-thinking
anthropic/claude-opus-4-5
anthropic/claude-3-7-sonnet-20250219
anthropic/claude-3-7-sonnet-latest
anthropic/claude-3-5-sonnet-20240620
anthropic/claude-sonnet-4
custom
I will setup later myself"

    local CLOUD_FALLBACK_GENERAL="google/gemini-3-pro-preview
google/gemini-flash-latest
google/gemini-3.5-pro
google-antigravity/gemini-3-pro-high
google-antigravity/gemini-3-flash
google-antigravity/claude-sonnet-4-5
anthropic/claude-sonnet-4-5
anthropic/claude-haiku-4-5
anthropic/claude-3-7-sonnet-latest
zai/glm-4.7
zai/glm-4.6v
zai/glm-4.6
zai/glm-4.7-flash
custom
I will setup later myself"

    local CLOUD_FALLBACK_LITE="google/gemini-3-flash-preview
google/gemini-flash-latest
google/gemini-2.5-flash-lite
google-antigravity/gemini-3-flash
anthropic/claude-haiku-4-5
anthropic/claude-3-5-haiku-latest
zai/glm-4.7-flash
zai/glm-4.5-flash
zai/glm-4.5-air
custom
I will setup later myself"

    local CLOUD_FALLBACK_HEAVY="google/gemini-3-pro-preview
google-antigravity/gemini-3-pro-high
google-antigravity/claude-opus-4-5-thinking
google-antigravity/claude-sonnet-4-5-thinking
anthropic/claude-opus-4-5
anthropic/claude-3-7-sonnet-20250219
anthropic/claude-3-7-sonnet-latest
anthropic/claude-3-5-sonnet-20240620
anthropic/claude-sonnet-4
zai/glm-4.7
zai/glm-4.6
zai/glm-4.6v
custom
I will setup later myself"

    local OPTS_GENERAL OPTS_LITE OPTS_HEAVY OPTS_FALLBACK_GENERAL OPTS_FALLBACK_LITE OPTS_FALLBACK_HEAVY
    if [ "$USE_OLLAMA" = true ]; then
        OPTS_GENERAL="[LOCAL]ollama/glm-4.7
[LOCAL]ollama/gemini-3-pro
[LOCAL]ollama/claude-3-sonnet-20250219
$CLOUD_GENERAL"
        OPTS_LITE="[LOCAL]ollama/glm-4.7-flash
[LOCAL]ollama/gemini-2.0-flash-lite
[LOCAL]ollama/claude-3-haiku-20240307
$CLOUD_LITE"
        OPTS_HEAVY="[LOCAL]ollama/glm-4.7-flash
[LOCAL]ollama/gemini-3-pro
[LOCAL]ollama/claude-opus-4-5-thinking
$CLOUD_HEAVY"
        OPTS_FALLBACK_GENERAL="[LOCAL]ollama/glm-4.7
[LOCAL]ollama/gemini-3-pro
[LOCAL]ollama/claude-3-sonnet-20250219
$CLOUD_FALLBACK_GENERAL"
        OPTS_FALLBACK_LITE="[LOCAL]ollama/glm-4.7-flash
[LOCAL]ollama/gemini-2.0-flash-lite
[LOCAL]ollama/claude-3-haiku-20240307
$CLOUD_FALLBACK_LITE"
        OPTS_FALLBACK_HEAVY="[LOCAL]ollama/glm-4.7-flash
[LOCAL]ollama/gemini-2.0-flash-lite
[LOCAL]ollama/claude-opus-4-5-thinking
$CLOUD_FALLBACK_HEAVY"
    else
        OPTS_GENERAL="$CLOUD_GENERAL"
        OPTS_LITE="$CLOUD_LITE"
        OPTS_HEAVY="$CLOUD_HEAVY"
        OPTS_FALLBACK_GENERAL="$CLOUD_FALLBACK_GENERAL"
        OPTS_FALLBACK_LITE="$CLOUD_FALLBACK_LITE"
        OPTS_FALLBACK_HEAVY="$CLOUD_FALLBACK_HEAVY"
    fi

    resolve_model_choice() {
        local prompt="$1" options="$2" out_var="$3" sel_var="${4:-_sel}"
        # secure_enter_ms=0: accept Enter immediately (avoids ignored-Enter exit bug on fast selection)
        select_tui "$prompt" "$options" "" "" "$sel_var" 0 "true" 1 0 0
        local sel="${!sel_var}"
        if [[ "$sel" == *"custom"* ]]; then
            ask_tui "Enter provider/model (e.g. zai/glm-4.7-flash)" "" "$out_var" "$TREE_TOP" 1 0
        elif [[ "$sel" == *"I will setup later"* ]]; then
            eval "$out_var=\"\""
        else
            sel="${sel#\[LOCAL\]}"
            eval "$out_var=\"$sel\""
        fi
    }

    resolve_model_choice "Which model to use for \"general\" tasks?" "$OPTS_GENERAL" "MODEL_GENERAL" "MODEL_GENERAL_SEL"
    resolve_model_choice "Which model to use for \"light\" tasks? ${DIM}${accent_color}subagents${RESET} ${accent_color}|${RESET} ${DIM}${accent_color}heartbeat${RESET}" "$OPTS_LITE" "MODEL_LITE" "MODEL_LITE_SEL"
    resolve_model_choice "Which model to use for \"heavy\" tasks? ${DIM}${accent_color}complex${RESET} ${accent_color}|${RESET} ${DIM}${accent_color}coding${RESET}" "$OPTS_HEAVY" "MODEL_HEAVY" "MODEL_HEAVY_SEL"
    ask_yes_no_tui "Setup fallback models?" "y" "FALLBACKS_SETUP_SEL" 1 0
    [[ "$FALLBACKS_SETUP_SEL" =~ ^[Yy] ]] && FALLBACKS_SETUP=true || FALLBACKS_SETUP=false
    if [ "$FALLBACKS_SETUP" = true ]; then
        resolve_model_choice "Which \"fallback\" model to use for \"general\" tasks?" "$OPTS_FALLBACK_GENERAL" "FALLBACK_GENERAL" "FB_GENERAL_SEL"
        resolve_model_choice "Which \"fallback\" model to use for \"light\" tasks? ${DIM}${accent_color}subagents${RESET} ${accent_color}|${RESET} ${DIM}${accent_color}heartbeat${RESET}" "$OPTS_FALLBACK_LITE" "FALLBACK_LITE" "FB_LITE_SEL"
        resolve_model_choice "Which \"fallback\" model to use for \"heavy\" tasks? ${DIM}${accent_color}complex${RESET} ${accent_color}|${RESET} ${DIM}${accent_color}coding${RESET}" "$OPTS_FALLBACK_HEAVY" "FALLBACK_HEAVY" "FB_HEAVY_SEL"
    fi

    if [ "$USE_OLLAMA" = true ]; then
        header_tui "Local LLM smoke test" "" "1"
        if command -v ollama &>/dev/null; then
            success "Ollama is installed"
        else
            warn "Ollama is not installed. Install it for local models: brew install ollama"
        fi
        if pgrep -x "ollama" >/dev/null || pgrep -f "ollama serve" >/dev/null; then
            success "Ollama service is running"
        else
            warn "Ollama service is not running. Start it for local models: brew services start ollama"
        fi
        LOCAL_MODELS=()
        for m in "$MODEL_GENERAL" "$MODEL_LITE" "$MODEL_HEAVY" "$FALLBACK_GENERAL" "$FALLBACK_LITE" "$FALLBACK_HEAVY"; do
            [ -z "$m" ] && continue
            [[ "$m" != ollama/* ]] && continue
            LOCAL_MODELS+=("$m")
        done
        if [ ${#LOCAL_MODELS[@]} -gt 0 ]; then
            verify_local_models_health "${LOCAL_MODELS[@]}"
        fi
    fi

    if [ -z "$MODEL_LITE" ] && [ -n "$MODEL_GENERAL" ]; then MODEL_LITE="$MODEL_GENERAL"; fi
    if [ -z "$MODEL_HEAVY" ] && [ -n "$MODEL_GENERAL" ]; then MODEL_HEAVY="$MODEL_GENERAL"; fi
    if [ -z "$FALLBACK_LITE" ] && [ -n "$FALLBACK_GENERAL" ]; then FALLBACK_LITE="$FALLBACK_GENERAL"; fi
    if [ -z "$FALLBACK_HEAVY" ] && [ -n "$FALLBACK_GENERAL" ]; then FALLBACK_HEAVY="$FALLBACK_GENERAL"; fi

    # Models are written by gateway.sh write_config (preserves gateway, workspace, docker, ollama, security)
}
