![Severity](https://img.shields.io/badge/Severity-Critical-red)
![Status](https://img.shields.io/badge/Status-Unpatched%20(0--Day)-orange)
![Vulnerabilities](https://img.shields.io/badge/Vulnerabilities-5-blue)

# SourceCodester-Banking-CVE
Syntropy Security's comprehensive security audit of the Online Banking Management System v1.0. Our assessment concludes that the application in its current state poses unacceptable risk to the organization. We identified five (5) critical security failures that would cause catastrophic financial loss and total operational paralysis if deployed.

# Security Advisory: Critical Financial Flaws in SourceCodester Online Banking System

| **Advisory Property** | **Details** |
| :--- | :--- |
| **Vendor** | SourceCodester |
| **Product** | Online Banking Management System |
| **Version** | 1.0 |
| **Vulnerability Count** | 5 |
| **Status** | Unpatched (0-Day) |
| **Date** | January 2026 |

## 1. Executive Summary
Syntropy Security has identified five (5) critical architectural vulnerabilities in the SourceCodester Online Banking Management System v1.0. These flaws demonstrate a complete breakdown of financial security controls, allowing for Remote Code Execution (RCE), unlimited currency generation, double-spending attacks, and administrative account takeover.

This repository serves as a technical case study on financial application security failures.

## 2. Vulnerability Index and Proof of Concept

| Vulnerability Type | Severity | CVE ID | Proof Artifacts & Documentation |
| :--- | :--- | :--- | :--- |
| **Remote Code Execution (RCE)**<br>*(Authenticated SQL Injection)* | **Critical** | *Pending* | • 📄 [**PDF Report (Section C)**](Syntropy_Security_Banking_Report.pdf)<br>• 📜 [**Exploit Summary**](Full_Chain_Exploit_Summary.txt)<br>• 📺 [**Watch Video PoC**](https://youtu.be/Rk1HRvvMxLI) |
| **Financial Logic Error**<br>*(Integer Overflow / Negative Transfer)* | **Critical** | *Pending* | • 📄 [**PDF Report (Section A)**](Syntropy_Security_Banking_Report.pdf)<br>• 📺 [**Watch Video PoC**](https://youtu.be/e6i0nSJLwXE) |
| **Concurrency Failure (Race Condition)**<br>*(Double Spending Attack)* | **Critical** | *Pending* | • 📄 [**PDF Report (Section B)**](Syntropy_Security_Banking_Report.pdf)<br>• 🐍 [**Python Script**](Race_Condition_Exploit.py)<br>• 📺 [**Watch Video PoC**](https://youtu.be/Hc6NieYza48) |
| **Broken Access Control (IDOR)**<br>*(Unauthorized Dashboard Access)* | **High** | *Pending* | • 📄 [**PDF Report (Section D)**](Syntropy_Security_Banking_Report.pdf)<br>• 📺 [**Watch Video PoC**](https://youtu.be/EXjJOA8HusY) |
| **Stored Cross-Site Scripting (XSS)**<br>*(Session Hijacking in Logs)* | **High** | *Pending* | • 📄 [**PDF Report (Section E)**](Syntropy_Security_Banking_Report.pdf)<br>• 📺 [**Watch Video PoC**](https://youtu.be/wEMU8p6ky8A) |

## 3. Reproduction Environment
To assist researchers in verifying these findings, we have provided an automated bash script to deploy the vulnerable environment locally.
* **Lab Setup Script:** [`Lab_setup_script.sh`](Lab_setup_script.sh)
* **Setup Tutorial:** 📺 [**Watch Lab Setup Video**](https://youtu.be/5bIYRRtWE_0)

## 4. Technical Analysis
### 4.1 Remote Code Execution (CWE-89)
The application allows authenticated users to inject arbitrary SQL commands via the `transfer.php` endpoint (`otherNo` parameter). This can be escalated to RCE by writing a PHP web shell to the server using `SELECT ... INTO OUTFILE`.

### 4.2 Financial Integrity Failures (CWE-190 & CWE-362)
* **Integer Overflow:** The transfer logic fails to validate negative inputs, allowing users to "transfer" negative amounts (effectively stealing funds).
* **Race Condition:** The transaction processing logic lacks atomic locks (e.g., `FOR UPDATE`), allowing parallel requests to spend the same balance multiple times.

### 4.3 Access Control Failures (CWE-639 & CWE-79)
Administrative dashboards (`mindex.php`) are accessible to unprivileged users via IDOR, and audit logs are vulnerable to Stored XSS (`feedback.php`), allowing attackers to hijack administrator sessions.

## 5. Remediation Recommendations
This software is fundamentally insecure and should **not** be used in any production environment. For educational remediation:
1.  **Use Transactions:** Wrap all balance updates in `START TRANSACTION` ... `COMMIT` blocks.
2.  **Input Validation:** Reject all negative numbers at the API level.
3.  **Prepared Statements:** Rewrite all queries using `mysqli_prepare()`.

## 6. Credits
**Research & Discovery:** Sankalp Devidas Hanwate
**Organization:** Syntropy Security
