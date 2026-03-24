{ pkgs, lib, inputs, ... }:
let
  treesitGrammars = pkgs.emacsPackages.treesit-grammars.with-all-grammars;
in
{
  home.file = {
    ".emacs.d/init.sample.el".source = "${inputs.emacs-config}/init.sample.el";
    ".emacs.d/loader.el".source = "${inputs.emacs-config}/loader.el";
    ".emacs.d/layers".source = "${inputs.emacs-config}/layers";
    ".emacs.d/snippets".source = "${inputs.emacs-config}/snippets";
    ".emacs.d/vendor".source = "${inputs.emacs-config}/vendor";
    ".emacs.d/early-init.el".text = ''
      (setq treesit-extra-load-path '("${treesitGrammars}/lib"))
    '';
  };

  home.activation.emacsInit = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p ~/.emacs.d
    mkdir -p ~/.org

    if [ ! -f ~/.emacs.d/init.el ]; then
      cp ${inputs.emacs-config}/init.sample.el ~/.emacs.d/init.el
      chmod u+w ~/.emacs.d/init.el
    fi
  '';

  home.packages = with pkgs; [
    emacs
    emacs-all-the-icons-fonts
    cspell
    hack-font
    sqlite
    gcc
  ];
}
