# Business Development Meeting Memo Skill

This Skill takes business development meeting notes and Stage 1 research findings to produce one connected follow-up memo per meeting, tying relevant research directly to what came up in that meeting instead of listing notes and research separately.

Two rules are built in, so the same judgment gets applied every time:

1. **Complete follow-up requirements** — a follow-up only counts as complete if it names a specific action, one named owner, and a deadline, all based on what's actually in the meeting notes. If anything's missing, the memo says so instead of guessing.
2. **Rules for inclusion** — a research finding only gets included if it connects to something specific in the meeting notes. Each finding is labeled as confirmed or a general pattern. If nothing connects, the memo says that instead of leaving the section blank.

## How to run it

1. Place your meeting notes and research findings `.docx` files in the project folder.
2. Update the file paths at the top of `generate_memos.ps1` to match your own folders.
3. Run the script to split both documents into matched meeting/research pairs:
   ```
   powershell -File generate_memos.ps1
   ```
4. Have Claude draft each memo by applying the rules in `SKILL.md` to each pair.
5. Output is one Markdown file per meeting.

See `Validation Note.docx` for testing details, and `GRASP 1.docx` / `GRASP 2.docx` for the planning behind each stage.
