# Automated Gobuster Subdomain & Directory Pipeline

A modular and interactive Bash automation script designed for Kali Linux. It chains subdomain enumeration directly into web directory fuzzing while automatically stripping hidden terminal ANSI formatting and parsing errors.

## Features
- **Dynamic User Inputs:** Prompts interactively for targets, custom file outputs, and wordlist paths.
- **Intelligent Fallbacks:** Defaults to industry-standard SecLists paths if no custom wordlist is supplied.
- **Data Normalisation:** Cleanly handles and strips hidden text artifacts, IP data columns, and raw ANSI character formatting strings.
- **SSL Flexibility:** Bypasses TLS connection drops (`-k`) on targets with expired or internal enterprise certificates.

## Prerequisites & Installation

Ensure your repository lists are updated and that you have `gobuster` along with `seclists` installed on your machine:

```bash
sudo apt update
sudo apt install gobuster seclists -y
```

## How to Deploy

1. Ensure the script (`auto_recon.sh`) has execution permissions:
   ```bash
   chmod +x auto_recon.sh
   ```

2. Run the automation pipeline:
   ```bash
   ./auto_recon.sh
   ```

3. Follow the on-screen prompts to input your target domain, custom file names, or custom wordlist paths.
