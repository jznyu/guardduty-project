# Infrastructure setup

<img width="1301" alt="Screenshot 2025-04-07 at 10 38 46 AM" src="https://github.com/user-attachments/assets/0ea2ff98-481d-43fc-a7f2-36c589f33a88" />

- 1 RedTeam EC2 instance to simulate SSH brute-force attacks
- 1 Linux target EC2 instance to be attacked
- A Bastion host for remote access
- Simple networking (1 public + 1 private subnet)
- Outputs the Linux target's security group ID for your Lambda function to use in remediation

# Remediation Setup

<img width="879" alt="Screenshot 2025-04-07 at 11 39 05 AM" src="https://github.com/user-attachments/assets/c151ff1b-4a3d-47db-884c-eef02109bac2" />

- Accepts the Security Group ID of Linux EC2 to remediate
- Accepts the Email Addresses to notify
- Deploys the **Lambda Function** that blocks IPs attempting SSH brute-force attacks
- Setups **EventBridge rule** that triggers Lambda Function based on GuardDuty findings (severity > 5)
