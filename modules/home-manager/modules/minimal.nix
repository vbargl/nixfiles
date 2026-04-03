{ lib, pkgs, config, ... }: 
let
  hasGuiCapability = builtins.elem "gui" config.environment.capabilities;
  
  pkgsSet = with pkgs; {
    cli = [
      moreutils
      nmap
      curl
      fzf
      rclone
      dasel
      bat
      btop
      gtrash
      zip
      unzip
      fd
      bc
      less
      nh
    ];

    gui = [
      ghostty
  		walker      # launcher
  		firefox     # browser
  		thunderbird # email
  		peazip      # archive manager
    ];
  };
in
{
  programs = {
    fish.enable = true;
    carapace = {
      enable = true;
      enableNushellIntegration = true;
      enableFishIntegration = true;
    };
    carapace-specs.enable = true;
    helix = {
      enable = true;
      defaultEditor = true;
    };

    nushell = {
      enable = true;
      extraEnv = ''
        # Rose Pine Moon prompt
        $env.PROMPT_COMMAND = {||
            let red = (ansi {fg: '#eb6f92'})
            let gold = (ansi {fg: '#f6c177'})
            let pine = (ansi {fg: '#31748f'})
            let iris = (ansi {fg: '#c4a7e7'})
            let overlay = (ansi {fg: '#6e6a86'})
            let reset = (ansi reset)

            let user = (whoami | str trim)
            let host = (hostname | str trim | split row '.' | first)
            let dir = if ($env.PWD | str starts-with $env.HOME) {
                $env.PWD | str replace $env.HOME '~'
            } else {
                $env.PWD
            }

            # VCS branch (jj or git)
            let jj_info = (do -i { ^jj log -r @ --no-graph -T 'separate(" ", bookmarks.join(", "), change_id.shortest(8))' } | complete)
            let branch_text = if $jj_info.exit_code == 0 {
                let info = ($jj_info.stdout | str trim)
                if ($info | is-empty) { "" } else { $"jj:($info)" }
            } else {
                let git_branch = (do -i { ^git symbolic-ref --short HEAD } | complete)
                if $git_branch.exit_code == 0 {
                    ($git_branch.stdout | str trim)
                } else {
                    ""
                }
            }

            let datetime = (date now | format date "%Y-%m-%d %H:%M")

            # Visible text lengths for padding
            let left_text = $"($user)@($host) ($dir)"
            let right_text = if ($branch_text | is-empty) {
                $datetime
            } else {
                $"($branch_text) ($datetime)"
            }

            let width = (term size).columns
            let padding = ([1, ($width - ($left_text | str length) - ($right_text | str length))] | math max)
            let spaces = (''' | fill -c ' ' -w $padding)

            # Colored output
            let left = $"($red)($user)($overlay)@($host) ($pine)($dir)($reset)"
            let right = if ($branch_text | is-empty) {
                $"($iris)($datetime)($reset)"
            } else {
                $"($gold)($branch_text) ($iris)($datetime)($reset)"
            }

            $"($left)($spaces)($right)"
        }

        $env.PROMPT_INDICATOR = {||
            let gold = (ansi {fg: '#f6c177'})
            let red = (ansi {fg: '#eb6f92'})
            let reset = (ansi reset)

            if ($env.LAST_EXIT_CODE? | default 0) == 0 {
                $"\n($gold)✔$ ($reset)"
            } else {
                $"\n($red)✗$ ($reset)"
            }
        }

        $env.PROMPT_COMMAND_RIGHT = ""
        $env.PROMPT_MULTILINE_INDICATOR = {|| "  " }
      '';
    };

    yazi.enable = true;

    zellij = {
      enable = true;

      # TODO: autostart in fish termina
      #       really want just completions only
      #
      # enableFishIntegration = true;
    };

};

  home.packages = lib.mkMerge [
    pkgsSet.cli
    (lib.mkIf hasGuiCapability pkgsSet.gui)
  ];
}
