#!/usr/bin/env python3
"""
Local Scrum Management CLI
Used by Git Agent to manage issues, sprints, and board state
"""

import json
import os
from datetime import datetime
from pathlib import Path

SCRUM_DIR = Path(__file__).parent
CONFIG_FILE = SCRUM_DIR / "config.json"
BOARD_FILE = SCRUM_DIR / "board.json"
ISSUES_DIR = SCRUM_DIR / "issues"
SPRINTS_DIR = SCRUM_DIR / "sprints"


def load_json(filepath):
    """Load JSON file"""
    with open(filepath, 'r') as f:
        return json.load(f)


def save_json(filepath, data):
    """Save JSON file"""
    with open(filepath, 'w') as f:
        json.dump(data, f, indent=2)


def get_next_issue_id():
    """Get and increment next issue ID"""
    config = load_json(CONFIG_FILE)
    issue_id = config['next_issue_id']
    config['next_issue_id'] += 1
    save_json(CONFIG_FILE, config)
    return issue_id


def create_issue(title, assignee, labels, body="", acceptance_criteria=None, sprint=None):
    """Create a new issue"""
    issue_id = get_next_issue_id()

    issue = {
        "id": issue_id,
        "title": title,
        "body": body,
        "status": "backlog",
        "assignee": assignee,
        "labels": labels if isinstance(labels, list) else [labels],
        "created": datetime.now().isoformat(),
        "updated": datetime.now().isoformat(),
        "sprint": sprint,
        "acceptance_criteria": acceptance_criteria or [],
        "branch": None,
        "pr": None
    }

    # Save issue file
    issue_file = ISSUES_DIR / f"{issue_id:03d}.json"
    save_json(issue_file, issue)

    # Add to board (backlog column)
    board = load_json(BOARD_FILE)
    board['backlog'].append(issue_id)
    save_json(BOARD_FILE, board)

    print(f"✓ Issue #{issue_id} created: {title}")
    print(f"  Assignee: {assignee}")
    print(f"  Labels: {', '.join(issue['labels'])}")
    return issue_id


def update_issue_status(issue_id, new_status):
    """Move issue to different board column"""
    # Load issue
    issue_file = ISSUES_DIR / f"{issue_id:03d}.json"
    issue = load_json(issue_file)

    # Load board
    board = load_json(BOARD_FILE)

    # Remove from old column
    old_status = issue['status']
    if issue_id in board[old_status]:
        board[old_status].remove(issue_id)

    # Add to new column
    if issue_id not in board[new_status]:
        board[new_status].append(issue_id)

    # Update issue
    issue['status'] = new_status
    issue['updated'] = datetime.now().isoformat()

    # Save changes
    save_json(issue_file, issue)
    save_json(BOARD_FILE, board)

    print(f"✓ Issue #{issue_id} moved: {old_status} → {new_status}")


def get_issue(issue_id):
    """Get issue details"""
    issue_file = ISSUES_DIR / f"{issue_id:03d}.json"
    if not issue_file.exists():
        print(f"✗ Issue #{issue_id} not found")
        return None
    return load_json(issue_file)


def render_board():
    """Render ASCII board"""
    board = load_json(BOARD_FILE)

    print("\n" + "="*80)
    print("SCRUM BOARD".center(80))
    print("="*80 + "\n")

    columns = ["backlog", "todo", "in_progress", "review", "done"]
    headers = ["Backlog", "Todo", "In Progress", "Review", "Done"]

    # Print headers
    for header in headers:
        print(f"│ {header:14} ", end="")
    print("│")
    print("├" + "─"*16 * 5 + "┤")

    # Get max rows
    max_rows = max(len(board[col]) for col in columns)

    # Print rows
    for i in range(max_rows):
        for col in columns:
            if i < len(board[col]):
                issue_id = board[col][i]
                issue = get_issue(issue_id)
                if issue:
                    title = issue['title'][:12]
                    print(f"│ #{issue_id}: {title:9} ", end="")
                else:
                    print(f"│ {' ':14} ", end="")
            else:
                print(f"│ {' ':14} ", end="")
        print("│")

    print("└" + "─"*16 * 5 + "┘\n")

    # Print summary
    total = sum(len(board[col]) for col in columns)
    print(f"Total issues: {total}")
    for col, header in zip(columns, headers):
        count = len(board[col])
        print(f"  {header}: {count}")
    print()


def list_issues(status=None):
    """List all issues or filter by status"""
    board = load_json(BOARD_FILE)

    if status:
        columns = [status]
    else:
        columns = ["backlog", "todo", "in_progress", "review", "done"]

    for col in columns:
        if board[col]:
            print(f"\n{col.upper().replace('_', ' ')}:")
            for issue_id in board[col]:
                issue = get_issue(issue_id)
                if issue:
                    print(f"  #{issue['id']:3d} [{issue['assignee']:15s}] {issue['title']}")


if __name__ == "__main__":
    import sys

    if len(sys.argv) < 2:
        print("Usage: scrum_cli.py <command> [args]")
        print("\nCommands:")
        print("  create <title> <assignee> <labels> - Create issue")
        print("  status <issue_id> <new_status>     - Update status")
        print("  show <issue_id>                    - Show issue details")
        print("  board                              - Render board")
        print("  list [status]                      - List issues")
        sys.exit(1)

    command = sys.argv[1]

    if command == "create":
        title = sys.argv[2]
        assignee = sys.argv[3]
        labels = sys.argv[4].split(',')
        create_issue(title, assignee, labels)

    elif command == "status":
        issue_id = int(sys.argv[2])
        new_status = sys.argv[3]
        update_issue_status(issue_id, new_status)

    elif command == "show":
        issue_id = int(sys.argv[2])
        issue = get_issue(issue_id)
        if issue:
            print(json.dumps(issue, indent=2))

    elif command == "board":
        render_board()

    elif command == "list":
        status = sys.argv[2] if len(sys.argv) > 2 else None
        list_issues(status)

    else:
        print(f"Unknown command: {command}")
        sys.exit(1)
