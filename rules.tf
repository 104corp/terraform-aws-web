variable "rules" {
  description = "Map of known security group rules (define as 'name' = ['from port', 'to port', 'protocol', 'description'])"
  default = {
    # SSH
    ssh-tcp       = [22, 22, "tcp", "SSH"]
    
    # HTTP
    http-80-tcp   = [80, 80, "tcp", "HTTP"]

    # HTTPS
    https-443-tcp = [443, 443, "tcp", "HTTPS"]

    # Open all ports & protocols
    all-all       = [-1, -1, "-1", "All protocols"]
    all-tcp       = [0, 65535, "tcp", "All TCP ports"]
    all-udp       = [0, 65535, "udp", "All UDP ports"]
    all-icmp      = [-1, -1, "icmp", "All IPV4 ICMP"]
    all-ipv6-icmp = [-1, -1, 58, "All IPV6 ICMP"]
  }
}