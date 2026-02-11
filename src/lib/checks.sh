#!/bin/bash

# --- Prerequisite & OS Checks for Clawfather ---

# Optional first arg: "skip_ollama" to skip Ollama install/check (when USE_OLLAMA=false)
check_prerequisites() {
    local skip_ollama="${1:-}"
    header "Checking Prerequisites" "1"
    _prereq_lines=1

    # Homebrew (macOS only)
    if [ "$OS_TYPE" == "macos" ]; then
        if ! command -v brew &> /dev/null; then
            _prereq_lines=$((_prereq_lines + 1))
            warn "Homebrew not found. Installing..."
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        else
            _prereq_lines=$((_prereq_lines + 1))
            success "Homebrew is ready"
        fi
    fi

    # Docker
    if ! command -v docker &> /dev/null; then
        case "$OS_TYPE" in
            macos)
                if [ ! -d "/Applications/Docker.app" ]; then
                    _prereq_lines=$((_prereq_lines + 1))
                    warn "Docker not found. Installing via Homebrew..."
                    brew install --cask docker
                    _prereq_lines=$((_prereq_lines + 1))
                    warn "Please open Docker Desktop from Applications now!"
                    if [ "$YES_TO_ALL" = true ]; then
                        _prereq_lines=$((_prereq_lines + 1))
                        printf "   Press [Enter] once Docker Desktop is running... %b(auto)%b\n" "$CYAN" "$RESET"
                    else
                        read -p "   Press [Enter] once Docker Desktop is running..."
                    fi
                else
                    _prereq_lines=$((_prereq_lines + 1))
                    success "Docker is ready"
                fi
                ;;
            linux)
                _prereq_lines=$((_prereq_lines + 1))
                warn "Docker not found. Installing Docker Engine..."
                case "$DISTRO" in
                    ubuntu|debian)
                        curl -fsSL https://get.docker.com -o /tmp/get-docker.sh
                        sudo sh /tmp/get-docker.sh
                        sudo usermod -aG docker "$USER"
                        rm /tmp/get-docker.sh
                        _prereq_lines=$((_prereq_lines + 1))
                        info "Docker installed. You may need to log out and back in for group changes."
                        ;;
                    centos|rhel|fedora)
                        if [ "$DISTRO" == "fedora" ]; then PKG="dnf"; else PKG="yum"; fi
                        sudo $PKG install -y docker
                        sudo systemctl start docker
                        sudo systemctl enable docker
                        sudo usermod -aG docker "$USER"
                        _prereq_lines=$((_prereq_lines + 1))
                        info "Docker installed. You may need to log out and back in for group changes."
                        ;;
                    *)
                        _prereq_lines=$((_prereq_lines + 1))
                        error "Unsupported Linux distribution: $DISTRO"
                        _prereq_lines=$((_prereq_lines + 1))
                        error "Please install Docker manually: https://docs.docker.com/engine/install/"
                        exit 1
                        ;;
                esac
                ;;
        esac
    else
        _prereq_lines=$((_prereq_lines + 1))
        success "Docker is ready"
    fi

    # Ollama (skip when skip_ollama is set, e.g. cloud-only install)
    if [ "$skip_ollama" = "skip_ollama" ]; then
        # Print to stdout so the next wizard step (Wipe Docker) follows with no extra newline (stderr flush can add a blank line)
        _prereq_lines=$((_prereq_lines + 1))
        printf "%b%s %b[INFO]%b %s\n" "$(get_accent)" "$TREE_MID" "$CYAN" "$RESET" "Skipping Ollama (cloud-only setup)"
    elif ! command -v ollama &> /dev/null; then
        case "$OS_TYPE" in
            macos)
                _prereq_lines=$((_prereq_lines + 1))
                warn "Ollama not found. Installing via Homebrew..."
                brew install ollama
                brew services start ollama
                _prereq_lines=$((_prereq_lines + 1))
                info "Waiting for Ollama to wake up..."
                sleep 5
                ;;
            linux)
                _prereq_lines=$((_prereq_lines + 1))
                warn "Ollama not found. Installing via official script..."
                curl -fsSL https://ollama.com/install.sh | sh
                if command -v systemctl &> /dev/null; then
                    sudo systemctl start ollama 2>/dev/null || true
                    sudo systemctl enable ollama 2>/dev/null || true
                fi
                _prereq_lines=$((_prereq_lines + 1))
                info "Waiting for Ollama to wake up..."
                sleep 5
                ;;
        esac
    else
        _prereq_lines=$((_prereq_lines + 1))
        success "Ollama is installed"
        if [ "$OS_TYPE" == "macos" ]; then
            if ! pgrep -x "ollama" > /dev/null; then
                _prereq_lines=$((_prereq_lines + 1))
                warn "Ollama service stopped. Starting..."
                brew services start ollama
                sleep 2
            else
                _prereq_lines=$((_prereq_lines + 1))
                success "Ollama service is running"
            fi
        elif [ "$OS_TYPE" == "linux" ]; then
            if command -v systemctl &> /dev/null; then
                if ! systemctl is-active --quiet ollama 2>/dev/null; then
                    _prereq_lines=$((_prereq_lines + 1))
                    warn "Ollama service stopped. Starting..."
                    sudo systemctl start ollama
                    sleep 2
                else
                    _prereq_lines=$((_prereq_lines + 1))
                    success "Ollama service is running"
                fi
            fi
        fi
    fi
    printf "\033[${_prereq_lines}A\r\033[K"
    printf "%b%s%b%b%b\033[K\n" "$(get_accent)" "$DIAMOND_EMPTY" "$(get_accent)" "Checking Prerequisites" "$RESET"
    printf "\033[$(($_prereq_lines - 1))B"
}
