#!/usr/bin/env python3
"""
Generate static HTML dashboard that can be viewed on GitHub
Embeds current board data directly in HTML
"""

import json
from pathlib import Path
from datetime import datetime

SCRUM_DIR = Path(__file__).parent
BOARD_FILE = SCRUM_DIR / "board.json"
CONFIG_FILE = SCRUM_DIR / "config.json"
ISSUES_DIR = SCRUM_DIR / "issues"
OUTPUT_FILE = SCRUM_DIR / "dashboard-static.html"


def load_json(filepath):
    with open(filepath, 'r') as f:
        return json.load(f)


def generate_static_dashboard():
    """Generate static HTML with embedded data"""

    # Load data
    board = load_json(BOARD_FILE)
    config = load_json(CONFIG_FILE)

    # Load all issues
    issues = {}
    for col in ["backlog", "todo", "in_progress", "review", "done"]:
        for issue_id in board[col]:
            issue_file = ISSUES_DIR / f"{issue_id:03d}.json"
            if issue_file.exists():
                issue = load_json(issue_file)
                issues[str(issue_id)] = {
                    "id": issue["id"],
                    "title": issue["title"],
                    "assignee": issue["assignee"],
                    "labels": issue["labels"],
                    "status": issue["status"]
                }

    # Generate JavaScript data
    board_data_js = json.dumps(board, indent=12)
    issues_data_js = json.dumps(issues, indent=12)
    generated_time = datetime.now().strftime('%Y-%m-%d %H:%M:%S')

    # HTML template
    html = f'''<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Scrum Board - {config["project"]}</title>
    <style>
        * {{
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }}

        body {{
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            padding: 20px;
            min-height: 100vh;
        }}

        .container {{
            max-width: 1400px;
            margin: 0 auto;
        }}

        header {{
            background: white;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
            margin-bottom: 30px;
        }}

        h1 {{
            color: #333;
            font-size: 32px;
            margin-bottom: 10px;
        }}

        .stats {{
            display: flex;
            gap: 20px;
            margin-top: 20px;
            flex-wrap: wrap;
        }}

        .stat-card {{
            background: #f8f9fa;
            padding: 15px 25px;
            border-radius: 8px;
            border-left: 4px solid #667eea;
        }}

        .stat-card .number {{
            font-size: 28px;
            font-weight: bold;
            color: #667eea;
        }}

        .stat-card .label {{
            color: #6c757d;
            font-size: 14px;
        }}

        .board {{
            display: grid;
            grid-template-columns: repeat(5, 1fr);
            gap: 20px;
            margin-bottom: 30px;
        }}

        @media (max-width: 1200px) {{
            .board {{
                grid-template-columns: repeat(3, 1fr);
            }}
        }}

        @media (max-width: 768px) {{
            .board {{
                grid-template-columns: 1fr;
            }}
        }}

        .column {{
            background: white;
            border-radius: 10px;
            padding: 20px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
            min-height: 400px;
        }}

        .column-header {{
            font-size: 18px;
            font-weight: 600;
            margin-bottom: 15px;
            padding-bottom: 10px;
            border-bottom: 2px solid #e9ecef;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }}

        .column-count {{
            background: #e9ecef;
            padding: 4px 12px;
            border-radius: 12px;
            font-size: 14px;
            color: #6c757d;
        }}

        .backlog .column-header {{ border-bottom-color: #6c757d; }}
        .todo .column-header {{ border-bottom-color: #0d6efd; }}
        .in-progress .column-header {{ border-bottom-color: #ffc107; }}
        .review .column-header {{ border-bottom-color: #fd7e14; }}
        .done .column-header {{ border-bottom-color: #28a745; }}

        .issue-card {{
            background: #f8f9fa;
            border-radius: 8px;
            padding: 15px;
            margin-bottom: 12px;
            border-left: 4px solid #667eea;
            cursor: pointer;
            transition: all 0.2s;
        }}

        .issue-card:hover {{
            transform: translateY(-2px);
            box-shadow: 0 4px 8px rgba(0,0,0,0.15);
        }}

        .backlog .issue-card {{ border-left-color: #6c757d; }}
        .todo .issue-card {{ border-left-color: #0d6efd; }}
        .in-progress .issue-card {{ border-left-color: #ffc107; }}
        .review .issue-card {{ border-left-color: #fd7e14; }}
        .done .issue-card {{ border-left-color: #28a745; }}

        .issue-id {{
            font-weight: bold;
            color: #667eea;
            font-size: 14px;
            margin-bottom: 8px;
        }}

        .issue-title {{
            color: #333;
            font-size: 15px;
            margin-bottom: 10px;
            line-height: 1.4;
        }}

        .issue-meta {{
            display: flex;
            gap: 8px;
            flex-wrap: wrap;
        }}

        .label {{
            background: #e9ecef;
            padding: 4px 10px;
            border-radius: 4px;
            font-size: 12px;
            color: #495057;
        }}

        .assignee {{
            background: #667eea;
            color: white;
            padding: 4px 10px;
            border-radius: 4px;
            font-size: 12px;
        }}

        .empty-column {{
            color: #adb5bd;
            text-align: center;
            padding: 40px 20px;
            font-style: italic;
        }}

        .info-banner {{
            background: #d1ecf1;
            border: 1px solid #0dcaf0;
            color: #055160;
            padding: 15px;
            border-radius: 8px;
            margin-bottom: 20px;
            text-align: center;
        }}

        .github-link {{
            color: #667eea;
            text-decoration: none;
            font-weight: 600;
        }}

        .github-link:hover {{
            text-decoration: underline;
        }}
    </style>
</head>
<body>
    <div class="container">
        <div class="info-banner">
            📸 Static snapshot from {generated_time} |
            <a href="https://github.com/tj-hand/agents_template" class="github-link" target="_blank">View on GitHub →</a>
        </div>

        <header>
            <h1>🎯 Scrum Board - {config["project"]}</h1>
            <div style="color: #6c757d; font-size: 14px; margin-top: 10px;">
                <span>Snapshot generated: {generated_time}</span>
            </div>
            <div class="stats" id="stats"></div>
        </header>

        <div class="board" id="board"></div>
    </div>

    <script>
        // Embedded data from {generated_time}
        const BOARD_DATA = {board_data_js};

        const ISSUES = {issues_data_js};

        function renderStats(board, issues) {{
            const totalIssues = Object.keys(issues).length;
            const doneCount = board.done.length;
            const progress = Math.round((doneCount / totalIssues) * 100) || 0;

            const statsHTML = `
                <div class="stat-card">
                    <div class="number">${{totalIssues}}</div>
                    <div class="label">Total Issues</div>
                </div>
                <div class="stat-card">
                    <div class="number">${{board.backlog.length}}</div>
                    <div class="label">Backlog</div>
                </div>
                <div class="stat-card">
                    <div class="number">${{board.in_progress.length}}</div>
                    <div class="label">In Progress</div>
                </div>
                <div class="stat-card">
                    <div class="number">${{doneCount}}</div>
                    <div class="label">Completed</div>
                </div>
                <div class="stat-card">
                    <div class="number">${{progress}}%</div>
                    <div class="label">Progress</div>
                </div>
            `;
            document.getElementById('stats').innerHTML = statsHTML;
        }}

        function renderBoard(board, issues) {{
            const columns = [
                {{ key: 'backlog', title: 'Backlog', class: 'backlog' }},
                {{ key: 'todo', title: 'Todo', class: 'todo' }},
                {{ key: 'in_progress', title: 'In Progress', class: 'in-progress' }},
                {{ key: 'review', title: 'Review', class: 'review' }},
                {{ key: 'done', title: 'Done', class: 'done' }}
            ];

            let boardHTML = '';

            for (const column of columns) {{
                const issueIds = board[column.key];
                const count = issueIds.length;

                boardHTML += `
                    <div class="column ${{column.class}}">
                        <div class="column-header">
                            <span>${{column.title}}</span>
                            <span class="column-count">${{count}}</span>
                        </div>
                `;

                if (issueIds.length === 0) {{
                    boardHTML += '<div class="empty-column">No issues</div>';
                }} else {{
                    for (const issueId of issueIds) {{
                        const issue = issues[issueId];
                        if (issue) {{
                            boardHTML += `
                                <div class="issue-card" onclick="alert('Issue #${{issue.id}}\\\\n${{issue.title}}\\\\n\\\\nAssignee: ${{issue.assignee}}\\\\nLabels: ${{issue.labels.join(', ')}}')">
                                    <div class="issue-id">#${{issue.id}}</div>
                                    <div class="issue-title">${{issue.title}}</div>
                                    <div class="issue-meta">
                                        <span class="assignee">${{issue.assignee}}</span>
                                        ${{issue.labels.map(label =>
                                            `<span class="label">${{label}}</span>`
                                        ).join('')}}
                                    </div>
                                </div>
                            `;
                        }}
                    }}
                }}

                boardHTML += '</div>';
            }}

            document.getElementById('board').innerHTML = boardHTML;
        }}

        // Render on load
        renderStats(BOARD_DATA, ISSUES);
        renderBoard(BOARD_DATA, ISSUES);
    </script>
</body>
</html>'''

    # Write to file
    with open(OUTPUT_FILE, 'w') as f:
        f.write(html)

    print(f"✅ Static dashboard generated: {OUTPUT_FILE}")
    print(f"   Can be viewed on GitHub at:")
    print(f"   https://github.com/tj-hand/agents_template/blob/main/.scrum/dashboard-static.html")
    print(f"   Or use GitHub Pages: https://tj-hand.github.io/agents_template/.scrum/dashboard-static.html")


if __name__ == "__main__":
    generate_static_dashboard()
