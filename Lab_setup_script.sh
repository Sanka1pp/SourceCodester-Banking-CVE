#!/bin/bash

# ==============================================================================
# SYNTROPY SECURITY - CERT-IN LAB AUTOMATOR (v5.0)
# Target: SourceCodester Online Banking System v1.0
# Context: Vulnerability Reproduction Environment
# ==============================================================================

# --- CONFIGURATION ---
SOURCE_DIR="/home/kali/Documents/CVE/SecureCodester_Banking_MS"
WEB_ROOT="/var/www/html/SecureCodester_Banking_MS"
DB_USER="bank_user"
DB_PASS="password123"
DB_NAME="banking_db"

# --- COLORS ---
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}[*] SYNTROPY LABS: INITIALIZING CERT-IN ENVIRONMENT...${NC}"

# 1. PRE-FLIGHT CHECK
if [ ! -d "$SOURCE_DIR" ]; then
    echo -e "${RED}[-] ERROR: Source code not found at $SOURCE_DIR${NC}"
    echo "    Please verify the path in the script configuration."
    exit 1
fi

# 2. CLEANUP & DEPLOY
echo -e "${GREEN}[*] Step 1/4: Resetting Web Services...${NC}"
sudo service apache2 stop
sudo service mysql start
sudo rm -rf $WEB_ROOT
sudo cp -r "$SOURCE_DIR" /var/www/html/

# [CRITICAL FIX] Set permissions to 777 so SQLMap can write the RCE shell
echo "    > Setting directory permissions to 777 (Required for INTO OUTFILE)..."
sudo chown -R mysql:mysql $WEB_ROOT
sudo chmod -R 777 $WEB_ROOT

# 3. DATABASE SETUP
echo -e "${GREEN}[*] Step 2/4: Rebuilding Database...${NC}"
SQL_FILE=$(find $WEB_ROOT -type f -name "*.sql" | head -n 1)

if [ -z "$SQL_FILE" ]; then
    echo -e "${RED}[-] ERROR: No SQL file found in source!${NC}"
    exit 1
fi

# We execute SQL commands to Drop, Create, Grant Permissions, and Import Data
sudo mysql -u root <<EOF
DROP DATABASE IF EXISTS $DB_NAME;
CREATE DATABASE $DB_NAME;
DROP USER IF EXISTS '$DB_USER'@'localhost';
CREATE USER '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASS';
GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'localhost';
GRANT FILE ON *.* TO '$DB_USER'@'localhost';
FLUSH PRIVILEGES;

USE $DB_NAME;
\. $SQL_FILE

-- [CRITICAL FIX] Rename Imported Tables to CamelCase (Linux Case Sensitivity Fix)
RENAME TABLE useraccounts TO userAccounts;
RENAME TABLE feedback TO Feedback;
RENAME TABLE notice TO Notice;
RENAME TABLE login TO Login;

-- [CRITICAL FIX] Create Mirrors so the code works either way
CREATE VIEW useraccounts AS SELECT * FROM userAccounts;
CREATE VIEW feedback AS SELECT * FROM Feedback;
CREATE VIEW notice AS SELECT * FROM Notice;
CREATE VIEW login AS SELECT * FROM Login;
EOF

# 4. CODE PATCHING
echo -e "${GREEN}[*] Step 3/4: Patching PHP Files...${NC}"
# Fix DB Credentials globally
find $WEB_ROOT -name "*.php" -exec sed -i "s/new mysqli(.*)/new mysqli('localhost','$DB_USER','$DB_PASS','$DB_NAME')/Ig" {} +
# Fix PHP 8 'define' error globally
find $WEB_ROOT -name "*.php" -exec sed -i "s/, *true *)/)/Ig" {} +
# Enable Errors for debugging
sed -i '2i error_reporting(E_ALL); ini_set("display_errors", 1);' $WEB_ROOT/bank/index.php

# 5. LAUNCH
echo -e "${GREEN}[*] Step 4/4: Starting Server...${NC}"
sudo service apache2 start

echo -e "${BLUE}[SUCCESS] SETUP COMPLETE.${NC}"
echo "---------------------------------------------------------------------------------"
echo "URL:     http://localhost/SecureCodester_Banking_MS/bank/"
echo "DB User: $DB_USER / $DB_PASS"
echo "---------------------------------------------------------------------------------"
echo -e "${GREEN}ACTION REQUIRED:${NC} Login as 'manager@manager.com' (Pass: manager)"
echo "Then register these 3 users manually to match the PoC videos:"
echo ""
echo "+------------+---------------------+------------------------+----------+---------+"
echo "| Role       | Character Name      | Login Email            | Password | Balance |"
echo "+------------+---------------------+------------------------+----------+---------+"
echo "| ATTACKER   | Bertram Gilfoyle    | gilfoyle@piedpiper.com | password | 100,000 |"
echo "| VICTIM A   | Richard Hendricks   | richard@piedpiper.com  | password | 100,000 |"
echo "| VICTIM B   | Erlich Bachman      | erlich@aviato.com      | password | 100,000 |"
echo "+------------+---------------------+------------------------+----------+---------+"
echo ""
