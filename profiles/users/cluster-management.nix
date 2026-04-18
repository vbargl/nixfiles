{ pkgs, ... }: {
  users.users.vbargl.packages = with pkgs; [
    k9s
    kubectl
    age
    deploy-rs
  ];
}
