<?php
/**
 * Webhook Endpoint for Git Pull
 *
 * This PHP script can be placed in the project-state directory to trigger
 * git pulls via HTTP requests.
 *
 * Usage: POST https://scrum.dotmkt.com.br/webhook.php?secret=YOUR_SECRET
 *
 * Security: Change the WEBHOOK_SECRET constant below
 */

// Configuration
define('WEBHOOK_SECRET', 'change-this-secret-key'); // CHANGE THIS!
define('LOG_FILE', '/var/log/project-webhook.log');
define('PROJECT_PATH', '/var/www/project-agents-template'); // Adjust as needed

// Helper function to log messages
function logMessage($message) {
    $timestamp = date('Y-m-d H:i:s');
    file_put_contents(LOG_FILE, "[$timestamp] $message\n", FILE_APPEND);
}

// Helper function to send JSON response
function jsonResponse($status, $message, $data = []) {
    http_response_code($status);
    header('Content-Type: application/json');
    echo json_encode(array_merge(['status' => $status < 300 ? 'success' : 'error', 'message' => $message], $data));
    exit;
}

// Only allow POST requests
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    jsonResponse(405, 'Method not allowed');
}

// Verify webhook secret
$receivedSecret = $_GET['secret'] ?? $_SERVER['HTTP_X_WEBHOOK_SECRET'] ?? '';

if ($receivedSecret !== WEBHOOK_SECRET) {
    logMessage('ERROR: Invalid webhook secret from IP: ' . ($_SERVER['REMOTE_ADDR'] ?? 'unknown'));
    jsonResponse(401, 'Unauthorized');
}

// Optional: verify GitHub signature if using GitHub webhooks
// $signature = $_SERVER['HTTP_X_HUB_SIGNATURE_256'] ?? '';
// $payload = file_get_contents('php://input');
// $expected = 'sha256=' . hash_hmac('sha256', $payload, WEBHOOK_SECRET);
// if (!hash_equals($expected, $signature)) {
//     jsonResponse(401, 'Invalid signature');
// }

logMessage('INFO: Webhook triggered from IP: ' . ($_SERVER['REMOTE_ADDR'] ?? 'unknown'));

// Change to project directory
if (!is_dir(PROJECT_PATH)) {
    logMessage('ERROR: Project path not found: ' . PROJECT_PATH);
    jsonResponse(404, 'Project path not found');
}

chdir(PROJECT_PATH);

// Get current commit
exec('git rev-parse HEAD 2>&1', $beforeOutput, $beforeCode);
$beforeCommit = trim($beforeOutput[0] ?? 'unknown');

// Fetch and pull
exec('git fetch origin 2>&1', $fetchOutput, $fetchCode);
exec('git pull origin $(git rev-parse --abbrev-ref HEAD) 2>&1', $pullOutput, $pullCode);

// Get new commit
exec('git rev-parse HEAD 2>&1', $afterOutput, $afterCode);
$afterCommit = trim($afterOutput[0] ?? 'unknown');

if ($pullCode !== 0) {
    logMessage('ERROR: Git pull failed: ' . implode(' ', $pullOutput));
    jsonResponse(500, 'Git pull failed', ['output' => $pullOutput]);
}

if ($beforeCommit !== $afterCommit) {
    logMessage("SUCCESS: Updated from $beforeCommit to $afterCommit");
    jsonResponse(200, 'Updated successfully', [
        'before' => $beforeCommit,
        'after' => $afterCommit,
        'output' => $pullOutput
    ]);
} else {
    logMessage('INFO: Already up to date at commit ' . $afterCommit);
    jsonResponse(200, 'Already up to date', [
        'commit' => $afterCommit
    ]);
}
