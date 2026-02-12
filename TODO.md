
- I need this:
◆  Enable hooks?
│  ◻ Skip for now
│  ◼ 🚀 boot-md (Run BOOT.md on gateway startup)
│  ◼ 📝 command-logger (Log all command events to a centralized audit file)
│  ◼ 💾 session-memory (Save session context to memory when /new command is issued)
- dont set default values again for gateway (port, etc)
- test all docker images [tested: 2/5]
  - fix commands for fourplayers/openclaw, test more
- test on Linux (should work)
- Start Docker -> No -> Continue setup next time
- now that pairing works -> maybe we dont need the allowInsecure + reboot hack?
- test other options in wizzard (remote gateway, tailsafe, loopback, etc)
- auto security check skills as post install step
- remove the bundled skills that comes with openclaw!!! Heard of Twitter incident?
- NEW: allow to select/deselect my selected skills to install inside wizzard
- move 'ywizz' library to a separate repo
- add 'docs' reader inside wizzard. Or Deepwiki?
- build openclaw from source option using Dockerfile?

