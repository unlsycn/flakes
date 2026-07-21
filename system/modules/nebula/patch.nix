{
  modulesPath,
  ...
}:
let
  upstreamModule = modulesPath + "/services/networking/nebula.nix";
  upstreamSource = builtins.readFile upstreamModule;

  globalFirewallDefinition =
    "    # Open the chosen ports for UDP.\n"
    + "    networking.firewall.allowedUDPPorts = lib.unique (\n"
    + "      lib.filter (port: port > 0) (\n"
    + "        lib.mapAttrsToList (netName: netCfg: resolveFinalPort netCfg) enabledNetworks\n"
    + "      )\n"
    + "    );\n\n";

  patchedSource =
    builtins.replaceStrings
      [ globalFirewallDefinition ]
      [
        ''
          # Firewall exposure is projected by the local mesh surface model instead.

        ''
      ]
      upstreamSource;

  patchedModule =
    if patchedSource == upstreamSource then
      throw "The upstream NixOS Nebula firewall definition changed; update system/modules/nebula/patch.nix"
    else
      builtins.toFile "nixos-nebula-without-global-firewall.nix" patchedSource;
in
{
  # The upstream module unconditionally writes a global allowedUDPPorts entry:
  # https://github.com/NixOS/nixpkgs/blob/753cc8a3a87467296ddd1fa93f0cc3e81120ee46/nixos/modules/services/networking/nebula.nix#L356-L361
  disabledModules = [ upstreamModule ];
  imports = [ patchedModule ];
}
