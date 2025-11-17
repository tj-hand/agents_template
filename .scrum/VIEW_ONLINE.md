# 🌐 View Scrum Board Online

GitHub doesn't render HTML files directly, but you can view the dashboard using these methods:

## 🚀 Quick View (No Setup)

### HTMLPreview.github.io
Click this link to view the dashboard instantly:

**[View Scrum Dashboard](https://htmlpreview.github.io/?https://github.com/tj-hand/agents_template/blob/claude/hello-world-test-01BrhfQBbPT8AGhuXyfQxS2F/.scrum/dashboard-static.html)**

This service renders the HTML file in your browser.

---

## 📝 Alternative: Markdown View

For a simpler view, check the latest markdown report:

[View Latest Report](.scrum/reports/)

Or generate a new one:
```bash
python3 .scrum/scrum_cli.py markdown
```

---

## 💻 Local Viewing (Best Experience)

Clone and view locally for the best experience:

```bash
git clone https://github.com/tj-hand/agents_template.git
cd agents_template/.scrum
python3 -m http.server 8000
```

Then open: http://localhost:8000/dashboard.html

---

## 📊 Quick Terminal View

After cloning:
```bash
python3 .scrum/scrum_cli.py board
```
