<div align="center">
  
# Security Advisory: SourceCodester Online Banking System v1.0

[![Packet Storm](https://img.shields.io/badge/Packet%20Storm-Advisory%20Published-blue?logo=security&logoColor=white)](https://packetstorm.news/files/id/213712)
![Severity](https://img.shields.io/badge/Severity-Critical-red)
![Status](https://img.shields.io/badge/Status-Unpatched%20(0--Day)-orange)

> **"Nice research! You drove a bus through this..."**
> — *Packet Storm Security Staff*

</div>

| **Advisory Property** | **Details** |
| :--- | :--- |
| **Vendor** | SourceCodester |
| **Product** | Online Banking Management System |
| **Version** | 1.0 |
| **Vulnerability Count** | 5 |
| **Status** | Unpatched (0-Day) |
| **Date** | January 2026 |

## 1. Executive Summary
Syntropy Security has identified five (3 Critical + 2 High) architectural vulnerabilities in the SourceCodester Online Banking System v1.0. These vulnerabilities demonstrate a complete breakdown of financial security controls. The flaws allow unauthenticated remote attackers to execute arbitrary code (RCE), bypass business logic to generate unlimited funds, and hijack administrative sessions.

Due to the severity of these findings (including Remote Code Execution and Financial Fraud), immediate remediation is recommended.

## 2. Vulnerability Index and Proof of Concept
The technical evidence for these findings is distributed across a comprehensive PDF report, specific exploit scripts, and video demonstrations.

| Vulnerability Type | Severity | CVE ID | Proof Artifacts & Documentation |
| :--- | :--- | :--- | :--- |
| **Remote Code Execution (RCE)**<br>*(Authenticated SQL Injection)* | **Critical** | *Pending* | • [**PDF Report (Section C)**](Syntropy_Security_Banking_Report.pdf)<br>• [**Exploit Summary**](Full_Chain_Exploit_Summary.txt)<br>• [**Video Demonstration**](https://youtu.be/Rk1HRvvMxLI) |
| **Financial Logic Error**<br>*(Integer Overflow / Negative Transfer)* | **Critical** | *Pending* | • [**PDF Report (Section A)**](Syntropy_Security_Banking_Report.pdf)<br>• [**Video Demonstration**](https://youtu.be/e6i0nSJLwXE) |
| **Concurrency Failure (Race Condition)**<br>*(Double Spending Attack)* | **Critical** | *Pending* | • [**PDF Report (Section B)**](Syntropy_Security_Banking_Report.pdf)<br>• [**Python Exploit (Race_Condition_Exploit.py)**](Race_Condition_Exploit.py)<br>• [**Video Demonstration**](https://youtu.be/Hc6NieYza48) |
| **Broken Access Control (IDOR)**<br>*(Unauthorized Dashboard Access)* | **High** | *Pending* | • [**PDF Report (Section D)**](Syntropy_Security_Banking_Report.pdf)<br>• [**Video Demonstration**](https://youtu.be/EXjJOA8HusY) |
| **Stored Cross-Site Scripting (XSS)**<br>*(Session Hijacking in Logs)* | **High** | *Pending* | • [**PDF Report (Section E)**](Syntropy_Security_Banking_Report.pdf)<br>• [**Video Demonstration**](https://youtu.be/wEMU8p6ky8A) |

## 3. Technical Analysis
### 3.1 Remote Code Execution (CWE-89)
The application allows authenticated users to inject arbitrary SQL commands via the `transfer.php` endpoint. Specifically, the `otherNo` parameter allows for `INTO OUTFILE` injection, enabling an attacker to write a PHP web shell to the server document root and achieve full system compromise.

### 3.2 Financial Integrity Failures (CWE-190 & CWE-362)
* **Integer Overflow:** The transfer logic fails to validate negative inputs. Authenticated users can transfer negative amounts (e.g., -500), effectively stealing funds from other accounts.
* **Race Condition:** The transaction processing logic lacks atomic database locks (e.g., `FOR UPDATE`), allowing attackers to send simultaneous requests to spend the same balance multiple times (Double Spending).

### 3.3 Access Control Failures (CWE-639 & CWE-79)
Administrative dashboards (`mindex.php`) are accessible to unprivileged users via Forced Browsing (IDOR). Additionally, the audit logs (`feedback.php`) are vulnerable to Stored XSS, allowing attackers to hijack administrator sessions by injecting malicious JavaScript into feedback forms.

## 4. Attack Surface Map
Visualizing the exploitation paths discovered during the audit:

```
[ EXTERNAL ATTACKER ]
        │
        ├── (A) Unauthenticated SQL Injection ──> [ DATABASE DUMP ]
        │       (Target: get_doctor.php)
        │
        ├── (B) Authentication Bypass ──────────> [ ADMIN DASHBOARD ]
        │       (Target: /admin/ path)                   │
        │                                                ▼
        ├── (C) IDOR / Broken Access Control ───> [ PATIENT RECORDS (PHI) ]
        │       (Target: view-medhistory.php)
        │
        └── (D) Stored XSS / CSRF ──────────────> [ ACCOUNT TAKEOVER ]
                (Target: User Profile / Add Doctor)
```
## 5. Remediation Recommendations
This software is fundamentally insecure and should **not** be used in any production environment. Administrators are advised to:
1.  **Network Isolation:** Restrict access to the banking panel to trusted IP addresses only.
2.  **Web Application Firewall (WAF):** Deploy rules to block SQL injection patterns and negative integer inputs.
3.  **Code Revision:**
    * Wrap all balance updates in `START TRANSACTION` ... `COMMIT` blocks.
    * Reject all negative numbers at the API level.
    * Rewrite all queries using `mysqli_prepare()`.

## 6. Remediation & Patch Analysis
The vendor has not released a patch. Below is the required code-level remediation for developers.

### 🛡️ Vulnerable vs. Secure Code Diff

**SQL Injection Fix (Use PDO):**

```
// VULNERABLE:
$sql = "SELECT * FROM doctors WHERE specilization = '".$_POST['specilizationid']."'";

// SECURE:
$stmt = $pdo->prepare("SELECT * FROM doctors WHERE specilization = :specid");
$stmt->execute(['specid' => $_POST['specilizationid']]);
```
**Access Control Fix (Session Validation):**

```
// VULNERABLE:
// No check at top of admin files.

// SECURE (Add to top of every /admin/ file):
session_start();
if ($_SESSION['role'] !== 'admin') {
    header("Location: /login.php");
    exit();
}
```
## 7. Credits
**Research & Discovery:** Sankalp Devidas Hanwate
**Organization:** Syntropy Security
---
###  Citation & Reference
**Permanent Link:** [Packet Storm Security Advisory](https://packetstorm.news/files/id/213712)

**Researcher:** Sankalp Devidas Hanwate (Syntropy Security)

**License:** Educational Use / Responsible Disclosure

*To leverage this research for penetration testing or security training, please link back to this repository.*
