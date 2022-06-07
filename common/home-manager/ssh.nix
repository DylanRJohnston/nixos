{
  programs.ssh = {
    enable = true;
    matchBlocks = {
      "personal.github.com" = {
        hostname = "github.com";
        user = "git";
        identityFile = "~/.ssh/personal";
      };
      "pi" = {
        hostname = "10.55.0.1";
        user = "dylanj";
        forwardAgent = true;
      };
    };
  };
}
