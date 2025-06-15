
# GN Manager Suite - Tools Directory

Welcome to the command center of the GN Manager Suite. This directory contains the complete arsenal of specialized, high-performance command-line tools engineered by **GeekNeuron**. Each script is a master of its domain, designed to be powerful independently, yet work in harmony as part of a cohesive ecosystem.

## First Steps & General Usage

1.  **Unified Location:** For the suite to function correctly, all `.bat` files must be kept in the same folder.
2.  **Main Entry Point:** The recommended way to start is by running `GN_Manager_Suite.bat`, which provides a central menu to access all other tools.
3.  **Administrator Rights:** All tools require administrative privileges to perform their tasks. They will automatically request elevation if not run as an administrator.
4.  **Automatic Setup:** On the first run of any tool, a configuration file (`GN_Manager_Config.ini`) and a log file (`GN_Manager_Log.txt`) will be created automatically in the same directory.

---

## The GN Manager Arsenal (Tool Definitions)

Here is a complete, in-depth guide to each of the 15 tools in the suite.

###  launcher.png **GN Manager Suite**
This is the main gateway and central command hub for the entire toolkit. It provides a clean, categorized menu that allows you to seamlessly launch any specialized tool and returns you to the main menu upon completion, creating a unified and fluid user experience.

---
### 1. Software Installation & Management

#### ⚙️ **GN Winget Manager**
Your modern command-line portal to the Windows Package Manager repository.
* **Capabilities:**
    * **Search:** Instantly find any application within the vast Winget repository.
    * **Install:** Install software directly from the source using its official Package ID.
    * **Upgrade:** Scan all installed applications and upgrade them to their latest versions, either all at once or individually.

#### 📦 **GN Local Install Manager**
A hyper-efficient utility for rapid, offline, bulk software installation.
* **Capabilities:**
    * **Drag & Drop Interface:** Simply drag a folder containing your installers onto the script's icon.
    * **Silent Sequential Installation:** The script automatically detects all `.exe` and `.msi` files and attempts to install them silently and in sequence, preventing conflicts.

---
### 2. System Cleanup & Optimization

#### 🧹 **GN Cleaner Manager**
A surgical tool for deep system hygiene and complete software removal.
* **Capabilities:**
    * **Intelligent Uninstall:** Automatically lists all installed programs for easy removal, with an optional "silent mode" attempt.
    * **Safe File Cleanup:** Finds leftover files and folders from uninstalled programs and moves them to a secure **Quarantine** directory instead of deleting them permanently.
    * **Registry Hygiene:** Scans for and allows the removal of orphaned registry keys, with a per-key confirmation to ensure maximum safety.
    * **CSV Export:** Exports a full list of all installed applications to a `.csv` file for inventory and analysis.

#### 💽 **GN Disk Analyzer**
A high-performance disk space cartographer inspired by TreeSize.
* **Capabilities:**
    * **Deep Scan:** Analyzes either a specific folder or an entire drive (`C:`, `D:`, etc.).
    * **Dual-Format Reporting:** Generates a comprehensive report in either a human-readable `.txt` format or a data-rich `.csv` format for analysis in spreadsheet software.
    * **Insightful Reports:** The report identifies the largest files and provides a breakdown of folder sizes to show exactly where your disk space is being used.

#### 🚀 **GN System Optimizer**
The "emergency boost" for your system, designed to optimize resource usage in real-time.
* **Capabilities:**
    * **RAM Optimization:** Attempts to free up cached memory held by idle processes, potentially improving system responsiveness in low-memory situations.
    * **Process Management:** Lists the top processes currently consuming the most CPU power and allows you to safely terminate them after confirmation.
    * **Startup Manager:** Lists all applications that run at startup and provides quick shortcuts to the official Windows tools (Task Manager, Startup Folder) to manage them.

---
### 3. System Repair & Security

#### 🔧 **GN Repair Toolkit**
The system's "mechanic," designed to fix common and complex Windows issues with a single click.
* **Capabilities:**
    * **Network Stack Reset:** A full suite of tools to fix connectivity issues, including DNS flushing, TCP/IP stack reset, and Winsock catalog reset.
    * **System Integrity Repair:** Provides easy access to run `sfc /scannow` and `DISM /Online /Cleanup-Image /RestoreHealth` to repair corrupted Windows system files.
    * **Windows Update Fix:** Clears the Windows Update cache to resolve issues with stuck or failed updates.

#### 🛡️ **GN Security Auditor**
A read-only "security consultant" that audits your system for common vulnerabilities without making any changes.
* **Capabilities:**
    * **Open Port Analysis:** Lists all open network ports and the executable responsible for each one.
    * **Admin Account Review:** Shows all users in the local Administrators group.
    * **Vulnerability Scan:** Finds services with unquoted paths, a classic privilege escalation risk.
    * **Hosts File Scan:** Checks the system's `hosts` file for suspicious entries that could indicate malware or redirection.

