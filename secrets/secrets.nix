let
  # User keys (can encrypt/rekey secrets)
  vbargl = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMFNlZYlDjje/aX9WSd0WyCvEQaqHvbX/5/IWvXkntdu bargl.vojtech.net";

  # Host keys (can decrypt secrets at runtime)
  flux-capacitor = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEa+f6pnQ4OmIdzK4q+l771PbYD5XqsxT9JN8p4uSx1A root@ant";
in
{
  "wifi-vodafone-psk.age".publicKeys = [ vbargl flux-capacitor ];
  "k3s-token.age".publicKeys = [ vbargl flux-capacitor ];
}
