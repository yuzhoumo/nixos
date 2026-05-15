# Fix: Intune CSR rejection caused by two issues:
# 1. kanidm-hsm-crypto 0.3.6 uses x509-cert 0.2's RequestBuilder which adds
#    an empty extensionRequest to the CSR. We strip it in csr-fix.patch.
# 2. libhimmelblau sends the CSR as raw base64, but Intune requires PEM-wrapped
#    PKCS#10. We add PEM headers in intune-pem-fix.patch.
{ config, lib, pkgs, himmelblau, ... }:

let
  system = pkgs.stdenv.hostPlatform.system;

  patchedPkgs = pkgs.extend (final: prev: {
    defaultCrateOverrides = prev.defaultCrateOverrides // {
      "kanidm-hsm-crypto" = attrs: {
        postPatch = ''
          patch -p1 < ${./csr-fix.patch}
        '';
      };
      "libhimmelblau" = attrs: {
        postPatch = ''
          patch -p1 < ${./intune-pem-fix.patch}
        '';
      };
    };
  });

  patchedHimmelblau = import "${himmelblau}" {
    inherit system;
    pkgs = patchedPkgs;
  };
in
{
  services.himmelblau = {
    daemonPackage = lib.mkForce patchedHimmelblau.packages.daemon;
    pamPackage = lib.mkForce patchedHimmelblau.packages.pam;
    nssPackage = lib.mkForce patchedHimmelblau.packages.nss;
    ssoPackage = lib.mkForce patchedHimmelblau.packages.sso;
    brokerPackage = lib.mkForce patchedHimmelblau.packages.broker;
  };

  environment.systemPackages = [
    patchedHimmelblau.packages.aad-tool
  ];
}