#### ⚙️ **GN Tweak Manager**
**For Advanced Users Only.** An expert-level control panel for fine-tuning sensitive Windows settings.
* **Capabilities:**
    * **Status-Aware Toggles:** Before any action, the script reports the current status of the setting (e.g., "Defender is currently ON").
    * **Security Toggles:** Enable or disable core components like Windows Defender, Windows Update, and the Windows Firewall, with multiple warnings and confirmations.
    * **UI Tweaks:** Easily toggle settings like showing hidden files and file extensions.

---
### 4. Data & Driver Management

#### 💾 **GN Backup Manager**
The ultimate data-fortification and system-migration utility.
* **Capabilities:**
    * **Profile-Based Backups:** Define profiles for complex applications (e.g., IDEs, design software) in the `config.ini` file.
    * **Compressed Archives:** Option to back up data as a space-saving, portable `.7z` archive (requires 7-Zip).
    * **Data & Registry:** Backs up both large data folders and specific registry keys.
    * **Intelligent Restore:** Can restore data from both standard folder backups and compressed archives.

#### 🔌 **GN Driver Manager**
A complete lifecycle management tool for your system's drivers.
* **Capabilities:**
    * **Hardware Diagnostics:** Identifies devices with missing or faulty drivers.
    * **Smart Driver Search:** Generates a precise Google search link using the device's unique Hardware ID to help you find the correct driver online.
    * **Full Driver Backup (Export):** Saves all your current third-party drivers to a single folder, essential before a clean Windows install.
    * **Bulk Driver Restore (Import):** Automatically installs all drivers from your backup folder onto a new system.

---
### 5. Analysis & Reporting

#### ℹ️ **GN System Info**
Your personal system diagnostician, providing a complete manifest of your hardware and software.
* **Capabilities:**
    * **Comprehensive Reports:** Gathers detailed information on your OS, CPU, RAM (per-module specs), GPU, storage drives, and network adapters.
    * **CSV Export:** Exports all gathered data into multiple, cleanly organized `.csv` files for inventory management or system comparison.

#### 🌐 **GN Network Manager**
A network detective's toolkit for troubleshooting any connectivity issue.
* **Capabilities:**
    * **Standard Diagnostics:** Includes `Ping` and `Traceroute` utilities.
    * **Advanced Lookups:** Performs deep DNS analysis (MX, NS, TXT records) and WHOIS lookups for domain information.
    * **Live Monitoring:** Lists all active network connections (`netstat`) and includes an integrated Internet Speed Test utility.
 
    * ---
### 6. Advanced Utilities & Automation

#### 🕒 **GN Restore Point Manager**
The "time machine" for your operating system, providing a simple and powerful command-line interface to manage Windows System Restore points.
* **Capabilities:**
    * **Create Restore Points:** Instantly create a new, named restore point with a custom description before making major system changes like driver or software installations.
    * **List All Points:** Display a clear, organized list of all available restore points along with their creation dates, descriptions, and unique sequence numbers.
    * **Delete Specific Points:** Safely delete old or unneeded restore points by their sequence number to free up valuable disk space, all after a final confirmation.

#### 📂 **GN File Commander**
An advanced operations commander for your files, built to perform complex bulk tasks that are tedious or impossible in Windows Explorer.
* **Capabilities:**
    * **Bulk Rename:** Mass rename hundreds of files based on user-defined search-and-replace patterns, featuring a crucial **-WhatIf** preview to show all proposed changes before committing.
    * **Duplicate File Finder:** Deep-scan a folder to find files with identical content (based on MD5 hash) regardless of their name, and report the groups of duplicates for manual cleanup.
    * **Auto-Organize:** Automatically sort a folder's entire contents (e.g., your Downloads folder) into neatly organized subdirectories based on file type (`.pdf`, `.jpg`, `.zip`) or creation date.

#### 🤖 **GN Automation Scheduler**
The "autopilot" for the entire suite, transforming your tools from reactive utilities into a proactive, self-maintaining system.
* **Capabilities:**
    * **Wizard-Based Task Creation:** A user-friendly, step-by-step wizard guides you through scheduling any other GN Manager script to run automatically.
    * **Flexible Scheduling:** Set tasks to run Daily or Weekly at a specific time, or to trigger automatically every time a user logs on.
    * **Task Management:** Easily list all custom tasks created by the suite and delete them by name.
    * **Run with Highest Privileges:** Automatically configures scheduled tasks to run with the necessary administrator rights for flawless, unattended execution.
