# 🦞 Skill Sync Utility

The `sync_skills.sh` script is a universal tool for managing OpenClaw skills. It uses your `CLAWHUB_SKILLS.md` file as the source of truth to automatically download, extract, and organize skills into their respective categories.

## 🚀 How to Run

From the project root:
```bash
bash src/sync_skills.sh
```

## 🛠️ How it Works

1.  **Parsing**: The script reads `CLAWHUB_SKILLS.md` and looks for category headers and skill download links.
2.  **Metadata**: It identifies the target folder for each category using a hidden comment in the markdown: `## Category <!-- folder: FolderName -->`.
3.  **Download & Extraction**:
    - Extracted slugs are used to download ZIP packages from the ClawHub API.
    - Skills are extracted into `skills/FolderName/slug`.
    - ZIP files are automatically cleaned up after extraction.
4.  **Efficiency**: The script skips skills that are already installed.
5.  **Robustness**: It includes a 3-attempt retry logic for failed downloads or invalid ZIP files.

## 📁 Adding New Skills

To add a new skill to the sync process:
1.  Open [CLAWHUB_SKILLS.md](./CLAWHUB_SKILLS.md).
2.  Ensure the category header has the `<!-- folder: ... -->` metadata.
3.  Add the skill to the table with its download link (containing `slug=...`).
4.  Run the script!

## 📜 UI Features

The script provides a "fancy" terminal UI:
- **Colors & Emojis** for clear visual status.
- **One-liner Progress**: Keeps the terminal clean while skipping existing skills.
- **Summary Table**: Shows total count, downloads, skips, and failures at the end.
