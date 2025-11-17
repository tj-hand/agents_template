#!/bin/bash
# Quick script to view the Scrum board in different formats

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

case "${1:-terminal}" in
    html|web|browser)
        echo "🌐 Opening HTML dashboard..."
        echo "Starting local server on http://localhost:8000"
        cd "$SCRIPT_DIR"
        python3 -m http.server 8000
        ;;

    static|github)
        echo "📸 Generating static HTML snapshot for GitHub..."
        python3 "$SCRIPT_DIR/generate_static.py"
        echo ""
        echo "✅ Static dashboard generated!"
        echo "   Commit and push to view on GitHub"
        ;;

    markdown|md)
        echo "📝 Generating markdown report..."
        python3 "$SCRIPT_DIR/scrum_cli.py" markdown
        ;;

    terminal|text|cli)
        echo "📊 Terminal board view:"
        python3 "$SCRIPT_DIR/scrum_cli.py" board
        ;;

    list)
        echo "📋 Issue list:"
        python3 "$SCRIPT_DIR/scrum_cli.py" list
        ;;

    *)
        echo "Usage: $0 [format]"
        echo ""
        echo "Formats:"
        echo "  terminal   - ASCII board in terminal (default)"
        echo "  static     - Generate static HTML for GitHub viewing"
        echo "  html       - Start local server for interactive dashboard"
        echo "  markdown   - Generate markdown report"
        echo "  list       - List all issues"
        echo ""
        echo "Examples:"
        echo "  $0              # Show terminal board"
        echo "  $0 static       # Generate GitHub-viewable HTML"
        echo "  $0 html         # Start local web server"
        echo "  $0 markdown     # Generate markdown report"
        ;;
esac
