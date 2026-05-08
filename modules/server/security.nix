{ ... }:

{
  boot.kernel.sysctl = {
    # prevent SYN flood attacks
    "net.ipv4.tcp_syncookies" = 1;

    # ignore ICMP redirects
    "net.ipv4.conf.all.accept_redirects" = 0;
    "net.ipv6.conf.all.accept_redirects" = 0;
    "net.ipv4.conf.default.accept_redirects" = 0;
    "net.ipv6.conf.default.accept_redirects" = 0;

    # don't send ICMP redirects
    "net.ipv4.conf.all.send_redirects" = 0;
    "net.ipv4.conf.default.send_redirects" = 0;

    # ignore source-routed packets
    "net.ipv4.conf.all.accept_source_route" = 0;
    "net.ipv6.conf.all.accept_source_route" = 0;

    # log martian packets
    "net.ipv4.conf.all.log_martians" = 1;
    "net.ipv4.conf.default.log_martians" = 1;

    # restrict dmesg access
    "kernel.dmesg_restrict" = 1;
  };

  system.autoUpgrade = {
    enable = true;
    allowReboot = false;
  };

  security.sudo.execWheelOnly = true;
}
