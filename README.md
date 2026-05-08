# RobinTrader GOLD 🚀💎
### Professional AI-Trading Fleet for Automated Markets

**RobinTrader GOLD** is a modular, multi-agent trading ecosystem designed for high-performance automation. The fleet consists of 6 specialized bots that work in synergy to analyze, validate, and execute trades autonomously. 

Built for the **AI4Trade** platform, this repository offers a professional "Plug-and-Play" infrastructure with self-initializing identity management and robust error-handling.

---

## 🛰️ The Fleet Architecture

The ecosystem is divided into specialized units to ensure stability and intelligence:

1.  **Bot 1: The Executor** 🛡️
    Manages open positions, implements dynamic trailing stops (0.5% buffer), and executes buy orders based on internal intelligence consensus.
2.  **Bot 2: The Analyst** 📊
    Scans market leaders and top-performing agents to identify high-probability assets, filtering them through the Guardian's blacklist.
3.  **Bot 3: Global Intelligence** 📡
    Parses global news and real-time feeds to extract market trends with a confidence-based scoring system.
4.  **Bot 4: The Guardian** ⚖️
    The security core. Monitors trader performance and automatically blacklists assets or agents with negative performance thresholds.
5.  **Bot 5: Heartbeat Monitor** ❤️
    Ensures 24/7 connectivity, handles session token refreshes, and manages platform notifications/tasks.
6.  **Bot 6: The Strategist** 🧠
    A regex-powered parser that analyzes raw strategy reports to identify expert consensus on specific assets.

---

## 🚀 Getting Started

The fleet is designed to be portable and requires zero manual configuration for paths.

### 1. Prerequisites
- Windows PowerShell 5.1+
- An active AI4Trade account.

### 2. Installation & Launch
1.  Clone this repository into your local machine.
2.  Open a PowerShell terminal in the project folder.
3.  Run the master startup script:
    ```powershell
    .\start_fleet.ps1
    ```

### 3. Automatic Initialization
On the first run, the system will:
- Generate a unique **Trader Identity** (e.g., `Trader_XXXXXXXXXX`).
- Create secure local session files (`.token`, `.credentials`).
- Synchronize with the AI4Trade API.

---

## ⚙️ Configuration
The central logic is managed in `config.ps1`. You can adjust global parameters such as:
- `BUY_AMOUNT`: Default trade size (default: $5,000).
- `RESERVE`: Minimum cash reserve.
- `TARGET_MAX/MIN`: Profit-taking thresholds.

---

## 📜 Disclaimer
*Trading involves significant risk. This software is provided for educational and automation purposes. The authors are not responsible for financial losses incurred through the use of this bot fleet. Always trade responsibly.*

---

**Developed with ❤️ by the RobinTrader Community.**
