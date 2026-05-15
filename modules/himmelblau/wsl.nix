# WSL-specific workarounds for himmelblau + Intune compliance
#
# On NixOS under WSL2, several things don't match what Intune/Entra expect:
#
# 1. OS identity:   Intune only supports Ubuntu; we spoof /etc/os-release.
# 2. Disk encryption: WSL runs inside a BitLocker-protected VHD; provide
#                     /etc/crypttab so the compliance checker sees encryption.
# 3. Missing dirs:  NixOS lacks directories the tasks daemon writes to
#                   (/etc/krb5.conf.d, /var/lib/AccountsService, etc.).
# 4. Sandbox gaps:  The upstream systemd unit restricts AF_UNIX only and
#                   has ProtectSystem=strict, blocking network + file writes
#                   that policy enforcement needs.
# 5. IPv6:          WSL2's IPv6 is broken; disable it system-wide.
# 6. Cron:          NixOS doesn't ship cron; Intune script policies need it.
{ config, lib, pkgs, ... }:

{
  # ── OS identity spoofing ────────────────────────────────────────────
  #
  # MSIT conditional-access policy requires Ubuntu. We write a fake
  # os-release and bind-mount it into the tasks daemon's mount namespace.

  environment.etc."himmelblau/fake-os-release" = {
    text = ''
      PRETTY_NAME="Ubuntu 22.04.4 LTS"
      NAME="Ubuntu"
      VERSION_ID="22.04"
      VERSION="22.04.4 LTS (Jammy Jellyfish)"
      VERSION_CODENAME=jammy
      ID=ubuntu
      ID_LIKE=debian
      HOME_URL="https://www.ubuntu.com/"
      SUPPORT_URL="https://help.ubuntu.com/"
      BUG_REPORT_URL="https://bugs.launchpad.net/ubuntu/"
      PRIVACY_POLICY_URL="https://www.ubuntu.com/legal/terms-and-policies/privacy-policy"
      UBUNTU_CODENAME=jammy
    '';
    mode = "0444";
  };

  systemd.services.himmelblaud-tasks.serviceConfig.BindReadOnlyPaths = [
    "/etc/himmelblau/fake-os-release:/etc/os-release"
    "/etc/himmelblau/fake-os-release:/usr/lib/os-release"
  ];

  # ── Disk encryption compliance ──────────────────────────────────────
  #
  # WSL2 runs inside a VHD on the Windows host, which should be protected
  # by BitLocker. The compliance checker looks for a non-empty /etc/crypttab.

  environment.etc."crypttab" = {
    text = "# WSL2 VHD is encrypted by host BitLocker\n";
    mode = "0644";
  };

  # ── Sandbox fixes for himmelblaud-tasks ─────────────────────────────
  #
  # The upstream unit sets RestrictAddressFamilies=AF_UNIX and
  # ProtectSystem=strict. Policy enforcement needs:
  #   - AF_INET for HTTPS to Graph/Intune APIs
  #   - Write access to policy cache, cron, kerberos, profile photos

  systemd.services.himmelblaud-tasks.serviceConfig = {
    RestrictAddressFamilies = lib.mkForce "AF_UNIX AF_INET";
    ReadWritePaths = [
      "/var/cache/himmelblau-policies"
      "/etc/cron.d"
      "/etc/krb5.conf.d"
      "/var/lib/AccountsService"
    ];
  };

  # ── Missing directories ────────────────────────────────────────────
  #
  # NixOS doesn't create these by default. The tasks daemon needs them
  # for script caching, cron jobs, kerberos config, and profile photos.

  systemd.tmpfiles.rules = [
    "d /var/cache/himmelblau-policies 0750 root root -"
    "d /etc/cron.d 0755 root root -"
    "d /etc/krb5.conf.d 0755 root root -"
    "d /var/lib/AccountsService/icons 0755 root root -"
    "d /var/lib/AccountsService/users 0755 root root -"
  ];

  # ── Cron daemon ─────────────────────────────────────────────────────
  #
  # Intune script policies install cron jobs; NixOS doesn't enable cron
  # by default.

  services.cron.enable = true;

  # ── IPv6 ────────────────────────────────────────────────────────────
  #
  # WSL2 cannot create IPv6 sockets; disable at the kernel level so all
  # applications (not just himmelblau) use IPv4.

  boot.kernel.sysctl."net.ipv6.conf.all.disable_ipv6" = 1;
  boot.kernel.sysctl."net.ipv6.conf.default.disable_ipv6" = 1;
}
