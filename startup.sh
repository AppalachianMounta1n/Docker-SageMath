# Add runtime security hardening for sysctl, ufw, and iptables (error-tolerant)
echo 'echo "Applying sysctl security settings..."' >> /home/sageuser/startup.sh
echo 'sysctl -p /etc/sysctl.conf 2>/dev/null || echo "sysctl not applied (not privileged or not supported)"' >> /home/sageuser/startup.sh
echo 'echo "Applying UFW firewall rules..."' >> /home/sageuser/startup.sh
echo 'ufw --force enable 2>/dev/null || echo "ufw not applied (not privileged or not supported)"' >> /home/sageuser/startup.sh
echo 'ufw default deny incoming 2>/dev/null || true' >> /home/sageuser/startup.sh
echo 'ufw default allow outgoing 2>/dev/null || true' >> /home/sageuser/startup.sh
echo 'ufw allow 8888/tcp 2>/dev/null || true' >> /home/sageuser/startup.sh
echo 'ufw allow 22/tcp 2>/dev/null || true' >> /home/sageuser/startup.sh
echo 'ufw --force reload 2>/dev/null || true' >> /home/sageuser/startup.sh
echo 'echo "Applying iptables rules..."' >> /home/sageuser/startup.sh
echo 'iptables -A INPUT -i lo -j ACCEPT 2>/dev/null || true' >> /home/sageuser/startup.sh
echo 'iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT 2>/dev/null || true' >> /home/sageuser/startup.sh
echo 'iptables -A INPUT -p tcp --dport 8888 -j ACCEPT 2>/dev/null || true' >> /home/sageuser/startup.sh
echo 'iptables -A INPUT -p tcp --dport 22 -j ACCEPT 2>/dev/null || true' >> /home/sageuser/startup.sh
echo 'iptables -A INPUT -j DROP 2>/dev/null || true' >> /home/sageuser/startup.sh
echo 'iptables -A FORWARD -j DROP 2>/dev/null || true' >> /home/sageuser/startup.sh
echo 'iptables-save > /etc/iptables/iptables.rules 2>/dev/null || true' >> /home/sageuser/startup.sh 