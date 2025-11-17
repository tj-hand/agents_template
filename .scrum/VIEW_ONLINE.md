# 🌐 View Scrum Board Online

## ⭐ BEST: Markdown Board (Renders on GitHub!)

**Just click this file on GitHub:**

**[📊 BOARD.md](BOARD.md)** ← Click to view the board!

GitHub renders this beautifully with:
- ✅ All 5 columns (Backlog, Todo, In Progress, Review, Done)
- ✅ All issues with assignees and labels
- ✅ Progress statistics
- ✅ Works perfectly on mobile/tablet
- ✅ No setup needed!

**This is the recommended way to view the board remotely.**

---

## 💻 Local Viewing (Interactive Dashboard)

For the full interactive HTML experience, clone locally:

```bash
git clone https://github.com/tj-hand/agents_template.git
cd agents_template/.scrum
python3 -m http.server 8000
```

Then open: http://localhost:8000/dashboard.html

Features:
- Auto-refresh every 30 seconds
- Click cards for details
- Beautiful gradient design
- Real-time updates

---

## 📊 Quick Terminal View

After cloning:
```bash
python3 .scrum/scrum_cli.py board
```

Shows ASCII board in terminal - fast and simple.

---

## 🔄 Updating the Board

When issues change, regenerate the markdown:

```bash
python3 .scrum/scrum_cli.py markdown > .scrum/BOARD.md
git add .scrum/BOARD.md
git commit -m "Update Scrum board"
git push
```

The updated board will be visible immediately on GitHub!
