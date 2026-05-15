# Fix: Intune CSR rejection caused by empty extensionRequest attribute
# kanidm-hsm-crypto 0.3.6 uses x509-cert 0.2's RequestBuilder which adds
# an empty extensionRequest to the CSR. Microsoft's API rejects this.
# We strip the empty attribute by rebuilding the CertificationRequestInfo
# DER without it, re-signing, and manually assembling the CertificateRequest.
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
