# OpenClaw Preparation Guide (macOS)

Before installing OpenClaw, follow these steps to secure your environment, protect your API keys, and prevent accidental data loss.

## 1. Secure API Key Management

Never hardcode API keys in scripts or configuration files that might be shared or committed to Git.

### Option A: Use a Shell Profile (Global)
Add keys to your `.zshrc` or `.bash_profile` to make them available to the Gateway and all skills.
1. Open your profile: `nano ~/.zshrc`
2. Add your keys: `export OPENAI_API_KEY='your-key-here'`
3. Apply changes: `source ~/.zshrc`

### Option B: Use `.env` Files (Project Specific)
Create a `.env` file in your OpenClaw root directory.
1. Create the file: `touch .env`
2. Add keys: `ANTHROPIC_API_KEY=your-key-here`
3. **CRITICAL**: Add `.env` to your `.gitignore` to prevent accidental leaks.

---

## 2. Preventing Accidental Deletion

By default, the `rm` command deletes files permanently. We recommend using `trash`, which moves files to the macOS Trash Bin instead.

### Install `trash`
```bash
brew install trash
```

### Alias `rm` for Safety
Add this to your `~.zshrc` to replace the dangerous `rm` command with a safer version.
```bash
alias rm='trash'
```
*Note: If you truly need to bypass the trash, use `/bin/rm`.*

---

## 3. Sandboxing & Workspace Isolation

To prevent an agent from accessing your entire `$HOME` directory, isolate its workspace.

### Workspace Permissions
Create a dedicated folder for OpenClaw and restrict access so other local processes (or users) cannot peek into it.
```bash
mkdir ~/OpenClawWorkspace
chmod 700 ~/OpenClawWorkspace
```

### Dedicated User Account (Pro Tip)
For maximum safety, create a standard (non-admin) macOS user account named `openclaw` and run the Gateway from there. This ensures that even a compromised agent cannot access your personal files, Keychain, or System Settings.

---

## 4. macOS Permission Preparation (TCC)

OpenClaw will request several native permissions. You can prepare for these in **System Settings > Privacy & Security**:
- **Accessibility**: Required for UI automation and click control.
- **Screen Recording**: Required for "visual" skills (Peekaboo, Vision).
- **Automation**: Required for AppleScript control of apps like Music, Mail, and Notes.

> [!IMPORTANT]
> Always review the "Transparency, Consent, and Control" (TCC) prompts. If you accidentally click "Deny," you must re-enable it manually in System Settings.
